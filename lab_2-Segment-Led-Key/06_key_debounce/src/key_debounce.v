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
	 input		  key_3,
    output [5:0] seg_sel,
    output [7:0] seg_data
);
wire button_negedge; //Key falling edge
ax_debounce ax_debounce_m0
(
    .clk             (clk),
    .rst             (~rst_n),
    .button_in       (key1),
    .button_posedge  (),
    .button_negedge  (button_negedge),
    .button_out      ()
);

ax_debounce ax_debounce_m1
(
    .clk             (clk),
    .rst             (~rst_n),
    .button_in       (key_3),
    .button_posedge  (),
    .button_negedge  (button_negedge_3),
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
wire[3:0] count2;
wire t2;
count_m10 count10_m2(
    .clk    (clk),
    .rst_n  (rst_n),
    .en     (t1 || button_negedge_3),
    .clr    (1'b0),
    .data   (count2),
    .t      (t2)
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

wire[6:0] seg_data_2;
seg_decoder seg_decoder_m2(
    .bin_data  (count2),
    .seg_data  (seg_data_2)
);

seg_scan seg_scan_m0(
    .clk        (clk),
    .rst_n      (rst_n),
    .seg_sel    (seg_sel),
    .seg_data   (seg_data),
    .seg_data_0 ({1'b1,7'b1111_111}),
    .seg_data_1 ({1'b1,7'b1111_111}),
    .seg_data_2 ({1'b1,7'b1000_000}),
    .seg_data_3 ({1'b1,seg_data_2}),
    .seg_data_4 ({1'b1,seg_data_1}),
    .seg_data_5 ({1'b1,seg_data_0})
);
endmodule 