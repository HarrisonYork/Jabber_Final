module adder(data_result, data_operandA, data_operandB, overflow, c0);
    input [31:0] data_operandA, data_operandB;
    input c0;

    output [31:0] data_result;
    output overflow;

    wire c8, c16, c24;

    wire P0, P1, P2, P3;
    wire G0, G1, G2, G3;

    wire P0c0, P1P0c0, P2P1P0c0, P3P2P1P0c0;
    wire P1G0, P2P1G0, P3P2P1G0;
    wire P2G1, P3P2G1;
    wire P3G2;

    wire [2:0] fakeOverflow;

    wire [31:0] notb;
    not_ nb(notb, data_operandB);

    wire [31:0] trueB;

    mux_2_32 bselect(trueB, c0, data_operandB, notb);

    // block: (data_result, P0, G0, data_operandA, data_operandB, overflow, c0)
    adderblock B0(data_result[7:0], P0, G0, data_operandA[7:0],  trueB[7:0], c0, fakeOverflow[0]);

    and ANDP0c0(P0c0, P0, c0);
    or ORc8(c8, G0, P0c0);

    adderblock B1(data_result[15:8], P1, G1, data_operandA[15:8],  trueB[15:8], c8, fakeOverflow[1]);

    and ANDP1P0c0(P1P0c0, P1, P0, c0);
    and ANDP1G0(P1G0, P1, G0);
    or ORc16(c16, G1, P1G0, P1P0c0);

    adderblock B2(data_result[23:16], P2, G2, data_operandA[23:16],  trueB[23:16], c16, fakeOverflow[2]);
   
    and ANDP2P1P0c0(P2P1P0c0, P2, P1, P0, c0);
    and ANDP2P1G0(P2P1G0, P2, P1, G0);
    and ANDP2G1(P2G1, P2, G1);
    or ORc24(c24, G2, P2G1, P2P1G0, P2P1P0c0);

    wire ovf2;

    adderblock B3(data_result[31:24], P3, G3, data_operandA[31:24],  trueB[31:24], c24, ovf2);

    and ANDP3P2P1P0c0(P3P2P1P0c0, P3, P2, P1, P0, c0);
    and ANDP3P2P1G0(P3P2P1G0, P3, P2, P1, G0);
    and ANDP3P2G1(P3P2G1, P3, P2, G1);
    and ANDP3G2(P3G2, P3, G2);

    wire ovf1;
    or ORovf(ovf1, G3, P3G2, P3P2G1, P3P2P1G0, P3P2P1P0c0);

    xor ovf(overflow, ovf1, ovf2);

endmodule