
`timescale 1ns / 1ps
module led_test
(
	input           clk,           // system clock 50Mhz on board
	input           rst_n,         // reset ,low active
	output reg[3:0] led            // LED,use for control the LED signal on board
);

//define the time counter
reg [31:0]      timer;

// cycle counter:from 0 to 4 sec
always@(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		timer <= 32'd0;                     //when the reset signal valid,time counter clearin
	 else if (timer == 32'd199_999_999)      //4 seconds count(50M*4-1=199999999)
		timer <= 32'd0;                     //count done,clearing the time counter
	else
		timer <= timer + 32'd1;             //timer counter = timer counter + 1
end

// LED control

always@(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		led <= 4'b0000;                     //when the reset signal active
	else if (timer < 32'd49_999_999)       //time counter count less than 2 sec,LED lighten gradually
		led <= timer[31:28];                //use the high four bits of timer as the LED brightness level for all four LEDs
	else                                   //time counter count more than 2 sec,LED dim gradually
		led <= ~timer[31:28];               //use the inverse of the high four bits of timer as the LED brightness level for all four LEDs
end

	
endmodule