module test1(a, b);
  input [6:0] a;
  output b;
  wire [5:0] c;
  INVX1 _1_(
    .A(a[0]),
    .Y(c[0])
  );
  AND2X1 _2_(
    .A(a[1]),
    .B(a[2]),
    .Y(c[1])
  );
  OR2X1 _3_(
    .A(a[3]),
    .B(a[4]),
    .Y(c[2])
  );
  NAND2X1 _4_(
    .A(a[5]),
    .B(a[6]),
    .Y(c[3])
  );
  OR2X1 _5_(
    .A(c[0]),
    .B(c[1]),
    .Y(c[4])
  );
  AND2X1 _6_(
    .A(c[4]),
    .B(c[2]),
    .Y(c[5])
  );
  NOR2X1 _7_(
    .A(c[5]),
    .B(c[3]),
    .Y(b)
  );
endmodule
