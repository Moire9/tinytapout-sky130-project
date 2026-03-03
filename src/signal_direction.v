`include "definitions.v"

module signal_direction(
	input clk_i,
	input signal_i,

	output change_o,
	output direction_o // 1 = rising, 0 = falling
);

reg signal_q = 0;

`FCDQ(clk_i, signal_i, signal_q);

reg previous_q = 0;

`FCDQ(clk_i, signal_q, previous_q);

assign change_o = signal_q ^ previous_q;
assign direction_o = signal_q; //`IF(1, signal_q, RISING, FALLING);

endmodule
