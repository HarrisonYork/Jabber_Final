module control_mem(instruction, wren);
    input [31:0] instruction;

    output wren;
    
    wire [4:0] opcode;
    assign opcode[4:0] = instruction[31:27];

    wire [31:0] inum;
    wire enable;
    assign enable = 1'b1;
    decoder control_decode(inum, opcode, enable);

    assign wren = inum[7];

endmodule