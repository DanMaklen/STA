module booth_encoder(mr, md, x, z);
  wire _0_;
  wire _1_;
  input [3:0] md;
  input [3:0] mr;
  output [3:0] x;
  output [3:0] z;
  INVX1 _2_ (
    .A(md[1]),
    .Y(_0_)
  );
  NOR2X1 _3_ (
    .A(md[0]),
    .B(_0_),
    .Y(x[1])
  );
  XOR2X1 _4_ (
    .A(md[0]),
    .B(md[1]),
    .Y(z[1])
  );
  AND2X2 _5_ (
    .A(_0_),
    .B(md[2]),
    .Y(x[2])
  );
  XOR2X1 _6_ (
    .A(md[1]),
    .B(md[2]),
    .Y(z[2])
  );
  INVX1 _7_ (
    .A(md[3]),
    .Y(_1_)
  );
  NOR2X1 _8_ (
    .A(md[2]),
    .B(_1_),
    .Y(x[3])
  );
  XOR2X1 _9_ (
    .A(md[2]),
    .B(md[3]),
    .Y(z[3])
  );
  assign x[0] = md[0];
  assign z[0] = md[0];
endmodule
