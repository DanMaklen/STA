module mux(input a, input b, input sel, output o);
	assign o = sel ? b : a;
endmodule