module buzzer_pwm_test(
    input wire clk,
    input wire rst_n,
	 input key,
    output wire led0,
	 output wire led1,
	 output wire led2,
	 output wire led3
);
	wire button_negedge; //Key falling edge
    reg[31:0] period = 32'd6000; // 2 seconds at 50MHz
	reg[32:0] Led_period = 32'd100_000_000;
    reg [31:0] cnt = 0;
	 reg[32:0] step;
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

	ax_debounce ax_debounce_m0
	(
		.clk             (clk),
		.rst             (~rst_n),
		.button_in       (key),
		.button_posedge  (),
		.button_negedge  (button_negedge),
		.button_out      ()
	);

    assign led0 = pwm_out;
	 assign led1 = pwm_out;
	 assign led2 = pwm_out;
	 assign led3 = pwm_out;

endmodule