module test4(a, b, clk);
  input [1:0] a;
  input clk;
  output b;
  wire [5:0] c;
  NAND2X1 _1_(
    .A(a[0]),
    .B(a[1]),
    .Y(c[0])
  );
  INVX1 _2_(
    .A(c[0]),
    .Y(c[1])
  );
  DFFPOSX1 _3FF_(
    .D(c[1]),
    .CLK(clk),
    .Q(c[2])
  );
  AND2X1 _4_(
    .A(c[2]),
    .B(c[1]),
    .Y(c[3])
  );
  OR2X1 _5_(
    .A(c[5]),
    .B(c[3]),
    .Y(c[4])
  );
  DFFPOSX1 _6FF_(
    .D(c[4]),
    .CLK(clk),
    .Q(c[5])
  );
  INVX1 _7_(
    .A(c[5]),
    .Y(b)
  );
endmodule
