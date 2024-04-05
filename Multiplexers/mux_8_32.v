module mux_8_32(out, select, in0, in1, in2, in3, in4, in5, in6, in7);
    input [2:0] select;
    input [31:0] in0, in1, in2, in3, in4, in5, in6, in7;
    output [31:0] out;
    wire [31:0] mux0, mux1;

    mux_4_32 first_top(mux0, select[1:0], in0, in1, in2, in3);
    mux_4_32 first_bottom(mux1, select[1:0], in4, in5, in6, in7);
    
    mux_2_32 last(out, select[2], mux0, mux1);
endmodule