/*
 * Copyleft (c) 2026 Moire9
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_moire9_directional_counter (
	input  wire [7:0] ui_in,    // Dedicated inputs
	output wire [7:0] uo_out,   // Dedicated outputs
	input  wire [7:0] uio_in,   // IOs: Input path
	output wire [7:0] uio_out,  // IOs: Output path
	output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
	input  wire       ena,      // always 1 when the design is powered, so you can ignore it
	input  wire       clk,      // clock
	input  wire       rst_n     // reset_n - low to reset
);

	assign uio_oe = 8'b11111111;

	wire [6:0] sevenseg_disp;
	wire [7:0] debug_turkeys;

	top top(
		.board_clk_i(clk),
		.reset_i(~rst_n),
		.btnR_async_i(ui_in[0]),
		.btnL_async_i(ui_in[1]),
		.seg_o(sevenseg_disp),
		.an_o(uio_out[3:0]),
		.led_o(uio_out[7:4]),
		.debug_turkeys_o(debug_turkeys)
	);

	// Testing mode with ui_in[7]
	assign uo_out = ui_in[7] ? debug_turkeys : {1'b0, sevenseg_disp};

	// List all unused inputs to prevent warnings
	wire _unused = &{ena, ui_in[7:3], uio_in, 1'b0};

endmodule
