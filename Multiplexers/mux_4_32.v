module mux_4_32(out, select, in0, in1, in2, in3);
    input [1:0] select;
    input [31:0] in0, in1, in2, in3;
    output [31:0] out;
    wire [31:0] mux0, mux1;

    mux_2_32 first_top(mux0, select[0], in0, in1);
    mux_2_32 first_bottom(mux1, select[0], in2, in3);
    
    mux_2_32 last(out, select[1], mux0, mux1);

endmodule