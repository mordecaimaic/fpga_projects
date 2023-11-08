module buzzer_pwm_test(
    input wire clk,
    input wire rst_n,
	 input key1,
    output wire led
);

    reg[31:0] period = 32'd6000; // 2 seconds at 50MHz
	reg[32:0] Led_period = 32'd50_000_000;
    reg [31:0] cnt = 0;
    reg [31:0] duty = 0;
    reg dir = 1'b0; // direction of change
    wire pwm_out;

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
//			if(button_negedge)
//				begin
//				if ()
//				end
            cnt <= cnt + 1;
            if (cnt == 99_999_999) begin
                cnt <= 0;
                dir <= ~dir;
            end
//            if (cnt == 49_999_999) // Change the duty cycle every 1,000,000 clock cycles
//                duty <= dir ? duty + 1 : duty - 1;
				duty <= dir ? duty + 4294967295 / 100_000_000 : duty - 4294967295/ 100_000_000;

        end
    end

	ax_debounce ax_debounce_m0
	(
		.clk             (clk),
		.rst             (~rst_n),
		.button_in       (key1),
		.button_posedge  (),
		.button_negedge  (button_negedge),
		.button_out      ()
	);

    assign led = pwm_out;

endmodule