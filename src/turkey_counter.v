`include "definitions.v"

module turkey_counter(
	input clk_i,
	input inc_i,
	input dec_i,
	input reset_i,
	output [7:0] Q_o
);
    reg [7:0] Q = 0;
    assign Q_o = Q;
	wire keep = (~inc_i & ~dec_i & ~reset_i) | (inc_i & dec_i & ~reset_i);

	wire [7:0] ff_D;

	`FF_BUS(clk_i, ff_D, Q, 0, 7)

	wire [7:0] incremented;
	wire [7:0] decremented;
	inc #(.WIDTH(8)) inc(.i(Q_o), .o(incremented));
	dec dec(.i(Q_o), .o(decremented));

	assign ff_D = `IF(8, keep, Q_o, `IF(8,
		reset_i, 0, // else
			incremented & {8{inc_i}} |
			decremented & {8{dec_i}}
		));
endmodule

module inc #(
	parameter WIDTH = 8
) (
	input  [WIDTH-1:0] i,
	output [WIDTH-1:0] o,
	output c_o
);
	assign c_o = &i;
	assign o[0] =~i[0]; // = i[0] ^ 1;
	// Generate a truth table. This is still structural - no behavioral
	// operators in sight, besides those used to loop.
	generate
		for (genvar b = 1; b < WIDTH; b = b + 1) begin
			assign o[b] = i[b] ^ &i[(b-1):0];
		end
	endgenerate
	// assign o[1] = i[1] ^  i[0];
	// assign o[2] = i[2] ^ &i[1:0];
	// assign o[3] = i[3] ^ &i[2:0];
	// assign o[4] = i[4] ^ &i[3:0];
	// assign o[5] = i[5] ^ &i[4:0];
endmodule

module dec #(
	parameter WIDTH = 8
) (
	input  [WIDTH-1:0] i,
	output [WIDTH-1:0] o,
	output n_o // negative
);
	assign n_o =  ~|o;
	assign o[0] = ~i[0];
	generate
		for (genvar b = 1; b < WIDTH; b = b + 1) begin
			assign o[b] = ~(i[b] ^ |i[(b-1):0]);
		end
	endgenerate

	// assign o[1] = ~(i[1] ^  i[0]);
	// assign o[2] = ~(i[2] ^ |i[1:0]);
	// assign o[3] = ~(i[3] ^ |i[2:0]);
	// assign o[4] = ~(i[4] ^ |i[3:0]);
	// assign o[5] = ~(i[5] ^ |i[4:0]);
	// assign o[6] = ~(i[6] ^ |i[5:0]);
	// assign o[7] = ~(i[7] ^ |i[6:0]);
	
	// FDRE ff1 [3:0] 
endmodule
