module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;

	wire [31:0] write_to_this_register;

	decoder decW(write_to_this_register, ctrl_writeReg, ctrl_writeEnable); // decoder(out, select, enable);

	// enable should be 1 for regA, B because we always want to read
	wire hot_enable;
	assign hot_enable = 1;

	wire [31:0] read_from_A;
	decoder deco(read_from_A, ctrl_readRegA, hot_enable); // decoder(out, select, enable);
	
	wire [31:0] read_from_B;
	decoder deco2(read_from_B, ctrl_readRegB, hot_enable); // decoder(out, select, enable);

	// make enables for registers
	wire [31:0] decoded_write_enable;

	genvar a;
    generate
        for (a=0; a<32; a = a+1) begin: loopa
            and AND1(decoded_write_enable[a], ctrl_writeEnable, write_to_this_register[a]);
			//this should and the write enable input with every output of 
			//register decode bus. Only 1 register should receive a 1 from
			//decoded_write_enable -> register
		end
    endgenerate
	
	// make registers
	//register register(clock, inEnable, inVal, outVal, reset);

	wire [31:0] zeros;
	genvar l;
    generate
        for (l=0; l<32; l = l+1) begin: loopl
            assign zeros[l] = 0;
		end
    endgenerate

	// wire [31:0] register0_out;
	// register register0(clock, decoded_write_enable[0], data_writeReg, register0_out, ctrl_reset);
	wire [31:0] register1_out;
	register register1(clock, decoded_write_enable[1], data_writeReg, register1_out, ctrl_reset);
	wire [31:0] register2_out;
	register register2(clock, decoded_write_enable[2], data_writeReg, register2_out, ctrl_reset);
	wire [31:0] register3_out;
	register register3(clock, decoded_write_enable[3], data_writeReg, register3_out, ctrl_reset);
	wire [31:0] register4_out;
	register register4(clock, decoded_write_enable[4], data_writeReg, register4_out, ctrl_reset);
	wire [31:0] register5_out;
	register register5(clock, decoded_write_enable[5], data_writeReg, register5_out, ctrl_reset);
	wire [31:0] register6_out;
	register register6(clock, decoded_write_enable[6], data_writeReg, register6_out, ctrl_reset);
	wire [31:0] register7_out;
	register register7(clock, decoded_write_enable[7], data_writeReg, register7_out, ctrl_reset);
	wire [31:0] register8_out;
	register register8(clock, decoded_write_enable[8], data_writeReg, register8_out, ctrl_reset);
	wire [31:0] register9_out;
	register register9(clock, decoded_write_enable[9], data_writeReg, register9_out, ctrl_reset);
	wire [31:0] register10_out;
	register register10(clock, decoded_write_enable[10], data_writeReg, register10_out, ctrl_reset);
	wire [31:0] register11_out;
	register register11(clock, decoded_write_enable[11], data_writeReg, register11_out, ctrl_reset);
	wire [31:0] register12_out;
	register register12(clock, decoded_write_enable[12], data_writeReg, register12_out, ctrl_reset);
	wire [31:0] register13_out;
	register register13(clock, decoded_write_enable[13], data_writeReg, register13_out, ctrl_reset);
	wire [31:0] register14_out;
	register register14(clock, decoded_write_enable[14], data_writeReg, register14_out, ctrl_reset);
	wire [31:0] register15_out;
	register register15(clock, decoded_write_enable[15], data_writeReg, register15_out, ctrl_reset);
	wire [31:0] register16_out;
	register register16(clock, decoded_write_enable[16], data_writeReg, register16_out, ctrl_reset);
	wire [31:0] register17_out;
	register register17(clock, decoded_write_enable[17], data_writeReg, register17_out, ctrl_reset);
	wire [31:0] register18_out;
	register register18(clock, decoded_write_enable[18], data_writeReg, register18_out, ctrl_reset);
	wire [31:0] register19_out;
	register register19(clock, decoded_write_enable[19], data_writeReg, register19_out, ctrl_reset);
	wire [31:0] register20_out;
	register register20(clock, decoded_write_enable[20], data_writeReg, register20_out, ctrl_reset);
	wire [31:0] register21_out;
	register register21(clock, decoded_write_enable[21], data_writeReg, register21_out, ctrl_reset);
	wire [31:0] register22_out;
	register register22(clock, decoded_write_enable[22], data_writeReg, register22_out, ctrl_reset);
	wire [31:0] register23_out;
	register register23(clock, decoded_write_enable[23], data_writeReg, register23_out, ctrl_reset);
	wire [31:0] register24_out;
	register register24(clock, decoded_write_enable[24], data_writeReg, register24_out, ctrl_reset);
	wire [31:0] register25_out;
	register register25(clock, decoded_write_enable[25], data_writeReg, register25_out, ctrl_reset);
	wire [31:0] register26_out;
	register register26(clock, decoded_write_enable[26], data_writeReg, register26_out, ctrl_reset);
	wire [31:0] register27_out;
	register register27(clock, decoded_write_enable[27], data_writeReg, register27_out, ctrl_reset);
	wire [31:0] register28_out;
	register register28(clock, decoded_write_enable[28], data_writeReg, register28_out, ctrl_reset);
	wire [31:0] register29_out;
	register register29(clock, decoded_write_enable[29], data_writeReg, register29_out, ctrl_reset);
	wire [31:0] register30_out;
	register register30(clock, decoded_write_enable[30], data_writeReg, register30_out, ctrl_reset);
	wire [31:0] register31_out;
	register register31(clock, decoded_write_enable[31], data_writeReg, register31_out, ctrl_reset);


	wire [31:0] tri_state;
	assign tri_state = 32'bz;

	assign data_readRegA[31:0] = read_from_A[0] ? zeros[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[1] ? register1_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[2] ? register2_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[3] ? register3_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[4] ? register4_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[5] ? register5_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[6] ? register6_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[7] ? register7_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[8] ? register8_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[9] ? register9_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[10] ? register10_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[11] ? register11_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[12] ? register12_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[13] ? register13_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[14] ? register14_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[15] ? register15_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[16] ? register16_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[17] ? register17_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[18] ? register18_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[19] ? register19_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[20] ? register20_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[21] ? register21_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[22] ? register22_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[23] ? register23_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[24] ? register24_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[25] ? register25_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[26] ? register26_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[27] ? register27_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[28] ? register28_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[29] ? register29_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[30] ? register30_out[31:0] : tri_state[31:0];
	assign data_readRegA[31:0] = read_from_A[31] ? register31_out[31:0] : tri_state[31:0];

	assign data_readRegB[31:0] = read_from_B[0] ? zeros[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[1] ? register1_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[2] ? register2_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[3] ? register3_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[4] ? register4_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[5] ? register5_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[6] ? register6_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[7] ? register7_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[8] ? register8_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[9] ? register9_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[10] ? register10_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[11] ? register11_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[12] ? register12_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[13] ? register13_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[14] ? register14_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[15] ? register15_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[16] ? register16_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[17] ? register17_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[18] ? register18_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[19] ? register19_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[20] ? register20_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[21] ? register21_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[22] ? register22_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[23] ? register23_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[24] ? register24_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[25] ? register25_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[26] ? register26_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[27] ? register27_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[28] ? register28_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[29] ? register29_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[30] ? register30_out[31:0] : tri_state[31:0];
	assign data_readRegB[31:0] = read_from_B[31] ? register31_out[31:0] : tri_state[31:0];

endmodule
