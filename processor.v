/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */

module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of 
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	/* YOUR CODE STARTS HERE */

    wire not_clock;
    assign not_clock = !clock;

//////////////////////////////////////// Handling Delay  //////////////////////////////////////// 
reg [63:0] current; // Create register to count clock cycles
reg [63:0] count_till; // Create register to hold which clock cycle to count till

/* Math:
Counts to 5000 every 1 second. Counts to 5 every 1ms*/

always @(negedge clock or posedge reset) begin //make sure to insert 5 nops
    if (reset) begin
        current = 0;
        count_till = 0;
    end else begin
        current = current + 1;
        if (q_imem[31:27] == 5'b11111) begin
            count_till = current + 100000 * q_imem[26:0] + 1;  // Update count_till based on q_imem value
        end
    end
end

    //////////////////////////////////////////////////////////////////////////////// 

//Fetch
    wire [31:0] PC, pc_address, pc_address_bex, pc_address_jump, pc_address_immediate, pc_address_reset, pc_address_increment, nop, increment, PC_plus_immediate_one;
    wire enable, pc_ovf;
    assign enable = 1'b1;
    assign increment[0] = 1'b1;
    assign increment[31:1] = 31'd0;
    assign nop[31:0] = 32'd0;
    
    mux_2_32 mux_pc_address(pc_address_reset, reset, pc_address_increment, nop);
    mux_2_32 mux_pc_branch(pc_address_immediate, branch_taken, pc_address_reset, PC_plus_immediate_one);
    mux_2_32 mux_pc_jump(pc_address_jump, select_PC_T & !branch_taken, pc_address_immediate, T);
    mux_2_32 mux_bex(pc_address_bex, bex_select, pc_address_jump, T_bex);
    mux_2_32 mux_pc_jr(pc_address, jr_select & !branch_taken, pc_address_bex, OPERAND_B);
    
    register reg_pc_address(not_clock, !div_stall & !data_stall & !ALU_exception & !lw_edge_stall & !mult_stall & !stall_for_delay, pc_address, PC, reset);
    adder pc_counter(pc_address_increment, PC, increment, pc_ovf, !enable);
    adder pc_immediate_plus_one(PC_plus_immediate_one, PC_plus_immediate, increment, pc_ovf, !enable);

    // output address to instruction memory
    assign address_imem[31:0] = PC[31:0];

//Fetch/Decode
    wire [31:0] FD_PC;
    register reg_fd_pc(not_clock, !div_stall & !data_stall & !ALU_exception & !lw_edge_stall & !mult_stall & !stall_for_delay, PC, FD_PC, reset);
    
    // get instruction from imem
    wire [31:0] FD_IR, muxed_FD_IR;
    wire nop_ctrl;
    register reg_fd_ir(not_clock, !div_stall & !data_stall & !ALU_exception & !lw_edge_stall & !mult_stall & !stall_for_delay, muxed_FD_IR, FD_IR, reset);
    mux_2_32 mux_fd_ir(muxed_FD_IR, reset | branch_taken | jr_select | bex_select | select_PC_T, q_imem, nop);

//Decode

        //////////////////////////////////////// Handling Delay  //////////////////////////////////////// 
    reg stall_for_delay;

    always @(posedge clock) begin
        if (current <= count_till && FD_IR[31:27] == 5'b11111) begin
            stall_for_delay = 1'b1;
        end else begin
            stall_for_delay = 1'b0;
        end
    end

    // want to stall PC and Fetch latch, and insert nops forward
    //////////////////////////////////////////////////////////////////////////////// 
    // register(clock, inEnable, inVal, outVal, reset);
    // instruction deconstruction
    wire [4:0] opcode, reg_d, reg_s, reg_t, reg0;
    assign reg_d[4:0] = FD_IR[26:22];
    assign reg_s[4:0] = FD_IR[21:17];
    assign reg_t[4:0] = FD_IR[16:12];

    wire [31:0] T;
    assign T[31:27] = 5'd0;
    assign T[26:0] = FD_IR[26:0];
    assign reg0[4:0] = 5'd0;

    mux_2_5 mux_readRstatusA(read_A_final, select_rstatus | branch_taken, reg_s, reg0);
    assign ctrl_readRegA[4:0] = read_A_final[4:0];

    wire [4:0] read_TorD, read_B_final, read_A_final;
    mux_2_5 mux_readB(read_TorD, D_switch_B, reg_t, reg_d);
    mux_2_5 mux_readRstatus(read_B_final, select_rstatus, read_TorD, rstatus);
    assign ctrl_readRegB[4:0] = read_B_final[4:0];

    wire D_switch_B, select_PC_T, jal, select_rstatus;
    control_d D_control(FD_IR, D_switch_B, select_PC_T, jal, select_rstatus);

    //control register write (from writeback)
    wire [4:0] register_to_write, register_to_write_alu, register_to_write_jal, reg_31;
    assign reg_31[4:0] = 5'b11111;
    mux_2_5 mux_reg_jump(register_to_write_jal, jal, write_reg, reg_31);
    mux_2_5 mux_reg_ALU_status(register_to_write_alu, ALU_exception, register_to_write_jal, rstatus);
    mux_2_5 mux_reg_div_status(register_to_write, (div_ex & div_stall), register_to_write_alu, rstatus);
    assign ctrl_writeReg[4:0] = register_to_write[4:0];

    wire [31:0] data_to_write, data_to_write_jal, data_to_write_jal_mux, data_to_write_alu;
    mux_2_32 mux_data_jump(data_to_write_jal_mux, jal, W_data, data_to_write_jal);
    mux_2_32 mux_reg_ALU_data(data_to_write_alu, ALU_exception, data_to_write_jal_mux, ALU_status);
    mux_2_32 mux_reg_div_data(data_to_write, (div_ex & div_stall), data_to_write_alu, div_status);
    assign data_writeReg[31:0] = data_to_write[31:0];

    wire jal_ovf;
    adder adder_jal(data_to_write_jal, FD_PC, increment, jal_ovf, !enable);

    assign ctrl_writeEnable = wren_regfile | jal;

    //ALU bypass
    wire data_stall, fake_stall, bypass_A_W, bypass_A_M, bypass_A_X, bypass_B_W, bypass_B_M, bypass_B_X,
        to_mem_bypass, bypass_D_W, bypass_D_M, bypass_D_X, jr_bypass_mem, bypass_data_M_D,
        jr_bypass_W, jr_bypass_M, jr_bypass_X, lw_edge_stall, bypass_data_M_A, bypass_data_M_B, jal_disable_W, jal_disable_M, jal_disable_X;
    assign fake_stall = 1'b0;
    control_hazard haz_con(FD_IR, DX_IR, XM_IR, MW_IR, data_stall, 
        bypass_A_W, bypass_A_M, bypass_A_X, 
        bypass_B_W, bypass_B_M, bypass_B_X,
        to_mem_bypass,
        bypass_D_W, bypass_D_M, bypass_D_X,
        lw_edge_stall, bypass_data_M_A, bypass_data_M_B, bypass_data_M_D,
        jal_disable_W, jal_disable_M, jal_disable_X);

    wire [31:0] bypassed_A, mux_A_bypass_W, mux_A_bypass_M, mux_A_bypass_MEM;
    mux_2_32 bypassAfromW(mux_A_bypass_W, bypass_A_W, data_readRegA, W_data);
    mux_2_32 bypassAfromM(mux_A_bypass_M, bypass_A_M, mux_A_bypass_W, ALU_OUT);
    mux_2_32 bypassAfromMEM(mux_A_bypass_MEM, bypass_data_M_A, mux_A_bypass_M, q_dmem);
    mux_2_32 bypassAfromX(bypassed_A, bypass_A_X, mux_A_bypass_MEM, ALU_out);

    wire [31:0] bypassed_B, mux_B_bypass_W, mux_B_bypass_M, mux_B_bypass_MEM;
    mux_2_32 bypassBfromW(mux_B_bypass_W, bypass_B_W, data_readRegB, W_data);
    mux_2_32 bypassBfromM(mux_B_bypass_M, bypass_B_M, mux_B_bypass_W, ALU_OUT);
    mux_2_32 bypassBfromMEM(mux_B_bypass_MEM, bypass_data_M_B, mux_B_bypass_M, q_dmem);
    mux_2_32 bypassBfromX(bypassed_B, bypass_B_X, mux_B_bypass_MEM, ALU_out);

    wire [31:0] bypassed_D, mux_D_bypass_W, mux_D_bypass_M, mux_D_bypass_MEM;
    mux_2_32 bypassDfromW(mux_D_bypass_W, bypass_D_W, data_readRegB, W_data);
    mux_2_32 bypassDfromM(mux_D_bypass_M, bypass_D_M, mux_D_bypass_W, ALU_OUT);
    mux_2_32 bypassDfromMEM(mux_D_bypass_MEM, bypass_data_M_D, mux_D_bypass_M, q_dmem);
    mux_2_32 bypassDfromX(bypassed_D, bypass_D_X, mux_D_bypass_MEM, ALU_out);

    wire select_bypassed_D;
    assign select_bypassed_D = bypass_D_W | bypass_D_M | bypass_data_M_D | bypass_D_X;

    wire [31:0] bypassed_B_or_D;
    mux_2_32 muxbypassedB(bypassed_B_or_D, select_bypassed_D, bypassed_B, bypassed_D);



//Decode/Execute
    wire [31:0] DX_PC;
    register reg_dx_pc(not_clock, !mult_stall, FD_PC, DX_PC, reset);
    
    wire [31:0] DX_IR, muxed_DX_IR;
    register reg_dx_ir(not_clock, !mult_stall & !stall_for_delay, muxed_DX_IR, DX_IR, reset);
    mux_2_32 mux_dx_ir(muxed_DX_IR, reset | branch_taken | jr_select | bex_select | data_stall | ALU_exception | div_stall | lw_edge_stall, FD_IR, nop);

    wire [31:0] OPERAND_A, OPERAND_B;
    register reg_operand_a(not_clock, !mult_stall, bypassed_A, OPERAND_A, reset);
    register reg_operand_b(not_clock, !mult_stall, bypassed_B_or_D, OPERAND_B, reset);
    
//Execute
    //control for execute stage
    wire [4:0] ALU_op, shift_amount;
    assign ALU_op[4:0] = DX_IR[6:2];
    assign shift_amount[4:0] = DX_IR[11:7];
    
    wire [16:0] immediate;
    assign immediate[16:0] = DX_IR[16:0];
    
    wire [26:0] target;
    assign target[26:0] = DX_IR[26:0];

    wire [4:0] X_opcode;
    assign X_opcode[4:0] = DX_IR[31:27];

    wire X_r_type, X_i_type, X_j1_type, X_j2_type, bne, blt, X_switch_B, X_add_imm, jr_select, ctrl_m, ctrl_d, bex;
    control X_control(DX_IR, X_r_type, X_i_type, X_j1_type, X_j2_type, bne, blt, X_switch_B, X_add_imm, jr_select, ctrl_m, ctrl_d, bex);

    // ALU
    wire [31:0] ALU_out, operand_B, ALU_status;
    wire [4:0] ALU_op_zeros, ALU_op_in;
    wire notEqual, lessThan, ALU_exception, mult_ready;
    alu ALU(ALU_out, OPERAND_A, operand_B, ALU_op_in, shift_amount, clock, ALU_status, notEqual, lessThan, X_add_imm, ALU_exception, mult_ready);

    wire [31:0] immediate_positive, immediate_negative, immediate_32;
    assign immediate_positive[16:0] = immediate[16:0];
    assign immediate_positive[31:17] = 15'd0;
    assign immediate_negative[16:0] = immediate[16:0];
    assign immediate_negative[31:17] = 15'b111111111111111;
    mux_2_32 mux_immediate_extended(immediate_32, immediate[16], immediate_positive, immediate_negative);

    mux_2_32 mux_operand_B(operand_B, X_add_imm, OPERAND_B, immediate_32);
    assign ALU_op_zeros[4:0] = 5'b00000;
    mux_2_5 mux_ALUop(ALU_op_in, X_i_type, ALU_op, ALU_op_zeros);

    wire branch_taken, pc_imm_ovf, bex_select;
    assign branch_taken = (lessThan & blt) | (notEqual & bne);
    assign nop_ctrl = branch_taken;
    assign bex_select = bex & notEqual; //A = 0, B = rstatus = r30
    wire [31:0] T_bex;
    assign T_bex[31:27] = 5'd0;
    assign T_bex[26:0] = DX_IR[26:0];

    wire [31:0] PC_plus_immediate;
    adder pc_plus_imm(PC_plus_immediate, DX_PC, immediate_32, pc_imm_ovf, !enable);

    //mult stall for one cycle -> operation takes two cycles with wallace tree
    wire mult_stall;
    tff mulstall(mult_stall, ctrl_m, clock, enable, !enable);

    // divider instruction
    wire [31:0] DIV_IR;
    register reg_div_ir(not_clock, (ctrl_d), DX_IR, DIV_IR, reset);
    control_div controller_divver(DIV_IR, DX_IR, clock, ctrl_d, div_rdy, stall, div_stall);

    //divider
    wire [31:0] div_result, div_status;
    wire div_ex, div_rdy, div_stall, div_select, stall; 
    assign div_stall = (stall | (ctrl_d & ~ALU_op[4] & ~ALU_op[3] & ALU_op[2] & ALU_op[1] & ALU_op[0]));
    //only care about div instructions because mult is fast
    multdiv divider_(OPERAND_A, OPERAND_B, !enable, ctrl_d, clock, div_result, div_ex, div_rdy, div_status, div_select);

    //div regs
    wire [31:0] DIV_OUT;
    register reg_div_out(not_clock, div_rdy, div_result, DIV_OUT, reset);

    wire [31:0] DIV_IR_W;
    register reg_div_ir_w(not_clock, div_rdy, DIV_IR, DIV_IR_W, reset);
    wire true_div_select;
    assign true_div_select = div_stall & div_select & (~DIV_IR_W[6] & ~DIV_IR_W[5] & DIV_IR_W[4] & DIV_IR_W[3] & DIV_IR_W[2]);

    
//Execute/Memory
    wire [31:0] XM_IR, mux_XM_IR;
    register reg_xm_ir(not_clock, !ALU_exception & !stall_for_delay, mux_XM_IR, XM_IR, reset);
    mux_2_32 mux_xm_ir(mux_XM_IR, div_stall || jal_disable_X || mult_stall, DX_IR, nop);

    wire [31:0] ALU_OUT, XM_B, mux_XM_B;
    register reg_alu_out(not_clock, !ALU_exception, ALU_out, ALU_OUT, reset);
    register reg_xm_b(not_clock, !ALU_exception, mux_XM_B, XM_B, reset);
    mux_2_32 mux_xm_b(mux_XM_B, to_mem_bypass, OPERAND_B, q_dmem);

   

//Memory
    wire dmem_wren;
    control_mem m_control(XM_IR, dmem_wren);
    assign address_dmem[31:0] = ALU_OUT[31:0];
    assign data[31:0] = XM_B[31:0];
    assign wren = dmem_wren;

//Memory/Writeback
    wire [31:0] MW_IR, mux_MW_IR;
    register reg_mw_ir(not_clock, !ALU_exception & !stall_for_delay, mux_MW_IR, MW_IR, reset);
    mux_2_32 muxMXIR(mux_MW_IR, jal_disable_M, XM_IR, nop);

    wire [31:0] MW_ALU_OUT, MW_Data;
    register reg_alu_out_mw(not_clock, !ALU_exception, ALU_OUT, MW_ALU_OUT, reset);
    register reg_mw_d(not_clock, !ALU_exception, q_dmem, MW_Data, reset);

    

//Writeback
    //control
    wire wren_regfile, select_ALU_data, select_MD_data, setx;
    assign select_MD_data = 1'b0;
    control_wb wb_con(MW_IR, wren_regfile, select_ALU_data, setx);

    //determine register to write to
    wire [4:0] write_reg_muldiv, write_reg, write_reg_one, write_reg_norm, rstatus;
    assign write_reg_muldiv[4:0] = DIV_IR_W[26:22];
    assign write_reg_norm[4:0] = MW_IR[26:22];
    assign rstatus[4:0] = 5'd30;
    mux_2_5 mux_write_reg(write_reg_one, true_div_select, write_reg_norm, write_reg_muldiv);
    mux_2_5 mux_write_rstatus(write_reg, setx, write_reg_one, rstatus);

    //determine data to write
    wire [31:0] W_data, data_no_md, T_data, data_with_rstatus, data_with_div;
    assign T_data[26:0] = MW_IR[26:0];
    assign T_data[31:27] = 5'd0;
    mux_2_32 mux_writeback_data(data_no_md, select_ALU_data, MW_ALU_OUT, MW_Data);
    mux_2_32 mux_rstatus_data(data_with_rstatus, setx, data_no_md, T_data);
    mux_2_32 mux_writeback_md(data_with_div, true_div_select, data_with_rstatus, DIV_OUT);
    mux_2_32 mux_jaldisablewdata(W_data, jal_disable_W, data_with_div, nop);
	
/* END CODE */

endmodule
