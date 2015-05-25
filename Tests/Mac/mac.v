// Basic Components; muxes, flip-flops, etc.
//
// Author: Ivan Castellanos
// email: ivan.castellanos@okstate.edu
// VLSI Computer Architecture Research Group,
// Oklahoma Stata University


//Reduced Full Adder Cell (for CLA, 8 gates instead of 9)

module rfa (sum, g, p, a, b, cin);

   output sum;
   output g;
   output p;
   input a;
   input b;
   input cin;

   //xor x1(sum, a, b, cin);
   assign sum = a ^ b ^ cin;
   
   //and a1(g, a, b);
   assign g = a & b;
   
   //or  o1(p, a, b);
   assign p = a | b;
   
endmodule


//17-bit Register with reset

module dffr_17 (q, d, clk, reset);

   output [16:0] q;
   input  [16:0] d;
   input  clk, reset;
   
   reg [16:0] q;
   
   always @ (posedge clk or negedge reset) 
      if (reset == 0)
         q <= 0; 
      else
         q <= d;

endmodule

//Basic adders for Multiplier

module FA (Sum, Cout, A, B, Cin);

   input A;
   input B;
   input Cin;   

   output Sum;
   output Cout;

	wire	w1;
	wire	w2;
	wire	w3;
	wire	w4;

	xor	x1(w1, A, B);
	xor	x2(Sum, w1, Cin);

	nand    n1(w2, A, B);
	nand    n2(w3, A, Cin);
	nand	n3(w4, B, Cin);
	//nand	n4(Cout, w2, w3, w4);
	assign Cout = ~ (w2 & w3 & w4);

endmodule // FA

module MFA (Sum, Cout, A, B, Sin, Cin);

   input A;
   input B;
   input Sin;
   input Cin;   

   output Sum;
   output Cout;

	wire    w0;
	wire	w1;
	wire	w2;
	wire	w3;
	wire	w4;

	and     a1(w0, A, B);

	xor	x1(w1, w0, Sin);
	xor	x2(Sum, w1, Cin);

	nand    n1(w2, w0, Sin);
	nand    n2(w3, w0, Cin);
	nand	n3(w4, Sin, Cin);
	//nand	n4(Cout, w2, w3, w4);
	assign Cout = ~ (w2 & w3 & w4);


endmodule // MFA

module NMFA (Sum, Cout, A, B, Sin, Cin);

   input A;
   input B;
   input Sin;
   input Cin;   

   output Sum;
   output Cout;

	wire  w0;
	wire	w1;
	wire	w2;
	wire	w3;
	wire	w4;

	nand    n0(w0, A, B);

	xor	x1(w1, w0, Sin);
	xor	x2(Sum, w1, Cin);

	nand    n1(w2, w0, Sin);
	nand    n2(w3, w0, Cin);
	nand	n3(w4, Sin, Cin);
	//nand	n4(Cout, w2, w3, w4);
	assign Cout = ~ (w2 & w3 & w4);


endmodule // NMFA

module MHA (Sum, Cout, A, B, Sin);

   input A;
   input B;
   input Sin;

   output Sum;
   output Cout;

	wire	w1;

	and	a0(w1, A, B);

	xor	x1(Sum, w1, Sin);

	and	a1(Cout, w1, Sin);

endmodule // MHA

// 16-Bit Carry Look Ahead adder, test design for Standard Cell/Custom Design
// 
// Author: Ivan Castellanos
// email: ivan.castellanos@okstate.edu
// VLSI Computer Architecture Research Group,
// Oklahoma Stata University

