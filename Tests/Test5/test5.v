module test5(a, b, clk);
  input [6:0] a;
  input clk;
  output b;
  wire [8:0] c;
  NAND2X1 _1_(
    .A(a[0]),
    .B(a[1]),
    .Y(c[0])
  );
  INVX1 _2_(
    .A(a[2]),
    .Y(c[1])
  );
  OR2X1 _3_(
    .A(a[3]),
    .B(a[4]),
    .Y(c[2])
  );
  AND2X1 _4_(
    .A(a[5]),
    .B(a[6]),
    .Y(c[3])
  );
  AND2X1 _5_(
    .A(c[0]),
    .B(c[1]),
    .Y(c[4])
  );
  OR2X1 _6_(
    .A(c[2]),
    .B(c[3]),
    .Y(c[5])
  );
  DFFPOSX1 _7FF_(
    .D(c[4]),
    .CLK(clk),
    .Q(c[6])
  );
  DFFPOSX1 _8FF_(
    .D(c[5]),
    .CLK(clk),
    .Q(c[7])
  );
  DFFPOSX1 _9FF_(
    .D(c[6]),
    .CLK(clk),
    .Q(c[8])
  );
  AND2X1 _10_(
    .A(c[8]),
    .B(c[7]),
    .Y(b)
  );
endmodule
