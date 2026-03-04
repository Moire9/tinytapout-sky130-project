`include "definitions.v"

module led_cycler(
	input clk_i,
	input reset_i,
	input cycle_i,
	input enable_i,
	input direction_i, // 1 = r2l, 0 = l2r

	output [7:0] led_o
);

wire [7:0] led_d;
reg [7:0] led_q;

// `FCDQI(clk_i, led_d[0], led_q[0], 1);
// `FF_BUS(clk_i, led_d, led_q, 1, 7);

always @(posedge clk_i) begin
	if (reset_i) begin
		led_q <= 8'b1
	end else begin
		led_q <= led_d;
	end
end

wire [7:0] left;
wire [7:0] right;
rol8 rol8(.i(led_q), .o(left));
ror8 ror8(.i(led_q), .o(right));

assign led_d = `IF(8, cycle_i, `IF(8, direction_i, left, right), led_q);

assign led_o = `IF(8, enable_i, led_q, 0);

endmodule

module rol8(
	input  [7:0] i,
	output [7:0] o
);

assign o = {i[6:0], i[7]};
endmodule

module ror8(
	input  [7:0] i,
	output [7:0] o
);

assign o = {i[0], i[7:1]};
endmodule
