/* Generated by Yosys 0.5 (git sha1 c3c9fbf, gcc 4.9.2-10ubuntu5 -O2 -fstack-protector-strong -fPIC -Os) */

(* top =  1  *)
(* src = "mux.v:1" *)
module mux(a, b, sel, o);
  wire _0_;
  wire _1_;
  wire _2_;
  (* src = "mux.v:1" *)
  input a;
  (* src = "mux.v:1" *)
  input b;
  (* src = "mux.v:1" *)
  output o;
  (* src = "mux.v:1" *)
  input sel;
  INVX1 _3_ (
    .A(sel),
    .Y(_0_)
  );
  NAND2X1 _4_ (
    .A(a),
    .B(_0_),
    .Y(_1_)
  );
  NAND2X1 _5_ (
    .A(b),
    .B(sel),
    .Y(_2_)
  );
  NAND2X1 _6_ (
    .A(_2_),
    .B(_1_),
    .Y(o)
  );
endmodule
