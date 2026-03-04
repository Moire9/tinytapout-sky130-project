`include "definitions.v"

module edge_detector
	#(
	parameter STROBE = 1
)
	(
    input clk_i,
    input reset_i,
    input button_i,
    output edge_o
);
	reg current_Q;
	reg old_Q;
	
	always @(posedge clk_i) begin
		if (reset_i) begin
			current_Q <= 0;
			old_Q <= 0;
		end else begin
			current_Q <= button_i;
			old_Q <= current_Q;
		end
	end

	// FDRE #(.INIT(0)) ff_current(.C(clk_i), .R(0), .CE(1), .D( button_i), .Q(current_Q));
	// FDRE #(.INIT(0)) ff_old    (.C(clk_i), .R(0), .CE(1), .D(current_Q), .Q(old_Q));
	// `FCDQ(clk_i, button_i, current_Q);

	// generate
		// if (STROBE) begin
	// `FCDQ(clk_i, current_Q, old_Q);
		// end
	// endgenerate
	
	// assign edge_o = old_Q == 0 && current_Q == 1;
	assign edge_o = STROBE ? ~old_Q && current_Q : current_Q; //`IF(1, STROBE, ~old_Q && current_Q, current_Q);
endmodule
