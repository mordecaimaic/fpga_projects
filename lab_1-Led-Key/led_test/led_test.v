`timescale 1ns / 1ps
module led_test
(
	input           clk,           // system clock 50Mhz on board
	input           rst_n,         // reset ,low active
	output reg[3:0] led,            // LED,use for control the LED signal on board
	input   key1
);

//define the time counter
reg [31:0]      timer;
reg [3:0] 		counter; 


reg enable = 1'b0; // 初始化为低电平，表示初始状态灭
wire button_negedge; // 消抖后的按键下降沿信号

ax_debounce ax_debounce_m0 (
    .clk             (clk),
    .rst             (~rst_n),    // 消抖模块的复位信号需要与 rst_n 取反连接
    .button_in       (key1),
    .button_posedge  (),
    .button_negedge  (button_negedge),
    .button_out      ()
);


// cycle counter:from 0 to 4 sec
always@(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		timer <= 32'd0;                     //when the reset signal valid,time counter clearing
		counter <= 2'd00;
	end
	else if (timer ==32'd49_999_999 && !enable)	// 1 scounter
	begin
		timer <= 32'd0;
		counter <= counter + 1;					 //屏蔽此语句，当进入1s计时模式的时候，counter不会增加，恢复时保持原来的计数值
	end
	else if (timer == 32'd149_999_999)      //3 seconds counter(50M*4-1=199999999)
	begin
		timer <= 32'd0;                     //count done,clearing the time counter
		counter <= counter + 1;    			
	end
	else
		timer <= timer + 32'd1;             //timer counter = timer counter + 1
end




//always@(posedge clk or negedge rst_n)
//begin
//	if (rst_n == 1'b0)
//	begin
//		timer <= 32'd0;                     //when the reset signal valid,time counter clearing
//		counter <= 2'd00;
//	end
//	else if (timer == 32'd149_999_999)      //4 seconds count(50M*4-1=199999999)
//	begin
//		timer <= 32'd0;                     //count done,clearing the time counter
//		counter <= counter + 1;
//	end
//	else
//		timer <= timer + 32'd1;             //timer counter = timer counter + 1
//end




// LED control
always@(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		led <= 4'b0000;                     //when the reset signal active
//	else if (!enable)
//		led <= 4'b0000;
	else if (timer < 32'd12_499_999)       //time counter count to 1st sec,LED1 lighten
		led <= 4'b1000;
	else if (timer == 32'd12_499_999)       //time counter count to 2nd sec,LED2 lighten
		led <= 4'b0100;
	else if (timer == 32'd24_999_999)      //time counter count to 3rd sec,LED3 lighten
		led <= 4'b0010;
	else if (timer == 32'd37_499_999)      //time counter count to 4th sec,LED4 lighten
		led <= 4'b0001;
	else if (timer == 32'd49_499_999)
		begin
		  led[3] <= counter[0];
		  led[2] <= counter[1];
		  led[1] <= counter[2];
		  led[0] <= counter[3];
		end
		
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        enable <= 1'b1; // 复位时禁用，灭
    end else if (button_negedge == 1'b1) begin
        // 在按键下降沿时，切换 LED 状态
        enable <= ~enable;
    end
end

endmodule
