`timescale 1ns/10ps

`define COUNT 0
/* 2-input nor gate with resource counter and time delay
 */

module my_nor(y, a, b);
  output y;
  input a, b;

  reg y;
  reg v;
initial begin
//`define COUNT=`COUNT+1;
end
  always@(a,b)begin
  #2 v=a|b;

  y=~v;
end
  /* at instantiation increment the resources used */
 

  /* add 2ns inherent delay */

endmodule

/* 2-input and gate using my_nor
 */

module my_and(y, a, b);
  output y;
  input a, b;
  wire y;
  my_nor mynor1(y,~a,~b);
endmodule

/* 3-input and gate using my_and
 */

module my_and3(y, a, b, c);
  output y;
  input a, b, c;
  
  wire y;
  wire v;
  my_and myand1(v,a,b);
  my_and myand2(y,v,c);
endmodule

/* 4-input and gate using my_and
 */

module my_and4(y, a, b, c, d);
  output y;
  input a, b, c, d;
  wire y;
  wire v;
  my_and3 and3_1(v,a,b,c);
  my_and myand3(y,v,d);

endmodule

/* 2-input or gate using my_nor
 */

module my_or(y, a, b);
  output y;
  input a, b;
  wire y;
  wire v;
  my_nor mynor2(v,a,b);
  assign y=~v;
endmodule

/* 3-input or gate using my_or
 */

module my_or3(y, a, b, c);
  output y;
  input a, b, c;
  wire y;
  wire v;
  
  my_or myor1(v,a,b);
  my_or myor2(y,v,c);

endmodule

/* 4-input or gate using my_or
 */

module my_or4(y, a, b, c, d);
  output y;
  input a, b, c, d;
  wire y;
  wire v;

  my_or3 or3_1(v,a,b,c);
  my_or myor3(y,v,d);

endmodule

/* 2-input xor gate using my_nor
 */

module my_xor(y, a, b);
  output y;
  input a, b;
  wire y;
  wire v1,v2;
  my_and myand4(v1,a,~b);
  my_and myand5(v2,~a,b);
  my_or myor4(y,v1,v2);
endmodule
