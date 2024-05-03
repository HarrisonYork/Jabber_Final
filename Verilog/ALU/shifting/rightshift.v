module rightshift(data_result, data_operandA, ctrl_shiftamt);
    input [31:0] data_operandA;
    input [4:0] ctrl_shiftamt;

    output [31:0] data_result;

    wire [31:0] shift16, shift8, shift4, shift2;

    rightshift16 rs16(shift16, data_operandA, ctrl_shiftamt[4]);
    
    rightshift8 rs8(shift8, shift16, ctrl_shiftamt[3]);

    rightshift4 rs4(shift4, shift8, ctrl_shiftamt[2]);

    rightshift2 rs2(shift2, shift4, ctrl_shiftamt[1]);

    rightshift1 rs1(data_result, shift2, ctrl_shiftamt[0]);
    
endmodule