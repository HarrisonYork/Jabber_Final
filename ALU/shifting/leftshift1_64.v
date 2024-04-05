module leftshift1_64( data_result, unshifted, ctrl);
    input [63:0] unshifted;
    input ctrl;

    output [63:0] data_result;

    wire [63:0] shifted;

    assign shifted[0] = 0;
    assign shifted[63:1] = unshifted[62:0];

    mux_2_64 mux(data_result, ctrl, unshifted, shifted);

endmodule