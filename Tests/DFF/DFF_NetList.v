/* Generated by Yosys 0.5 (git sha1 c3c9fbf, gcc 4.9.2-10ubuntu5 -O2 -fstack-protector-strong -fPIC -Os) */

(* src = "DFF.v:1" *)
module DFF(D, clk, Q);
  (* src = "DFF.v:1" *)
  input D;
  (* src = "DFF.v:1" *)
  output Q;
  (* src = "DFF.v:1" *)
  input clk;
  DFFPOSX1 _0_ (
    .CLK(clk),
    .D(D),
    .Q(Q)
  );
endmodule