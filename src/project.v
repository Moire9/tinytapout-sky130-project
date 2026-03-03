/*
 * Copyleft (c) 2026 Moire9
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_moire9_abysmal_dogshit_application (
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

  top top(
		.board_clk_i(clk),
		.btnU_async_i(~rst_n),
		.btnR_async_i(ui_in[0]),
		.btnL_async_i(ui_in[1]),
		.dp_o(uo_out[7]),
		.seg_o(uo_out[6:0]),
		.an_o(uio_out[3:0]),
		.led_o(uio_out[7:4])
  );

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:3], uio_in, 1'b0};

endmodule
