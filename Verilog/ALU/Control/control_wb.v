module control_wb(instruction, wren_regfile, select_ALU_data, setx);
    input [31:0] instruction;

    output wren_regfile, select_ALU_data, setx;
    
    wire [4:0] opcode;
    assign opcode[4:0] = instruction[31:27];

    wire [31:0] inum;
    wire enable;
    assign enable = 1'b1;
    decoder control_decode(inum, opcode, enable);

    wire rtype, itype, j1type, j2type;
    assign rtype = inum[0];
    assign itype = inum[5] | inum[7] | inum[8] | inum[2] | inum[6];
    assign j1type = inum[1] | inum[3] | inum[22] | inum[21];
    assign j2type = inum[4];

    assign wren_regfile = rtype | inum[5] | inum[8] | inum[21];
    assign select_ALU_data = inum[8];

    assign setx = inum[21];

endmodule