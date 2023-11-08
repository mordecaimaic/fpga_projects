//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//  Author: meisq                                                               //
//          msq@qq.com                                                          //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//===============================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//-------------------------------------------------------------------------------
//  2017/6/19     meisq         1.0         Original
//*******************************************************************************/
module key_debounce(
    input        clk,
    input        rst_n,
	input        key1,
    output [5:0] seg_sel,
    output [7:0] seg_data,
	output wire led0,
    output wire led1,
    output wire led2,
    output wire led3

);
wire button_negedge; //Key falling edge
reg[31:0] period = 32'd6000; // 2 seconds at 50MHz
reg[32:0] Led_period = 32'd100_000_000;
reg[32:0] step;
reg [31:0] cnt = 0;
reg [31:0] duty = 0;
reg dir = 1'b0; // direction of change
wire pwm_out;



ax_debounce ax_debounce_m0
(
    .clk             (clk),
    .rst             (~rst_n),
    .button_in       (key1),
    .button_posedge  (),
    .button_negedge  (button_negedge),
    .button_out      ()
);

wire[3:0] count;
wire t0;
count_m10 count10_m0(
    .clk    (clk),
    .rst_n  (rst_n),
    .en     (button_negedge),
    .clr    (1'b0),
    .data   (count),
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
//Count decoding
wire[6:0] seg_data_0;
seg_decoder seg_decoder_m0(
    .bin_data  (count),
    .seg_data  (seg_data_0)
);

wire[6:0] seg_data_1;
seg_decoder seg_decoder_m1(
    .bin_data  (count1),
    .seg_data  (seg_data_1)
);
seg_scan seg_scan_m0(
    .clk        (clk),
    .rst_n      (rst_n),
    .seg_sel    (seg_sel),
    .seg_data   (seg_data),
    .seg_data_0 ({1'b1,7'b1111_111}),
    .seg_data_1 ({1'b1,7'b1111_111}),
    .seg_data_2 ({1'b1,7'b1111_111}),
    .seg_data_3 ({1'b1,7'b1111_111}),
//    .seg_data_4 ({1'b1,seg_data_1}),
	 .seg_data_4 ({1'b1,7'b1111_111}),
    .seg_data_5 ({1'b1,seg_data_0})
);




    // Instantiate the ax_pwm module
	  ax_pwm#
	(
		 .N(32)
	) 
	ax_pwm_m0(
		 .clk      (clk),
		 .rst      (~rst_n),
		 .period   (period),
		 .duty     (duty),
		 .pwm_out  (pwm_out)
		 );

   always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            cnt <= 0;
            duty <= 0;
            dir <= 1'b0;
        end else begin
			if(button_negedge)
				begin
                Led_period = Led_period * 2;
					 cnt = 0;
					 duty = 0;
					 dir = 1'b0;
				end
			if (Led_period > 32'd800_000_000)
					  Led_period = 32'd100_000_000;
            cnt = cnt + 1;
            if (cnt == Led_period - 1) begin
                cnt = 0;
                dir = ~dir;
            end
//            if (cnt == 49_999_999) // Change the duty cycle every 1,000,000 clock cycles
//                duty <= dir ? duty + 1 : duty - 1;
				step = 4294967295 / Led_period;
				duty = dir ? duty + step  : duty - step;

        end
    end

    assign led0 = pwm_out;
    assign led1 = pwm_out;
    assign led2 = pwm_out;
    assign led3 = pwm_out;


endmodule 