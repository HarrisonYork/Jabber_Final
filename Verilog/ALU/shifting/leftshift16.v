module leftshift16(data_result, unshifted, ctrl);
    input [31:0] unshifted;
    input ctrl;

    output [31:0] data_result;

    wire [31:0] shifted;

    assign shifted[0] = 0;
    assign shifted[1] = 0;
    assign shifted[2] = 0;
    assign shifted[3] = 0;
    assign shifted[4] = 0;
    assign shifted[5] = 0;
    assign shifted[6] = 0;
    assign shifted[7] = 0;
    assign shifted[8] = 0;
    assign shifted[9] = 0;
    assign shifted[10] = 0;
    assign shifted[11] = 0;
    assign shifted[12] = 0;
    assign shifted[13] = 0;
    assign shifted[14] = 0;
    assign shifted[15] = 0;
    assign shifted[16] = unshifted[0];
    assign shifted[17] = unshifted[1];
    assign shifted[18] = unshifted[2];
    assign shifted[19] = unshifted[3];
    assign shifted[20] = unshifted[4];
    assign shifted[21] = unshifted[5];
    assign shifted[22] = unshifted[6];
    assign shifted[23] = unshifted[7];
    assign shifted[24] = unshifted[8];
    assign shifted[25] = unshifted[9];
    assign shifted[26] = unshifted[10];
    assign shifted[27] = unshifted[11];
    assign shifted[28] = unshifted[12];
    assign shifted[29] = unshifted[13];
    assign shifted[30] = unshifted[14];
    assign shifted[31] = unshifted[15];

    mux_2_32 mux(data_result, ctrl, unshifted, shifted);

endmodule