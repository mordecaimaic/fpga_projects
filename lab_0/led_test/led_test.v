`timescale 1ns / 1ps
module led_test
(
	input           clk,           // system clock 50Mhz on board
	input           rst_n,         // reset ,low active
	output reg[3:0] led            // LED,use for control the LED signal on board
);

//define the time counter
reg [31:0]      timer;
reg [3:0] 		counter; 

// cycle counter:from 0 to 4 sec
always@(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		timer <= 32'd0;                     //when the reset signal valid,time counter clearin
	 else if (timer == 32'd149_999_999)      //4 seconds count(50M*4-1=199999999)
		timer <= 32'd0;                     //count done,clearing the time counter
	else
		timer <= timer + 32'd1;             //timer counter = timer counter + 1
end

// LED control

always@(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		led <= 4'b0000;                     //when the reset signal active
	else if (timer < 32'd12_499_999)       //time counter count less than 0.25 sec,LED1 lighten
		led <= 4'b0001;
	else if (timer == 32'd12_499_999)       //time counter count to 0.25 sec,LED2 lighten
		led <= 4'b0010;
	else if (timer == 32'd24_999_999)      //time counter count to 0.50 sec,LED3 lighten
		led <= 4'b0100;
	else if (timer == 32'd37_499_999)      //time counter count to 0.75 sec,LED4 lighten
		led <= 4'b1000;
	else if (timer == 32'd49_499_999)		//time counter count to 1.0 sec,counter lighten
    begin
		  led[3] <= counter[0];
        led[2] <= counter[1];
        led[1] <= counter[2];
        led[0] <= counter[3];
		end
end



always@(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        counter <= 4'b0000; // reset signal valid，set counter to initial
    else if (timer == 32'd149_999_999) // timer counter count to 3.0sec, Led counter+=1
        counter <= counter + 1; 	 
end
	
endmodule	