module cla16(sum, a, b);
    
   output [16:0] sum;
   input  [15:0] a,b;
   
   wire [14:0] carry;
   wire [15:0] g, p;
   wire [4:0] gout, pout;

   rfa rfa0(sum[0], g[0], p[0], a[0], b[0], 1'b0);
   rfa rfa1(sum[1], g[1], p[1], a[1], b[1], carry[0]);
   rfa rfa2(sum[2], g[2], p[2], a[2], b[2], carry[1]);
   rfa rfa3(sum[3], g[3], p[3], a[3], b[3], carry[2]);
   bclg4 bclg30(carry[2:0], gout[0], pout[0], g[3:0], p[3:0], 1'b0);
   
   rfa rfa4(sum[4], g[4], p[4], a[4], b[4], carry[3]);
   rfa rfa5(sum[5], g[5], p[5], a[5], b[5], carry[4]);
   rfa rfa6(sum[6], g[6], p[6], a[6], b[6], carry[5]);
   rfa rfa7(sum[7], g[7], p[7], a[7], b[7], carry[6]);
   bclg4 bclg74(carry[6:4], gout[1], pout[1], g[7:4], p[7:4], carry[3]);
   
   rfa rfa8(sum[8], g[8], p[8], a[8], b[8], carry[7]);
   rfa rfa9(sum[9], g[9], p[9], a[9], b[9], carry[8]);
   rfa rfa10(sum[10], g[10], p[10], a[10], b[10], carry[9]);
   rfa rfa11(sum[11], g[11], p[11], a[11], b[11], carry[10]);
   bclg4 bclg118(carry[10:8], gout[2], pout[2], g[11:8], p[11:8], carry[7]);

   rfa rfa12(sum[12], g[12], p[12], a[12], b[12], carry[11]);
   rfa rfa13(sum[13], g[13], p[13], a[13], b[13], carry[12]);
   rfa rfa14(sum[14], g[14], p[14], a[14], b[14], carry[13]);
   rfa rfa15(sum[15], g[15], p[15], a[15], b[15], carry[14]);
   bclg4 bclg1512(carry[14:12], gout[3], pout[3], g[15:12], p[15:12], carry[11]);

   bclg4 bclg_150({carry[11], carry[7], carry[3]}, gout[4], pout[4], {gout[3], gout[2], gout[1], gout[0]}, {pout[3], pout[2], pout[1], pout[0]}, 1'b0);

   assign sum[16] = gout[4]; 

endmodule


// 4-bit Block Carry Look-Ahead Generator

module bclg4 (cout, gout, pout, g, p, cin);

   output [2:0] cout;
   output gout;
   output pout;
   input [3:0] g;
   input [3:0] p;
   input cin;
   
   wire a1_out, a2_out, a3_out, a4_out, a5_out, a6_out;
   wire a7_out, a8_out, a9_out;

   and a1(a1_out, p[0], cin);
   or  o1(cout[0], g[0], a1_out);

   and a2(a2_out, p[1], g[0]);
   //and a3(a3_out, p[1], p[0], cin);
   assign a3_out = p[1] & p[0] & cin;
   
   //or  o2(cout[1], g[1], a2_out, a3_out);
   assign cout[1] = g[1] | a2_out | a2_out;

   and a4(a4_out, p[2], g[1]);
   //and a5(a5_out, p[2], p[1], g[0]);
   assign a5_out = p[2] & p[1] & g[0];
   
   //and a6(a6_out, p[2], p[1], p[0], cin);
   assign a6_out = p[2]& p[1]& p[0]& cin;
   
   //or  o3(cout[2], g[2], a4_out, a5_out, a6_out);
   assign cout[2] = g[2] | a4_out |  a5_out | a6_out;
	 
   and a7(a7_out, p[3], g[2]);
   //and a8(a8_out, p[3], p[2], g[1]);
   assign a8_out = p[3] & p[2] & g[1];
   
   //and a9(a9_out, p[3], p[2], p[1], g[0]);
   assign a9_out = p[3] & p[2] & p[1] & g[0];
   
   //or  o4(gout, g[3], a7_out, a8_out, a9_out);
   assign gout= g[3]| a7_out| a8_out| a9_out;
   
   //and a10(pout, p[0], p[1], p[2], p[3]);
   assign pout= p[0]& p[1]& p[2]& p[3];
   
endmodule
//Ivan Castellanos

module multi (P, A, B);

   input [7:0] A;
   input [7:0] B;

   output [15:0] P;

//row b0
	wire	wa10,wa20,wa30,wa40,wa50,wa60,wn70;

//row b1
	wire	wmhc01,wmhc11,wmhc21,wmhc31,wmhc41,wmhc51,wmhc61;
	wire	wmhs11,wmhs21,wmhs31,wmhs41,wmhs51,wmhs61,wn71;

//row b2
	wire	wmfc02,wmfc12,wmfc22,wmfc32,wmfc42,wmfc52,wmfc62;
	wire	wmfs12,wmfs22,wmfs32,wmfs42,wmfs52,wmfs62,wn72;

//row b3
	wire	wmfc03,wmfc13,wmfc23,wmfc33,wmfc43,wmfc53,wmfc63;
	wire	wmfs13,wmfs23,wmfs33,wmfs43,wmfs53,wmfs63,wn73;

//row b4
	wire	wmfc04,wmfc14,wmfc24,wmfc34,wmfc44,wmfc54,wmfc64;
	wire	wmfs14,wmfs24,wmfs34,wmfs44,wmfs54,wmfs64,wn74;

//row b5
	wire	wmfc05,wmfc15,wmfc25,wmfc35,wmfc45,wmfc55,wmfc65;
	wire	wmfs15,wmfs25,wmfs35,wmfs45,wmfs55,wmfs65,wn75;

//row b6
	wire	wmfc06,wmfc16,wmfc26,wmfc36,wmfc46,wmfc56,wmfc66;
	wire	wmfs16,wmfs26,wmfs36,wmfs46,wmfs56,wmfs66,wn76;

//row b7
	wire	wnmfc07,wnmfc17,wnmfc27,wnmfc37,wnmfc47,wnmfc57,wnmfc67;
	wire	wnmfs17,wnmfs27,wnmfs37,wnmfs47,wnmfs57,wnmfs67,wa77;

//row b8
	wire	wfac08,wfac18,wfac28,wfac38,wfac48,wfac58,wfac68;

//Row bo Implementation

	and	a00(P[0] , A[0], B[0]);
	and	a10(wa10 ,A[1], B[0]);
	and	a20(wa20 ,A[2], B[0]);
	and	a30(wa30 ,A[3], B[0]);
	and	a40(wa40 ,A[4], B[0]);
	and	a50(wa50 ,A[5], B[0]);
	and	a60(wa60 ,A[6], B[0]);
	nand	n70(wn70 ,A[7], B[0]);

//Row b1

	MHA     mha01(.Sum(P[1]), .Cout(wmhc01), .A(A[0]), .B(B[1]), .Sin(wa10));
	MHA     mha11(.Sum(wmhs11), .Cout(wmhc11), .A(A[1]), .B(B[1]), .Sin(wa20));
	MHA     mha21(.Sum(wmhs21), .Cout(wmhc21), .A(A[2]), .B(B[1]), .Sin(wa30));
	MHA     mha31(.Sum(wmhs31), .Cout(wmhc31), .A(A[3]), .B(B[1]), .Sin(wa40));
	MHA     mha41(.Sum(wmhs41), .Cout(wmhc41), .A(A[4]), .B(B[1]), .Sin(wa50));
	MHA     mha51(.Sum(wmhs51), .Cout(wmhc51), .A(A[5]), .B(B[1]), .Sin(wa60));
	MHA     mha61(.Sum(wmhs61), .Cout(wmhc61), .A(A[6]), .B(B[1]), .Sin(wn70));
	nand	n71(wn71, A[7], B[1]);

//Row b2

	MFA 	mfa02(.Sum(P[2]), .Cout(wmfc02), .A(A[0]), .B(B[2]), .Sin(wmhs11), .Cin(wmhc01));
	MFA 	mfa12(.Sum(wmfs12), .Cout(wmfc12), .A(A[1]), .B(B[2]), .Sin(wmhs21), .Cin(wmhc11));
	MFA 	mfa22(.Sum(wmfs22), .Cout(wmfc22), .A(A[2]), .B(B[2]), .Sin(wmhs31), .Cin(wmhc21));
	MFA 	mfa32(.Sum(wmfs32), .Cout(wmfc32), .A(A[3]), .B(B[2]), .Sin(wmhs41), .Cin(wmhc31));
	MFA 	mfa42(.Sum(wmfs42), .Cout(wmfc42), .A(A[4]), .B(B[2]), .Sin(wmhs51), .Cin(wmhc41));
	MFA 	mfa52(.Sum(wmfs52), .Cout(wmfc52), .A(A[5]), .B(B[2]), .Sin(wmhs61), .Cin(wmhc51));
	MFA 	mfa62(.Sum(wmfs62), .Cout(wmfc62), .A(A[6]), .B(B[2]), .Sin(wn71), .Cin(wmhc61));
	nand	n72(wn72, A[7], B[2]);

//Row b3

	MFA 	mfa03(.Sum(P[3]), .Cout(wmfc03), .A(A[0]), .B(B[3]), .Sin(wmfs12), .Cin(wmfc02));
	MFA 	mfa13(.Sum(wmfs13), .Cout(wmfc13), .A(A[1]), .B(B[3]), .Sin(wmfs22), .Cin(wmfc12));
	MFA 	mfa23(.Sum(wmfs23), .Cout(wmfc23), .A(A[2]), .B(B[3]), .Sin(wmfs32), .Cin(wmfc22));
	MFA 	mfa33(.Sum(wmfs33), .Cout(wmfc33), .A(A[3]), .B(B[3]), .Sin(wmfs42), .Cin(wmfc32));
	MFA 	mfa43(.Sum(wmfs43), .Cout(wmfc43), .A(A[4]), .B(B[3]), .Sin(wmfs52), .Cin(wmfc42));
	MFA 	mfa53(.Sum(wmfs53), .Cout(wmfc53), .A(A[5]), .B(B[3]), .Sin(wmfs62), .Cin(wmfc52));
	MFA 	mfa63(.Sum(wmfs63), .Cout(wmfc63), .A(A[6]), .B(B[3]), .Sin(wn72), .Cin(wmfc62));
	nand	n73(wn73, A[7], B[3]);
	
//Row b4

	MFA 	mfa04(.Sum(P[4]), .Cout(wmfc04), .A(A[0]), .B(B[4]), .Sin(wmfs13), .Cin(wmfc03));
	MFA 	mfa14(.Sum(wmfs14), .Cout(wmfc14), .A(A[1]), .B(B[4]), .Sin(wmfs23), .Cin(wmfc13));
	MFA 	mfa24(.Sum(wmfs24), .Cout(wmfc24), .A(A[2]), .B(B[4]), .Sin(wmfs33), .Cin(wmfc23));
	MFA 	mfa34(.Sum(wmfs34), .Cout(wmfc34), .A(A[3]), .B(B[4]), .Sin(wmfs43), .Cin(wmfc33));
	MFA 	mfa44(.Sum(wmfs44), .Cout(wmfc44), .A(A[4]), .B(B[4]), .Sin(wmfs53), .Cin(wmfc43));
	MFA 	mfa54(.Sum(wmfs54), .Cout(wmfc54), .A(A[5]), .B(B[4]), .Sin(wmfs63), .Cin(wmfc53));
	MFA 	mfa64(.Sum(wmfs64), .Cout(wmfc64), .A(A[6]), .B(B[4]), .Sin(wn73), .Cin(wmfc63));
	nand	n74(wn74, A[7], B[4]);
	
//Row b5

	MFA 	mfa05(.Sum(P[5]), .Cout(wmfc05), .A(A[0]), .B(B[5]), .Sin(wmfs14), .Cin(wmfc04));
	MFA 	mfa15(.Sum(wmfs15), .Cout(wmfc15), .A(A[1]), .B(B[5]), .Sin(wmfs24), .Cin(wmfc14));
	MFA 	mfa25(.Sum(wmfs25), .Cout(wmfc25), .A(A[2]), .B(B[5]), .Sin(wmfs34), .Cin(wmfc24));
	MFA 	mfa35(.Sum(wmfs35), .Cout(wmfc35), .A(A[3]), .B(B[5]), .Sin(wmfs44), .Cin(wmfc34));
	MFA 	mfa45(.Sum(wmfs45), .Cout(wmfc45), .A(A[4]), .B(B[5]), .Sin(wmfs54), .Cin(wmfc44));
	MFA 	mfa55(.Sum(wmfs55), .Cout(wmfc55), .A(A[5]), .B(B[5]), .Sin(wmfs64), .Cin(wmfc54));
	MFA 	mfa65(.Sum(wmfs65), .Cout(wmfc65), .A(A[6]), .B(B[5]), .Sin(wn74), .Cin(wmfc64));
	nand	n75(wn75, A[7], B[5]);
	
//Row b6

	MFA 	mfa06(.Sum(P[6]), .Cout(wmfc06), .A(A[0]), .B(B[6]), .Sin(wmfs15), .Cin(wmfc05));
	MFA 	mfa16(.Sum(wmfs16), .Cout(wmfc16), .A(A[1]), .B(B[6]), .Sin(wmfs25), .Cin(wmfc15));
	MFA 	mfa26(.Sum(wmfs26), .Cout(wmfc26), .A(A[2]), .B(B[6]), .Sin(wmfs35), .Cin(wmfc25));
	MFA 	mfa36(.Sum(wmfs36), .Cout(wmfc36), .A(A[3]), .B(B[6]), .Sin(wmfs45), .Cin(wmfc35));
	MFA 	mfa46(.Sum(wmfs46), .Cout(wmfc46), .A(A[4]), .B(B[6]), .Sin(wmfs55), .Cin(wmfc45));
	MFA 	mfa56(.Sum(wmfs56), .Cout(wmfc56), .A(A[5]), .B(B[6]), .Sin(wmfs65), .Cin(wmfc55));
	MFA 	mfa66(.Sum(wmfs66), .Cout(wmfc66), .A(A[6]), .B(B[6]), .Sin(wn75), .Cin(wmfc65));
	nand	n76(wn76, A[7], B[6]);

//Row b7

	NMFA 	nmfa07(.Sum(P[7]), .Cout(wnmfc07), .A(A[0]), .B(B[7]), .Sin(wmfs16), .Cin(wmfc06));
	NMFA 	nmfa17(.Sum(wnmfs17), .Cout(wnmfc17), .A(A[1]), .B(B[7]), .Sin(wmfs26), .Cin(wmfc16));
	NMFA 	nmfa27(.Sum(wnmfs27), .Cout(wnmfc27), .A(A[2]), .B(B[7]), .Sin(wmfs36), .Cin(wmfc26));
	NMFA 	nmfa37(.Sum(wnmfs37), .Cout(wnmfc37), .A(A[3]), .B(B[7]), .Sin(wmfs46), .Cin(wmfc36));
	NMFA 	nmfa47(.Sum(wnmfs47), .Cout(wnmfc47), .A(A[4]), .B(B[7]), .Sin(wmfs56), .Cin(wmfc46));
	NMFA 	nmfa57(.Sum(wnmfs57), .Cout(wnmfc57), .A(A[5]), .B(B[7]), .Sin(wmfs66), .Cin(wmfc56));
	NMFA 	nmfa67(.Sum(wnmfs67), .Cout(wnmfc67), .A(A[6]), .B(B[7]), .Sin(wn76), .Cin(wmfc66));
	and	a77(wa77, A[7], B[7]);

//Row b8

	FA 	fa08(.Sum(P[8]), .Cout(wfac08), .A(wnmfc07), .B(wnmfs17), .Cin(1'b1));
	FA 	fa18(.Sum(P[9]), .Cout(wfac18), .A(wnmfc17), .B(wnmfs27), .Cin(wfac08));
	FA 	fa28(.Sum(P[10]), .Cout(wfac28), .A(wnmfc27), .B(wnmfs37), .Cin(wfac18));
	FA 	fa38(.Sum(P[11]), .Cout(wfac38), .A(wnmfc37), .B(wnmfs47), .Cin(wfac28));
	FA 	fa48(.Sum(P[12]), .Cout(wfac48), .A(wnmfc47), .B(wnmfs57), .Cin(wfac38));
	FA 	fa58(.Sum(P[13]), .Cout(wfac58), .A(wnmfc57), .B(wnmfs67), .Cin(wfac48));
	FA 	fa68(.Sum(P[14]), .Cout(wfac68), .A(wnmfc67), .B(wa77), .Cin(wfac58));

	not	inv1(P[15], wfac68);

endmodule // multi
// 16-Bit Multiply Add Unit, test design for Standard Cell/Custom Design
// F = Accumulation ( A * B )
// Author: Ivan Castellanos
// email: ivan.castellanos@okstate.edu
// VLSI Computer Architecture Research Group,
// Oklahoma Stata University

module multiplyadd(result, a, b, reset, clk);

   output [16:0] result;
   input  [7:0] a;
   input  [7:0] b;
   input  reset;
   input  clk;
   
   wire [15:0] multiplication;
   wire [16:0] sum;

// Custom cell block:
   multi multi_module(multiplication, a, b);

   cla16 cla16_module(sum, multiplication, result[15:0]);

// Output register is 17-bits long to include Carry out in the result.
   dffr_17 accu_output(result, sum, clk, reset);

endmodule
