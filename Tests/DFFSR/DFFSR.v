module DFFSR(input D, input clk, input rst, output reg Q, output reg Qbar);
	always@(posedge clk)
		if(rst) begin
			Q <= 0;
			Qbar <= 1;
		end
		else begin
			Q <= D;
			Qbar <= ~D;
		end
endmodule
