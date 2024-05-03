module control_hazard(FD_IR, DX_IR, XM_IR, MW_IR, data_stall, 
    bypass_A_W, bypass_A_M, bypass_A_X, 
    bypass_B_W, bypass_B_M, bypass_B_X,
    to_mem_bypass, 
    bypass_D_W, bypass_D_M, bypass_D_X,
    lw_edge_stall, bypass_data_M_A, bypass_data_M_B, bypass_data_M_D,
    jal_disable_W, jal_disable_M, jal_disable_X);

    input [31:0] FD_IR, DX_IR, XM_IR, MW_IR;
    
    output bypass_A_W, bypass_A_M, bypass_A_X, bypass_B_W, bypass_B_M, bypass_B_X;

    output bypass_D_W, bypass_D_M, bypass_D_X;

    output data_stall, to_mem_bypass, jal_disable_W, jal_disable_M, jal_disable_X;

    output lw_edge_stall, bypass_data_M_A, bypass_data_M_B, bypass_data_M_D;

    wire [4:0] FD_S, FD_T, FD_D, DX_D, XM_D, MW_D, zero;

    assign FD_S[4:0] = FD_IR[21:17];
    assign FD_T[4:0] = FD_IR[16:12];
    assign FD_D[4:0] = FD_IR[26:22];

    assign DX_D[4:0] = DX_IR[26:22];
    assign XM_D[4:0] = XM_IR[26:22];
    assign MW_D[4:0] = MW_IR[26:22];

    assign zero[4:0] = 5'd0;
    wire enable;
    assign enable = 1'b1;

    wire [4:0] opcodeFD, ALUopFD;
    assign opcodeFD[4:0] = FD_IR[31:27];
    assign ALUopFD[4:0] = FD_IR[6:2];

    wire [31:0] inumFD, alunumFD;
    decoder decode_opcodefd(inumFD, opcodeFD, enable);
    decoder decode_aluopfd(alunumFD, ALUopFD, enable);

    wire [4:0] opcodeDX, ALUopDX;
    assign opcodeDX[4:0] = DX_IR[31:27];
    assign ALUopDX[4:0] = DX_IR[6:2];

    wire [31:0] inumDX, alunumDX;
    decoder decode_opcodeDX(inumDX, opcodeDX, enable);
    decoder decode_aluopDX(alunumDX, ALUopDX, enable);

    wire [4:0] opcodeXM, ALUopXM;
    assign opcodeXM[4:0] = XM_IR[31:27];
    assign ALUopXM[4:0] = XM_IR[6:2];

    wire [31:0] inumXM, alunumXM;
    decoder decode_opcodeXM(inumXM, opcodeXM, enable);
    decoder decode_aluopXM(alunumXM, ALUopXM, enable);

    wire [4:0] opcodeMW, ALUopMW;
    assign opcodeMW[4:0] = MW_IR[31:27];
    assign ALUopMW[4:0] = MW_IR[6:2];

    wire [31:0] inumMW, alunumMW;
    decoder decode_opcodeMW(inumMW, opcodeMW, enable);
    decoder decode_aluopMW(alunumMW, ALUopMW, enable);

    wire RAW, bex_setx, jal_haz;
    assign RAW = ((FD_S == DX_D && FD_S != zero) || (FD_T == DX_D && FD_T != zero) ||
                  (FD_S == XM_D && FD_S != zero) || (FD_T == XM_D && FD_T != zero) ||
                  (FD_S == MW_D && FD_S != zero) || (FD_T == MW_D && FD_T != zero)) && 
                        (arithmetic_FD);

    assign bex_setx =  ((inumFD[22] && inumDX[21]) ||
                        (inumFD[22] && inumXM[21]) ||
                        (inumFD[22] && inumMW[21]) );

    assign jal_haz = inumFD[3] && (reg31 == DX_D || reg31 == XM_D || reg31 == MW_D);

    assign data_stall = 1'b0;
                       
    wire [4:0] reg31;
    assign reg31[4:0] = 5'd31;

    // BYPASSING CONTROL
    
    wire branch_instruction_FD;
    assign branch_instruction_FD = inumFD[2] || inumFD[6];

    wire arithmetic_FD;
    assign arithmetic_FD = inumFD[0] || inumFD[5]; // normal alu op or addi
    
    // bypass A value (reg s)    
    assign bypass_A_W = ((MW_D == FD_S && FD_S != zero) && ((arithmetic_FD || branch_instruction_FD || inumFD[7] || inumFD[8]) && (inumMW[0] || inumMW[5])));
                    
    assign bypass_A_M = ((XM_D == FD_S && FD_S != zero) && ((arithmetic_FD || branch_instruction_FD || inumFD[7] || inumFD[8]) && (inumXM[0] || inumXM[5]))); //maybe inumXM[8] here
    
    assign bypass_A_X = ((DX_D == FD_S && FD_S != zero) && ((arithmetic_FD || branch_instruction_FD || inumFD[7] || inumFD[8]) && (inumDX[0] || inumDX[5])));

    assign bypass_data_M_A = (XM_D == FD_S && FD_S != zero) && 
                        ((arithmetic_FD || branch_instruction_FD) && inumXM[8]);

    // bypass B value (reg t)
    assign bypass_B_W = (MW_D == FD_T && FD_T != zero) && (inumFD[0] && (inumMW[0] || inumMW[5]));
    
    assign bypass_B_M = (XM_D == FD_T && FD_T != zero) && (inumFD[0] && (inumXM[0] || inumXM[5]));
    
    assign bypass_B_X = (DX_D == FD_T && FD_T != zero) && (inumFD[0] && (inumDX[0] || inumDX[5]));

    assign bypass_data_M_B = (XM_D == FD_T && FD_T != zero) && 
                        ((arithmetic_FD || branch_instruction_FD) && inumXM[8]);

    // bypass reg d
    assign bypass_D_W = ((FD_D == MW_D && FD_D != zero) && ((inumMW[0] || inumMW[5] || inumMW[8]) && (inumFD[4]|| inumFD[7] || branch_instruction_FD)));
    
    assign bypass_D_M = ((FD_D == XM_D && FD_D != zero) && ((inumXM[0] || inumXM[5]) && (inumFD[4] || inumFD[7] || branch_instruction_FD)));
    
    assign bypass_D_X = ((FD_D == DX_D && FD_D != zero) && ((inumDX[0] || inumDX[5] || inumDX[8]) && (inumFD[4] || inumFD[7] || branch_instruction_FD)));

    assign bypass_data_M_D = (XM_D == FD_D && FD_D != zero) && 
                        ((inumXM[8]) && (inumFD[4] || inumFD[7] || branch_instruction_FD));

    //if a lw in M and sw in X with same reg, send output of ram to XM_B
    assign to_mem_bypass = (inumXM[8] && inumDX[7]) && (XM_D == DX_D && DX_D != zero); //sw is 7, lw is 8

    // lw edge case stall
    wire lw_stall_arithmetic, lw_stall_branch, lw_stall_jr; //lw_edge_stall
    assign lw_stall_arithmetic = (FD_S == DX_D || FD_T == DX_D) && (DX_D != zero) && (inumDX[8] && (arithmetic_FD));
    assign lw_stall_branch = (FD_D == DX_D || FD_S == DX_D) && (DX_D != zero) && (inumDX[8] && (branch_instruction_FD));
    assign lw_stall_jr = (FD_D == DX_D) && (DX_D != zero) && (inumDX[8] && inumFD[4]);
    assign lw_edge_stall = lw_stall_arithmetic || lw_stall_branch || lw_stall_jr;

    //disable writing to jal in between taking jump and jal reaching W latch
    assign jal_disable_W = (inumFD[3] && (inumMW[0] || inumMW[5]) && (MW_D == reg31));
    assign jal_disable_M = (inumFD[3] && (inumXM[0] || inumXM[5]) && (XM_D == reg31));
    assign jal_disable_X = (inumFD[3] && (inumDX[0] || inumDX[5]) && (DX_D == reg31));



    



endmodule