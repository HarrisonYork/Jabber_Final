module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY, muldiv_status, write_div);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result, muldiv_status;
    output data_exception, data_resultRDY, write_div;

    wire [31:0] A_reg, B_reg;
    register holdA(clock, ctrl_DIV, data_operandA, A_reg, zero);
    register holdB(clock, ctrl_DIV, data_operandB, B_reg, zero);

    wire [31:0] read_A, read_B;
    mux_2_32 mux_A(read_A, ctrl_DIV, A_reg, data_operandA);
    mux_2_32 mux_B(read_B, ctrl_DIV, B_reg, data_operandB);

    wire [31:0] mult, div, div_unsigned;
    wire [31:0] remainder, remainder_unsigned, r_flip;

    wire zero, one, ovfA, ovfB, ovfDiv, ovfR;
    assign zero = 1'b0;
    assign one = 1'b1;

    wire [31:0] zero_32;
    assign zero_32[31:0] = 32'b0;

    wire [31:0] flip_A, flip_B, flip_div;
    adder add_flip_a(flip_A, zero_32, read_A, ovfA, one); //data_result, data_operandA, data_operandB, overflow, c0);
    adder add_flip_b(flip_B, zero_32, read_B, ovfB, one);

    wire [31:0] operandA, operandB;
    mux_2_32 choose_A(operandA, read_A[31], read_A, flip_A);
    mux_2_32 choose_B(operandB, read_B[31], read_B, flip_B);

    wire div_exception, mult_exception, div_rdy, mult_rdy;
    
    wallacetree_32 mult_(mult, mult_exception, read_A, read_B, zero, ctrl_MULT, clock, mult_rdy);

    divider div_(div_unsigned, operandA, operandB, ctrl_DIV, clock, div_exception, div_rdy, remainder_unsigned, write_div); // (result, A, B, ctrl_DIV, clock, exception, ready);

    wire select_div;
    assign select_div = read_A[31] ^ read_B[31];
    mux_2_32 choose_div(div, select_div, div_unsigned, flip_div);
    adder add_flip_div(flip_div, zero_32, div_unsigned, ovfDiv, one);

    
    mux_2_32 choose_r(remainder, read_A[31], remainder_unsigned, r_flip);
    adder add_flip_r(r_flip, zero_32, remainder_unsigned, ovfR, one);

    wire operation;
    dffe hold_operation(operation, ctrl_MULT, ctrl_MULT | ctrl_DIV, one, zero);

    wire [31:0] dex, mex, md_zeros, m_mux, d_mux;
    assign mex[31:0] = 32'd4;
    assign dex[31:0] = 32'd5;
    assign md_zeros[31:0] = 32'd0;
    
    mux_2_32 operation_mux(data_result, operation, div, mult);
    mux_2_1 exception_mux(data_exception, operation, div_exception, mult_exception);
    mux_2_1 ready_mux(data_resultRDY, operation, div_rdy, mult_rdy);

    mux_2_32 md_m_mux(m_mux, mult_exception, md_zeros, mex);
    mux_2_32 md_d_mux(d_mux, div_exception, md_zeros, dex);
    mux_2_32 md_md_mux(muldiv_status, operation, d_mux, m_mux);

endmodule