`include "definitions.v"

module led_cycler(
	input clk_i,
	input reset_i,
	input cycle_i,
	input enable_i,
	input direction_i, // 1 = r2l, 0 = l2r

	output [3:0] led_o
);

wire [3:0] led_d;
reg  [3:0] led_q;

always @(posedge clk_i or posedge reset_i) begin
	if (reset_i) begin
		led_q <= 4'b1;
	end else begin
		led_q <= led_d;
	end
end

wire [3:0] left;
wire [3:0] right;
rol4 rol4(.i(led_q), .o(left));
ror4 ror4(.i(led_q), .o(right));

assign led_d = `IF(4, cycle_i, `IF(4, direction_i, left, right), led_q);

assign led_o = `IF(4, enable_i, led_q, 0);

endmodule

module rol4(
	input  [3:0] i,
	output [3:0] o
);

assign o = {i[2:0], i[3]};
endmodule

module ror4(
	input  [3:0] i,
	output [3:0] o
);

assign o = {i[0], i[3:1]};
endmodule
