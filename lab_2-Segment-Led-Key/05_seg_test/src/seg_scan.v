module seg_scan(
	input           clk,
	input           rst_n,
	output reg[5:0] seg_sel,      //digital led chip select
	output reg[7:0] seg_data,     //eight segment digital tube output,MSB is the decimal point
	input[7:0]      seg_data_0,
	input[7:0]      seg_data_1,
	input[7:0]      seg_data_2,
	input[7:0]      seg_data_3,
	input[7:0]      seg_data_4,
	input[7:0]      seg_data_5
);
parameter SCAN_FREQ = 200;     //scan frequency
parameter CLK_FREQ = 50000000; //clock frequency

parameter SCAN_COUNT = CLK_FREQ /(SCAN_FREQ * 6) - 1;

reg[31:0] scan_timer;  //scan time counter
reg[3:0] scan_sel;     //Scan select counter

always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		scan_timer <= 32'd0;
		scan_sel <= 4'd0;
	end
	else if(scan_timer >= SCAN_COUNT)
	begin
		scan_timer <= 32'd0;
		if(scan_sel == 4'd5)
			scan_sel <= 4'd0;
		else
			scan_sel <= scan_sel + 4'd1;
	end
	else
		begin
			scan_timer <= scan_timer + 32'd1;
		end
end
always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		seg_sel <= 6'b111111;
		seg_data <= 8'hff;
	end
	else
	begin
		case(scan_sel)
			//first digital led
			4'd0:
			begin
				seg_sel <= 6'b11_1110;
				seg_data <= input_data[0];
			end
			//second digital led
			4'd1:
			begin
				seg_sel <= 6'b11_1101;
				seg_data <= input_data[1];
			end
			//...
			4'd2:
			begin
				seg_sel <= 6'b11_1011;
				seg_data <= input_data[2];
			end
			4'd3:
			begin
				seg_sel <= 6'b11_0111;
				seg_data <= input_data[3];
			end
			4'd4:
			begin
				seg_sel <= 6'b10_1111;
				seg_data <= input_data[4];
			end
			4'd5:
			begin
				seg_sel <= 6'b01_1111;
				seg_data <= input_data[5];
			end
			default:
			begin
				seg_sel <= 6'b11_1111;
				seg_data <= 8'hff;
			end
		endcase
	end
end

reg [7:0] input_data[0:5]; // 定义一个 6x8 的二维 reg 数组
reg[3:0] i;
reg flag = 0;

always @(posedge clk) begin
   input_data[0] = seg_data_0;
   input_data[1] = seg_data_1;
   input_data[2] = seg_data_2;
   input_data[3] = seg_data_3;
   input_data[4] = seg_data_4;
   input_data[5] = seg_data_5;

     for (i = 0; i < 5; i = i + 1) begin
      if (input_data[i] == 8'b1100_0000 && flag == 0)
         input_data[i] = 8'b1111_1111;
	  else if  (input_data[i] != 8'b1100_0000)
	  	flag = 1;
      end

   flag = 0;
	
end



endmodule