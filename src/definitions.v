// `include "definitions.v"

`ifndef __DEFINITIONS_V
`define __DEFINITIONS_V

`timescale 1ns / 1ps

// "You will be typing FDRE until your fingers fall off" -Raphael
`define FCREDQI(clock, reset, enable, data, qata, init) \
always @(posedge clock) begin if (enable) qata <= (reset) ? (init) : (data); end
//	FDRE #(.INIT(init)) FF_`__LINE__ (.C(clock), .R(reset), .CE(enable), .D(data), .Q(qata))
`define FCDQ(clock, data, qata) `FCREDQI(clock, 1'b0, 1'b1, data, qata, 1'b0)
`define FCDQI(clock, data, qata, init) `FCREDQI(clock, 1'b0, 1'b1, data, qata, init)
`define FF_BUS(clock, data, qata, startbit, endbit) \
	generate for (genvar GV_`__LINE__ = startbit; GV_`__LINE__ <= endbit; GV_`__LINE__ = GV_`__LINE__ + 1) begin `FCDQ(clk_i, data[GV_`__LINE__], qata[GV_`__LINE__]); end endgenerate

`define IF(width, argument, truecase, falsecase) ({width{argument}} & (truecase) | {width{~(argument)}} & (falsecase))
`define IF1(argument, truecase, falsecase) IF(1, argument, truecase, falsecase)

`endif
