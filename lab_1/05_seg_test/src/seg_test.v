module seg_test(
                input      clk,
                input      rst_n,
                output reg[3:0] led,            // LED,use for control the LED signal on board
	             input   key1,
                output[5:0]seg_sel,
                output[7:0]seg_data
                );

//define the time counter
reg [31:0]      timer;
reg [3:0] 		counter; 

reg enable = 1'b0; // 初始化为低电平，表示初始状态灭
wire button_negedge; // 消抖后的按键下降沿信号

reg[31:0] timer_cnt;
reg en_1hz;                          //1 second , 1 counter enable

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
	else if (timer ==32'd49_999_999)	// 1 scounter
	begin
		timer <= 32'd0;
		counter <= counter + 1;
	end
	else
		timer <= timer + 32'd1;             //timer counter = timer counter + 1
end


// LED control
always@(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		led <= 4'b0000;                     //when the reset signal active
//	else if (!enable)
//		led <= 4'b0000;
	else if (timer < 32'd12_499_999)       //time counter count to less than 0.25 sec,LED1 lighten
		led <= 4'b1000;
	else if (timer == 32'd12_499_999)       //time counter count to 0.25 sec,LED2 lighten
		led <= 4'b0100;
	else if (timer == 32'd24_999_999)      //time counter count to 0.5 sec,LED3 lighten
		led <= 4'b0010;
	else if (timer == 32'd37_499_999)      //time counter count to 0.75 sec,LED4 lighten
		led <= 4'b0001;
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        enable <= 1'b1; // 复位时禁用，灭
    end else if (button_negedge == 1'b1) begin
        // 在按键下降沿时，切换 LED 状态
        enable <= ~enable;
    end
end


always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        en_1hz <= 1'b0;
        timer_cnt <= 32'd0;
    end
    else if(timer_cnt >= 32'd49_999_999)
    begin
        en_1hz <= 1'b1;
        timer_cnt <= 32'd0;
    end
//    else if(enable) // 启用这一行，当key1按下的时候，后台计数暂停，数码管显示暂停
	 else					// 启用这一行，当key1按下的时候，后台计数继续进行，但数码管显示暂停
    begin
        en_1hz <= 1'b0;
        timer_cnt <= timer_cnt + 32'd1; 
    end
end
wire[3:0] count0;
wire t0;
count_m10 count10_m0(
    .clk    (clk),
    .rst_n  (rst_n),
    .en     (en_1hz),
    .clr    (1'b0),
    .data   (count0),
    .t      (t0)
 );
wire[3:0] count1;
wire t1;
count_m10 count10_m1(
     .clk    (clk),
     .rst_n  (rst_n),
     .en     (t0),
     .clr    (1'b0),
     .data   (count1),
     .t      (t1)
 );

wire[3:0] count2;
wire t2;
count_m10 count10_m2(
    .clk   (clk),
    .rst_n (rst_n),
    .en    (t1),
    .clr   (1'b0),
    .data  (count2),
    .t     (t2)
);

wire[3:0] count3;
wire t3;
count_m10 count10_m3(
    .clk   (clk),
    .rst_n (rst_n),
    .en    (t2),
    .clr   (1'b0),
    .data  (count3),
    .t     (t3)
);

wire[3:0] count4;
wire t4;
count_m10 count10_m4(
    .clk   (clk),
    .rst_n (rst_n),
    .en    (t3),
    .clr   (1'b0),
    .data  (count4),
    .t     (t4)
);

wire[3:0] count5;
wire t5;
count_m10 count10_m5(
    .clk   (clk),
    .rst_n (rst_n),
    .en    (t4),
    .clr   (1'b0),
    .data  (count5),
    .t     (t5)
);

wire[6:0] seg_data_0;
seg_decoder seg_decoder_m0(
    .bin_data  (count5),
	 .enable		(enable),
    .seg_data  (seg_data_0)
);
wire[6:0] seg_data_1;
seg_decoder seg_decoder_m1(
    .bin_data  (count4),
	 .enable		(enable),
    .seg_data  (seg_data_1)
);
wire[6:0] seg_data_2;
seg_decoder seg_decoder_m2(
    .bin_data  (count3),
	 .enable		(enable),
    .seg_data  (seg_data_2)
);
wire[6:0] seg_data_3;
seg_decoder seg_decoder_m3(
    .bin_data  (count2),
	 .enable		(enable),
    .seg_data  (seg_data_3)
);
wire[6:0] seg_data_4;
seg_decoder seg_decoder_m4(
    .bin_data  (count1),
	 .enable		(enable),
    .seg_data  (seg_data_4)
);

wire[6:0] seg_data_5;
seg_decoder seg_decoder_m5(
    .bin_data  (count0),
	 .enable		(enable),
    .seg_data  (seg_data_5)
);

seg_scan seg_scan_m0(
    .clk        (clk),
    .rst_n      (rst_n),
    .seg_sel    (seg_sel),
    .seg_data   (seg_data),
    .seg_data_0 ({1'b1,seg_data_0}),      //The  decimal point at the highest bit,and low level effecitve
    .seg_data_1 ({1'b1,seg_data_1}), 
    .seg_data_2 ({1'b1,seg_data_2}),
    .seg_data_3 ({1'b1,seg_data_3}),
    .seg_data_4 ({1'b1,seg_data_4}),
    .seg_data_5 ({1'b1,seg_data_5})
);
endmodule 