`timescale 1ns / 1ps
module seg_test(
                input      clk,
                input      rst_n,
                output[5:4]seg_sel,
                output[7:0]seg_data,
                output reg[3:0] led            // LED,use for control the LED signal on board

                );
					 
reg[31:0] timer_cnt;
reg en_1hz;                          //1 second , 1 counter enable
//define the time counter
reg [31:0]      timer;
reg [3:0] 		counter; 


always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        en_1hz <= 1'b0;
        timer_cnt <= 32'd0;
    end
    else if(timer_cnt >= 32'd149_999_999)
    begin
        en_1hz <= 1'b1;
        timer_cnt <= 32'd0;
    end
    else
    begin
        en_1hz <= 1'b0;
        timer_cnt <= timer_cnt + 32'd1; 
    end
end

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

always@(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        counter <= 4'b0000; // 复位信号有效时，设置计数器初始值
    else if (timer == 32'd149_999_999)
        counter <= counter + 1; 	 
end


wire[3:0] count0;
wire t0;
//count_m10 count10_m0(
//    .clk    (clk),
//    .rst_n  (rst_n),
//    .en     (en_1hz),
//    .clr    (1'b0),
//    .data   (count0),
//    .t      (t0)
// );
// 
wire[3:0] count1;
wire t1;
//count_m10 count10_m1(
//     .clk    (clk),
//     .rst_n  (rst_n),
//     .en     (t0),
//     .clr    (1'b0),
//     .data   (count1),
//     .t      (t1)
// );


count_m16 count_m16(
    .clk    (clk),
    .rst_n  (rst_n),
    .en     (en_1hz),
    .clr    (1'b0),
    .one (count0),
    .ten (count1),
    .data_0   (count0),
    .data_1   (count1),
    .t      (t0)
 );


wire[6:0] seg_data_4;
seg_decoder seg_decoder_m4(
    .bin_data  (count1),
    .seg_data  (seg_data_4)
);

wire[6:0] seg_data_5;
seg_decoder seg_decoder_m5(
    .bin_data  (count0),
    .seg_data  (seg_data_5)
);

seg_scan seg_scan_m0(
    .clk        (clk),
    .rst_n      (rst_n),
    .seg_sel    (seg_sel),
    .seg_data   (seg_data),
//    .seg_data_0 ({1'b1,seg_data_0}),      //The  decimal point at the highest bit,and low level effecitve
//    .seg_data_1 ({1'b1,seg_data_1}), 
//    .seg_data_2 ({1'b1,seg_data_2}),
//    .seg_data_3 ({1'b1,seg_data_3}),
    .seg_data_4 ({1'b1,seg_data_4}),
    .seg_data_5 ({1'b1,seg_data_5})
);
endmodule 