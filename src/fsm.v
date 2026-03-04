`include "definitions.v"

`define  RISING(side) (side``_change &&  side``_direction)
`define FALLING(side) (side``_change && ~side``_direction)

module fsm(
	input clk_i,
	input reset_i,
	input L_i,
	input R_i,

	output increment_o,
	output decrement_o,
	output currently_crossing_o
);

// INTERNAL SIGNALS

wire L_change;
wire L_direction; // 1 = rising, 0 = falling
wire R_change;
wire R_direction;

signal_direction direction_L(
	.clk_i      (clk_i),
	.reset_i    (reset_i),
	.signal_i   (L_i),
	.change_o   (L_change),
	.direction_o(L_direction)
);

signal_direction direction_R(
	.clk_i      (clk_i),
	.reset_i    (reset_i),
	.signal_i   (R_i),
	.change_o   (R_change),
	.direction_o(R_direction)
);

// STATE DEFINITION

parameter INIT         = 0;
parameter L2R_APPROACH = 1;
parameter L2R_COVER    = 2;
parameter L2R_LEAVING  = 3;
parameter R2L_APPROACH = 4;
parameter R2L_COVER    = 5;
parameter R2L_LEAVING  = 6;

wire [6:0] state_d;
reg [6:0] state_q;

always @(posedge clk_i or posedge reset_i) begin
	if (reset_i) begin
		state_q <= 7'b0000001;
	end else begin
		state_q <= state_d;
	end
end

// Someone showed me a way to use a single FDRE call to generate a bus of FFs.
// I could not remember how to do it or replicate it.
// `FCDQI (clk_i, state_d[0], state_q[0], 1'b1);
// `FF_BUS(clk_i, state_d, state_q, 1, 6);

// STATE TRANSITIONS

// undefined behavior
wire panic_to_init = L_change && R_change;

wire l2r_init_to_approach = state_q[INIT] && `FALLING(L);

wire l2r_approach_to_init = state_q[L2R_APPROACH] && `RISING(L);
wire l2r_approach_to_cover = state_q[L2R_APPROACH] && `FALLING(R);

wire l2r_cover_to_approach = state_q[L2R_COVER] && `RISING(R);
wire l2r_cover_to_leaving = state_q[L2R_COVER] && `RISING(L);

wire l2r_leaving_to_cover = state_q[L2R_LEAVING] && `FALLING(L);
wire l2r_leaving_to_init = state_q[L2R_LEAVING] && `RISING(R);

wire r2l_init_to_approach = state_q[INIT] && `FALLING(R);

wire r2l_approach_to_init = state_q[R2L_APPROACH] && `RISING(R);
wire r2l_approach_to_cover = state_q[R2L_APPROACH] && `FALLING(L);

wire r2l_cover_to_approach = state_q[R2L_COVER] && `RISING(L);
wire r2l_cover_to_leaving = state_q[R2L_COVER] && `RISING(R);

wire r2l_leaving_to_cover = state_q[R2L_LEAVING] && `FALLING(R);
wire r2l_leaving_to_init = state_q[R2L_LEAVING] && `RISING(L);


assign state_d[INIT        ] = state_q[INIT        ] &&
	~(l2r_init_to_approach || r2l_init_to_approach)  ||
	(l2r_leaving_to_init || l2r_approach_to_init ||
		r2l_leaving_to_init || r2l_approach_to_init || panic_to_init);

assign state_d[L2R_APPROACH] = state_q[L2R_APPROACH] &&
	~(l2r_approach_to_init || l2r_approach_to_cover || panic_to_init) ||
	(l2r_init_to_approach || l2r_cover_to_approach);
assign state_d[L2R_COVER   ] = state_q[L2R_COVER   ] &&
	~(l2r_cover_to_approach || l2r_cover_to_leaving || panic_to_init) ||
	(l2r_approach_to_cover || l2r_leaving_to_cover);
assign state_d[L2R_LEAVING ] = state_q[L2R_LEAVING ] &&
	~(l2r_leaving_to_cover || l2r_leaving_to_init || panic_to_init)   ||
	(l2r_cover_to_leaving);

assign state_d[R2L_APPROACH] = state_q[R2L_APPROACH] &&
	~(r2l_approach_to_init || r2l_approach_to_cover || panic_to_init) ||
	(r2l_init_to_approach || r2l_cover_to_approach);
assign state_d[R2L_COVER   ] = state_q[R2L_COVER   ] &&
	~(r2l_cover_to_approach || r2l_cover_to_leaving || panic_to_init) ||
	(r2l_approach_to_cover || r2l_leaving_to_cover);
assign state_d[R2L_LEAVING ] = state_q[R2L_LEAVING ] &&
	~(r2l_leaving_to_cover || r2l_leaving_to_init || panic_to_init) ||
	(r2l_cover_to_leaving);

// EXTERNAL SIGNALS

assign increment_o = r2l_leaving_to_init;
assign decrement_o = l2r_leaving_to_init;

assign currently_crossing_o = ~state_q[INIT];

endmodule
