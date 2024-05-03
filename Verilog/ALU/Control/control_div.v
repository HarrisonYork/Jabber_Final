module control_div(instruction, instruction_X, cpu_clock, ctrl_d, div_rdy, stall, outside_stall);
    input cpu_clock, ctrl_d, div_rdy, outside_stall;
    input [31:0] instruction, instruction_X;

    output stall;

    wire [4:0] opcode, ALUop;
    assign opcode[4:0] = instruction[31:27];
    assign ALUop[4:0] = instruction[6:2];

    wire [31:0] inum, alunum;
    wire enable;
    assign enable = 1'b1;
    decoder decode_opcode(inum, opcode, enable);
    decoder decode_aluop(alunum, ALUop, enable);

    wire [4:0] opcodeX, ALUopX;
    assign opcodeX[4:0] = instruction_X[31:27];
    assign ALUopX[4:0] = instruction_X[6:2];

    wire [31:0] inumX, alunumX;
    decoder decode_opcodeX(inumX, opcodeX, enable);
    decoder decode_aluopX(alunumX, ALUopX, enable);

    wire fake_stall, reached33;
    //(q, t, clk, en, clr);
    tff staller(stall, (ctrl_d & inumX[0] & alunumX[7]) | (reached33 & inum[0] & alunum[7] & outside_stall), cpu_clock, enable, !enable);

    wire [5:0] stall_count;
    count_64 countStall(stall_count, cpu_clock, ctrl_d);
    assign reached33 = stall_count[5] && !stall_count[4] && !stall_count[3] && !stall_count[2] && !stall_count[1] && stall_count[0];


endmodule