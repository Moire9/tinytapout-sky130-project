`include "definitions.v"

module signal_direction(
	input clk_i,
	input signal_i,
	input reset_i,

	output change_o,
	output direction_o // 1 = rising, 0 = falling
);

reg signal_q, previous_q;

always @(posedge clk_i or posedge reset_i) begin
	if (reset_i) begin
		signal_q <= 0;
		previous_q <= 0;
	end else begin
		previous_q <= signal_q;
		signal_q <= signal_i;
	end
end

assign change_o = signal_q ^ previous_q;
assign direction_o = signal_q;

endmodule
