module key_debounce(
    input                clk,        // 系统时钟
    input                rst_n,      // 复位信号，低电平有效
    input                key1,       // 消抖后的按键输入
    output reg [3:0]     led         // LED 输出
);

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

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        enable <= 1'b0; // 复位时禁用，灭
    end else if (button_negedge == 1'b1) begin
        // 在按键下降沿时，切换 LED 状态
        enable <= ~enable;
    end
end

always @(posedge clk) begin
    if (enable) begin
        led <= 4'b1111; // 如果 enable 为高电平，所有 LED 亮
    end else begin
        led <= 4'b0000; // 如果 enable 为低电平，所有 LED 灭
    end
end

endmodule
