module adderblock(data_result, P0, G0, data_operandA, data_operandB, c0, overflow);
    input [7:0] data_operandA, data_operandB;
    input c0;

    output [7:0] data_result;
    output P0, G0;
    output overflow;

    wire c0, c1, c2, c3, c4, c5, c6, c7;

    wire p0, p1, p2, p3, p4, p5, p6, p7;
    wire g0, g1, g2, g3, g4, g5, g6, g7;

    wire p0c0, p1p0c0, p2p1p0c0, p3p2p1p0c0, p4p3p2p1p0c0, p5p4p3p2p1p0c0, p6p5p4p3p2p1p0c0, p7p6p5p4p3p2p1p0c0;
    wire p1g0, p2p1g0, p3p2p1g0, p4p3p2p1g0, p5p4p3p2p1g0, p6p5p4p3p2p1g0, p7p6p5p4p3p2p1g0;
    wire p2g1, p3p2g1, p4p3p2g1, p5p4p3p2g1, p6p5p4p3p2g1, p7p6p5p4p3p2g1;
    wire p3g2, p4p3g2, p5p4p3g2, p6p5p4p3g2, p7p6p5p4p3g2;
    wire p4g3, p5p4g3, p6p5p4g3, p7p6p5p4g3;
    wire p5g4, p6p5g4, p7p6p5g4;
    wire p6g5, p7p6g5;
    wire p7g6;

    // level 1 - propogate and generate
    and ANDg0(g0, data_operandA[0], data_operandB[0]);
    and ANDg1(g1, data_operandA[1], data_operandB[1]);
    and ANDg2(g2, data_operandA[2], data_operandB[2]);
    and ANDg3(g3, data_operandA[3], data_operandB[3]);
    and ANDg4(g4, data_operandA[4], data_operandB[4]);
    and ANDg5(g5, data_operandA[5], data_operandB[5]);
    and ANDg6(g6, data_operandA[6], data_operandB[6]);
    and ANDg7(g7, data_operandA[7], data_operandB[7]);

    or ORp0(p0, data_operandA[0], data_operandB[0]);
    or ORp1(p1, data_operandA[1], data_operandB[1]);
    or ORp2(p2, data_operandA[2], data_operandB[2]);
    or ORp3(p3, data_operandA[3], data_operandB[3]);
    or ORp4(p4, data_operandA[4], data_operandB[4]);
    or ORp5(p5, data_operandA[5], data_operandB[5]);
    or ORp6(p6, data_operandA[6], data_operandB[6]);
    or ORp7(p7, data_operandA[7], data_operandB[7]);

    // level 2 - products (ANDs)
    and ANDp0c0(p0c0, p0, c0);
    and ANDp1p0c0(p1p0c0, p1, p0, c0);
    and ANDp2p1p0c0(p2p1p0c0, p2, p1, p0, c0);
    and ANDp3p2p1p0c0(p3p2p1p0c0, p3, p2, p1, p0, c0);
    and ANDp4p3p2p1p0c0(p4p3p2p1p0c0, p4, p3, p2, p1, p0, c0);
    and ANDp5p4p3p2p1p0c0(p5p4p3p2p1p0c0, p5, p4, p3, p2, p1, p0, c0);
    and ANDp6p5p4p3p2p1p0c0(p6p5p4p3p2p1p0c0, p6, p5, p4, p3, p2, p1, p0, c0);
    and ANDp7p6p5p4p3p2p1p0c0(p7p6p5p4p3p2p1p0c0, p7, p6, p5, p4, p3, p2, p1, p0, c0);

    and ANDp1g0(p1g0, p1, g0);
    and ANDp2p1g0(p2p1g0, p2, p1, g0);
    and ANDp3p2p1g0(p3p2p1g0, p3, p2, p1, g0);
    and ANDp4p3p2p1g0(p4p3p2p1g0, p4, p3, p2, p1, g0);
    and ANDp5p4p3p2p1g0(p5p4p3p2p1g0, p5, p4, p3, p2, p1, g0);
    and ANDp6p5p4p3p2p1g0(p6p5p4p3p2p1g0, p6, p5, p4, p3, p2, p1, g0);
    and ANDp7p6p5p4p3p2p1g0(p7p6p5p4p3p2p1g0, p7, p6, p5, p4, p3, p2, p1, g0);

    and ANDp2g1(p2g1, p2, g1);
    and ANDp3p2g1(p3p2g1, p3, p2, g1);
    and ANDp4p3p2g1(p4p3p2g1, p4, p3, p2, g1);
    and ANDp5p4p3p2g1(p5p4p3p2g1, p5, p4, p3, p2, g1);
    and ANDp6p5p4p3p2g1(p6p5p4p3p2g1, p6, p5, p4, p3, p2, g1);
    and ANDp7p6p5p4p3p2g1(p7p6p5p4p3p2g1, p7, p6, p5, p4, p3, p2, g1);

    and ANDp3g2(p3g2, p3, g2);
    and ANDp4p3g2(p4p3g2, p4, p3, g2);
    and ANDp5p4p3g2(p5p4p3g2, p5, p4, p3, g2);
    and ANDp6p5p4p3g2(p6p5p4p3g2, p6, p5, p4, p3, g2);
    and ANDp7p6p5p4p3g2(p7p6p5p4p3g2, p7, p6, p5, p4, p3, g2);

    and ANDp4g3(p4g3, p4, g3);
    and ANDp5p4g3(p5p4g3, p5, p4, g3);
    and ANDp6p5p4g3(p6p5p4g3, p6, p5, p4, g3);
    and ANDp7p6p5p4g3(p7p6p5p4g3, p7, p6, p5, p4, g3);

    and ANDp5g4(p5g4, p5, g4);
    and ANDp6p5g4(p6p5g4, p6, p5, g4);
    and ANDp7p6p5g4(p7p6p5g4, p7, p6, p5, g4);
    
    and ANDp6g5(p6g5, p6, g5);
    and ANDp7p6g5(p7p6g5, p7, p6, g5);

    and ANDp7g6(p7g6, p7, g6);
    
    // level 3 - sums of products
    or ORc1(c1, g0, p0c0);
    or ORc2(c2, g1, p1g0, p1p0c0);
    or ORc3(c3, g2, p2g1, p2p1g0, p2p1p0c0);
    or ORc4(c4, g3, p3g2, p3p2g1, p3p2p1g0, p3p2p1p0c0);
    or ORc5(c5, g4, p4g3, p4p3g2, p4p3p2g1, p4p3p2p1g0, p4p3p2p1p0c0);
    or ORc6(c6, g5, p5g4, p5p4g3, p5p4p3g2, p5p4p3p2g1, p5p4p3p2p1g0, p5p4p3p2p1p0c0);
    or ORc7(c7, g6, p6g5, p6p5g4, p6p5p4g3, p6p5p4p3g2, p6p5p4p3p2g1, p6p5p4p3p2p1g0, p6p5p4p3p2p1p0c0);

    // P0, G0 block-level output
    and ANDP0(P0, p7, p6, p5, p4, p3, p2, p1, p0);
    or ORG0(G0, g7, p7g6, p7p6g5, p7p6p5g4, p7p6p5p4g3, p7p6p5p4p3g2, p7p6p5p4p3p2g1, p7p6p5p4p3p2p1g0);

    // sum bits
    xor XORs0(data_result[0], data_operandA[0], data_operandB[0], c0);
    xor XORs1(data_result[1], data_operandA[1], data_operandB[1], c1);
    xor XORs2(data_result[2], data_operandA[2], data_operandB[2], c2);
    xor XORs3(data_result[3], data_operandA[3], data_operandB[3], c3);
    xor XORs4(data_result[4], data_operandA[4], data_operandB[4], c4);
    xor XORs5(data_result[5], data_operandA[5], data_operandB[5], c5);
    xor XORs6(data_result[6], data_operandA[6], data_operandB[6], c6);
    xor XORs7(data_result[7], data_operandA[7], data_operandB[7], c7); 

    assign overflow = c7;   

endmodule