module tff(q, t, clk, en, clr);
   input clk, en, clr;
   input t;
   output q;

    wire d;
    assign d = ((q & ~t) | (t & ~q));

    dffe diffeq(q, d, clk, en, clr);
    
   
endmodule