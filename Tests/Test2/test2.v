module test2(a, b, clk);
  input [4:0] a;
  input clk;
  output [1:0] b;
  wire [8:0] c;
  DFFPOSX1 _1FF_(
    .D(a[0]),
    .CLK(clk),
    .Q(c[0])
  );
  INVX1 _2_(
    .A(a[1]),
    .Y(c[1])
  );
  NAND2X1 _3_(
    .A(a[3]),
    .B(a[4]),
    .Y(c[2])
  );
  AND2X1 _4_(
    .A(c[1]),
    .B(a[2]),
    .Y(c[3])
  );
  OR2X1 _5_(
    .A(c[3]),
    .B(c[2]),
    .Y(c[4])
  );
  INVX1 _6_(
    .A(c[0]),
    .Y(c[5])
  );
  DFFPOSX1 _7FF_(
    .D(c[4]),
    .CLK(clk),
    .Q(c[6])
  );
  NOR2X1 _8_(
    .A(c[5]),
    .B(c[6]),
    .Y(c[7])
  );
  DFFPOSX1 _9FF_(
    .D(c[7]),
    .CLK(clk),
    .Q(c[8])
  );
  AND2X1 _10_(
    .A(c[5]),
    .B(c[8]),
    .Y(b[0])
  );
  INVX1 _11_(
    .A(c[8]),
    .Y(b[1])
  );
endmodule
