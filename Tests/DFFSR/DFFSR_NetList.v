/* Generated by Yosys 0.5 (git sha1 c3c9fbf, gcc 4.9.2-10ubuntu5 -O2 -fstack-protector-strong -fPIC -Os) */

(* src = "DFF.v:1" *)
module DFFR(D, clk, rst, Q, Qbar);
  (* src = "DFF.v:2" *)
  wire _0_;
  (* src = "DFF.v:2" *)
  wire _1_;
  wire _2_;
  wire _3_;
  (* src = "DFF.v:1" *)
  input D;
  (* src = "DFF.v:1" *)
  output Q;
  (* src = "DFF.v:1" *)
  output Qbar;
  (* src = "DFF.v:1" *)
  input clk;
  (* src = "DFF.v:1" *)
  input rst;
  INVX1 _4_ (
    .A(rst),
    .Y(_2_)
  );
  NAND2X1 _5_ (
    .A(D),
    .B(_2_),
    .Y(_1_)
  );
  INVX1 _6_ (
    .A(D),
    .Y(_3_)
  );
  NOR2X1 _7_ (
    .A(rst),
    .B(_3_),
    .Y(_0_)
  );
  DFFPOSX1 _8_ (
    .CLK(clk),
    .D(_0_),
    .Q(Q)
  );
  DFFPOSX1 _9_ (
    .CLK(clk),
    .D(_1_),
    .Q(Qbar)
  );
endmodule
