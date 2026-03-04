`include "definitions.v"

module turkey_counter(
	input clk_i,
	input reset_i,
	input inc_i,
	input dec_i,
	output [7:0] Q_o
);
    reg [7:0] Q;
    assign Q_o = Q;

	always @(posedge clk_i) begin
		if (reset_i)
			Q <= 0;
		else if (inc_i)
			Q <= Q + 1;
		else if (dec_i)
			Q <= Q - 1;
	end
endmodule
