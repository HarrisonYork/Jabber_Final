module control(instruction, rtype, itype, j1type, j2type, bne, blt, switch_B, add_imm, jr_select, mul, div, bex);
    input [31:0] instruction;

    output rtype, itype, j1type, j2type, bne, blt, switch_B, add_imm, jr_select, mul, div, bex;
    
    wire [4:0] opcode;
    assign opcode[4:0] = instruction[31:27];

    wire [31:0] inum;
    wire enable_;
    assign enable_ = 1'b1;
    decoder control_decode(inum, opcode, enable_);

    assign rtype = inum[0];
    assign itype = inum[5] | inum[7] | inum[8] | inum[2] | inum[6];
    assign j1type = inum[1] | inum[3] | inum[22] | inum[21];
    assign j2type = inum[4];

    assign bne = inum[2];
    assign blt = inum[6];

    assign switch_B = bne | blt | inum[7] | inum[8];
    assign add_imm = inum[7] | inum[5] | inum[8];

    assign jr_select = inum[4];
    
    wire [4:0] ALUop;
    assign ALUop[4:0] = instruction[6:2];

    wire [31:0] alunum;
    decoder control_decode_alunum(alunum, ALUop, enable_);

    assign mul = alunum[6] & inum[0];
    assign div = alunum[7] & inum[0];

    assign bex = inum[22];


endmodule