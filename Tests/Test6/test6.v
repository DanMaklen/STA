module test5(a, b, clk);
  input [2:0] a;
  input clk;
  output b;
  wire [6:0] c;
  AND2X1 _1_(
    .A(a[0]),
    .B(a[1]),
    .Y(c[0])
  );
  OR2X1 _2_(
    .A(c[0]),
    .B(a[1]),
    .Y(c[1])
  );
  INVX1 _3_(
    .A(c[0]),
    .Y(c[2])
  );
  DFFPOSX1 _4FF_(
    .D(c[2]),
    .CLK(clk),
    .Q(c[3])
  );
  AND2X1 _5_(
    .A(c[5]),
    .B(c[3]),
    .Y(c[4])
  );
  DFFPOSX1 _6FF_(
    .D(c[4]),
    .CLK(clk),
    .Q(c[5])
  );
  NOR2X1 _7_(
    .A(c[5]),
    .B(c[1]),
    .Y(c[6])
  );
  AND2X1 _8_(
    .A(c[6]),
    .B(c[6]),
    .Y(b)
  );
endmodule
