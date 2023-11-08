module key_test
(
	input                 clk,       // 系统上的时钟，50MHz
	input [3:0]           key,       // 输入的按键信号
	output [3:0]       led        // LED，用于控制板上的LED信号
);

reg[3:0] led_r;  // 定义第一个级联寄存器，生成四个 D 触发器
reg enable;

always @(posedge clk) begin
	if (key[1] == 1'b0)
		enable = ~enable;
	led_r = (enable) ? 4'b1111 : 4'b0000; // 当 key[1] 按下时，led_r 全部置位；否则，全部清零
end

assign led = led_r;

endmodule
