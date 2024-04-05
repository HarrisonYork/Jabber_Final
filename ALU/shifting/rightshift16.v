module rightshift16( data_result, unshifted, ctrl);
    input [31:0] unshifted;
    input ctrl;

    output [31:0] data_result;

    wire [31:0] shifted;

    assign shifted[0] = unshifted[16];
    assign shifted[1] = unshifted[17];
    assign shifted[2] = unshifted[18];
    assign shifted[3] = unshifted[19];
    assign shifted[4] = unshifted[20];
    assign shifted[5] = unshifted[21];
    assign shifted[6] = unshifted[22];
    assign shifted[7] = unshifted[23];
    assign shifted[8] = unshifted[24];
    assign shifted[9] = unshifted[25];
    assign shifted[10] = unshifted[26];
    assign shifted[11] = unshifted[27];
    assign shifted[12] = unshifted[28];
    assign shifted[13] = unshifted[29];
    assign shifted[14] = unshifted[30];
    assign shifted[15] = unshifted[31];
    assign shifted[31] = unshifted[31];
    assign shifted[30] = unshifted[31];
    assign shifted[29] = unshifted[31];
    assign shifted[28] = unshifted[31];
    assign shifted[27] = unshifted[31];
    assign shifted[26] = unshifted[31];
    assign shifted[25] = unshifted[31];
    assign shifted[24] = unshifted[31];
    assign shifted[23] = unshifted[31];
    assign shifted[22] = unshifted[31];
    assign shifted[21] = unshifted[31];
    assign shifted[20] = unshifted[31];
    assign shifted[19] = unshifted[31];
    assign shifted[18] = unshifted[31];
    assign shifted[17] = unshifted[31];
    assign shifted[16] = unshifted[31];

    mux_2_32 mux(data_result, ctrl, unshifted, shifted);

endmodule