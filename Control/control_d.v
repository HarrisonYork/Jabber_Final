module control_d(instruction, switch_B, select_PC_T, jal, select_rstatus);
    input [31:0] instruction;

    output switch_B, add_imm, select_PC_T, jal, select_rstatus;
    
    wire [4:0] opcode;
    assign opcode[4:0] = instruction[31:27];

    wire [31:0] inum;
    wire enable;
    assign enable = 1'b1;
    decoder control_decode(inum, opcode, enable);

    assign switch_B = inum[2] | inum[6] | inum[7] | inum[8] | inum[4];
    assign select_rstatus = inum[22];
    assign select_PC_T = inum[1] | inum[3];
    assign jal = inum[3];
    


endmodule