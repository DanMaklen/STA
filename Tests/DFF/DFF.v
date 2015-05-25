module DFF(input D, input clk, output reg Q);
	always@(posedge clk)
		Q <= D;
endmodule
