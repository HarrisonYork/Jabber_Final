module alu(ALU_out, operand_A, operand_B, ALUop, shift_amount, clock, overflow, notEqual, lessThan, addi_signal, ALU_exception, mult_ready);
    input [31:0] operand_A, operand_B;
    input [4:0] ALUop, shift_amount;
    input clock, addi_signal;

    output [31:0] ALU_out, overflow;
    output notEqual, lessThan, ALU_exception, mult_ready;


    wire addsub, add_exception, sub_exception;
    wire [31:0] add_out, sub_out;
    assign addsub = 1'b0;
    adder ADD(add_out, operand_A, operand_B, add_exception, addsub); 
    adder SUB(sub_out, operand_A, operand_B, sub_exception, !addsub); 

    wire [31:0] and_out, or_out, sll_out, sra_out;
    and_ AND(and_out, operand_A, operand_B);
    or_ OR(or_out, operand_A, operand_B);
    leftshift SLL(sll_out, operand_A, shift_amount);
    rightshift SRA(sra_out, operand_A, shift_amount);

    wire mul, div, muldiv_exception, muldiv_ready;
    wire [31:0] muldiv_out;
    assign mul = !ALUop[0];
    //always multiply because one cycle operation
    wallacetree_32 wt_32(muldiv_out, muldiv_exception, operand_A, operand_B, addsub, mul, clock, muldiv_ready);

    assign mult_ready = muldiv_ready;

    mux_8_32 mux_alu_out(ALU_out, ALUop[2:0], add_out, sub_out, and_out, or_out, sll_out, sra_out, muldiv_out, muldiv_out);

    
    //control outputs
    isnotequal is_ne(notEqual, sub_out);

    // b less than a due to register switch
    assign lessThan = ((!operand_A[31] & operand_B[31]) | //a +, b -
                    (!operand_A[31] & !operand_B[31] & !sub_out[31]) |  //a +, b +, sub +
                    (operand_A[31] & operand_B[31] & !sub_out[31])) & // a -, b -, sub +
                    !(operand_A[31] & !operand_B[31]) & notEqual; // a -, b +

    //overflow
    wire alu_op_b0;
    assign alu_op_b0 = ALUop[0];
    
    wire [31:0] rstatus_1, rstatus_2, rstatus_3, rstatus_4, m_zeros, overflow_t, m_add, m_addi, m_sub, m_mul, overflow_add;
    assign m_zeros[31:0] = 32'd0;
    assign rstatus_1[31:0] = 32'd1;
    assign rstatus_2[31:0] = 32'd2;
    assign rstatus_3[31:0] = 32'd3;
    assign rstatus_4[31:0] = 32'd4;

    mux_2_32 mux_overflow1(m_add, add_exception, m_zeros, rstatus_1);
    mux_2_32 mux_overflow2(m_addi, add_exception, m_zeros, rstatus_2);
    mux_2_32 mux_overflow3(m_sub, sub_exception, m_zeros, rstatus_3);
    mux_2_32 mux_overflow4(m_mul, muldiv_exception, m_zeros, rstatus_4);

    mux_2_32 mux_ovf_4(overflow_t, alu_op_b0, m_add, m_sub);
    mux_2_32 mux_ovf_addaddisub(overflow_add, addi_signal, overflow_t, m_addi);

    wire mulselect;
    assign mulselect = ALUop[2] & ALUop[1] & !ALUop[0];
    mux_2_32 mux_final_ovf(overflow, mulselect, overflow_add, m_mul);

    wire [31:0] alunum;
    decoder control_decode_alunum(alunum, ALUop, !addsub);

    assign ALU_exception = (add_exception & alunum[0]) | (sub_exception & alunum[1]) | (muldiv_exception & alunum[6]);



endmodule