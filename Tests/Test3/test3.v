module test3(a, b, clk);
  input [1:0] a;
  input clk;
  output b;
  wire [2:0] c;
  AND2X1 _1_(
    .A(c[2]),
    .B(a[0]),
    .Y(c[0])
  );
  DFFPOSX1 _2FF_(
    .D(c[0]),
    .CLK(clk),
    .Q(c[1])
  );
  DFFPOSX1 _3FF_(
    .D(c[1]),
    .CLK(clk),
    .Q(c[2])
  );
  NAND2X1 _4_(
    .A(c[2]),
    .B(a[1]),
    .Y(b)
  );
endmodule
