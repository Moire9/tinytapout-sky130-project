`include "definitions.v"

module top(
	input board_clk_i,
	input reset_i,
	input btnL_async_i,
	input btnR_async_i,

	output [6:0] seg_o,
	output [3:0] an_o,
	output [3:0] led_o
);

// DEFINITIONS

parameter [0:0] DIRECTION_R2L = 1; // positive
parameter [0:0] DIRECTION_L2R = 0; // negative

wire clk_4Hz;
wire clk_i; // 11 Mhz
wire digsel; // 60 Hz

clock_divider clock_divider(
	.clk_in(board_clk_i),
	.reset(reset_i),
	.clk_4Hz(clk_4Hz),
	.clk_11MHz_div(clk_i),
	.digsel(digsel)
);

wire [3:0] hex_digit_index;

wire btnL, btnR;

wire [7:0] turkeys;
wire negative_turkeys = turkeys[7];
wire [7:0] turkeys_inverted = ~turkeys + 1;
wire [7:0] turkeys_abs = `IF(8, negative_turkeys, turkeys_inverted, turkeys);

reg ever_crossed; // Starts at 0 then goes 1 forever
wire ever_crossed_d;
reg last_direction;
wire last_direction_d;
wire currently_crossing; // suspends LED direction

wire strobe_increment_turkeys;
wire strobe_decrement_turkeys;

ring_counter ring_counter(
	.clk_i    (clk_i),
	.reset_i  (reset_i),
	.advance_i(digsel),
	.ring_o   (hex_digit_index)
);

// STATE

turkey_counter turkey_counter(
	.clk_i  (clk_i),
	.reset_i(reset_i),
	.inc_i  (strobe_increment_turkeys),
	.dec_i  (strobe_decrement_turkeys),
	.Q_o    (turkeys)
);

always @(posedge clk_i or posedge reset_i) begin
	if (reset_i) begin
		last_direction <= 0;
		ever_crossed <= 0;
	end else begin
		last_direction <= last_direction_d;
		ever_crossed <= ever_crossed_d;
	end
end

assign last_direction_d = (strobe_increment_turkeys & DIRECTION_R2L) |
	(strobe_decrement_turkeys & DIRECTION_L2R) |
	((~strobe_decrement_turkeys & ~strobe_increment_turkeys) & last_direction);

assign ever_crossed_d = ever_crossed | strobe_decrement_turkeys | strobe_increment_turkeys;

// INPUT

edge_detector #(.STROBE(0)) sync_btnL(
	.clk_i   (clk_i),
	.reset_i (reset_i),
	.button_i(~btnL_async_i),
	.edge_o  (btnL)
);
edge_detector #(.STROBE(0)) sync_btnR(
	.clk_i   (clk_i),
	.reset_i (reset_i),
	.button_i(~btnR_async_i),
	.edge_o  (btnR)
);

// OUTPUT

assign an_o = {
	1'b1,
	~(hex_digit_index[2] && negative_turkeys),
	~hex_digit_index[1],
	~hex_digit_index[0]
};

wire [3:0] current_hex_digit = `IF(4, hex_digit_index[1], turkeys_abs[7:4], turkeys_abs[3:0]);

wire [6:0] encoded_digit;
hex7seg hex7seg(
	.N_i  (current_hex_digit),
	.Seg_o(encoded_digit)
);

assign seg_o = `IF(7, hex_digit_index[2], 7'b0111111, encoded_digit);

led_cycler led_cycler(
	.clk_i      (clk_i),
	.reset_i    (reset_i),
	.cycle_i    (clk_4Hz),
	.direction_i(last_direction),
	.enable_i   (!currently_crossing && ever_crossed),
	.led_o      (led_o[3:0])
);

// FSM

fsm fsm(
	.clk_i(clk_i),
	.reset_i(reset_i),
	.L_i  (btnL),
	.R_i  (btnR),

	.increment_o(strobe_increment_turkeys),
	.decrement_o(strobe_decrement_turkeys),

	.currently_crossing_o(currently_crossing)
);

endmodule


module clock_divider (
    input  wire clk_in, // 50 MHz
    input  wire reset,
    output reg  clk_4Hz,
    output reg  clk_11MHz_div,
    output reg  digsel
);

    reg [23:0] clk_counter_4hz;
    reg [3 :0] clk_counter_11mhz;
    reg [20:0] clk_counter_digsel;

    always @(posedge clk_in) begin
        if (reset) begin
            clk_counter_4hz   <= 24'd0;
            clk_counter_11mhz <= 4'd0;
            clk_counter_digsel<= 21'd0;
            clk_4Hz           <= 1'b0;
            clk_11MHz_div     <= 1'b0;
            digsel            <= 1'b0;
        end else begin
            if (clk_counter_4hz == 24'd12500000) begin
                clk_counter_4hz <= 24'd0;
                clk_4Hz <= ~clk_4Hz;
            end else begin
                clk_counter_4hz <= clk_counter_4hz + 1'b1;
            end

            if (clk_counter_11mhz == 4'd9) begin
                clk_counter_11mhz <= 4'd0;
                clk_11MHz_div <= ~clk_11MHz_div;
            end else begin
                clk_counter_11mhz <= clk_counter_11mhz + 1'b1;
            end

            if (clk_counter_digsel == 21'd1666667) begin
                clk_counter_digsel <= 21'd0;
                digsel <= ~digsel;
            end else begin
                clk_counter_digsel <= clk_counter_digsel + 1'b1;
            end
        end
    end

endmodule

