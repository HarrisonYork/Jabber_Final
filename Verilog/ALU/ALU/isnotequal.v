module isnotequal(w_isnotequal, sub);
    input [31:0] sub;
    output w_isnotequal;

    wire or1, or2, or3, or4;

    or OR1(or1, sub[0], sub[1], sub[2], sub[3], sub[4], sub[5], sub[6], sub[7]);
    or OR2(or2, sub[8], sub[9], sub[10], sub[11], sub[12], sub[13], sub[14], sub[15]);
    or OR3(or3, sub[16], sub[17], sub[18], sub[19], sub[20], sub[21], sub[22], sub[23]);
    or OR4(or4, sub[24], sub[25], sub[26], sub[27], sub[28], sub[29], sub[30], sub[31]);

    or ANDout(w_isnotequal, or1, or2, or3, or4);

endmodule