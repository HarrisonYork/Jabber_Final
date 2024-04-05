`timescale 1ns / 1ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, 
 * RegFile and Memory elements together.
 *
 * This file will be used to generate the bitstream to upload to the FPGA.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 * 
 * We will be using our own separate Wrapper_tb.v to test your code. You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 * You must change line 36 to add the memory file of the test you created using the assembler
 * For example, you would add sample inside of the quotes on line 38 after assembling sample.s
 *
 **/

module Wrapper (clock, reset,
	ACL_CIPO, ACL_COPI,
	ACL_SCLK, ACL_CSN,
	ACL_INTERRUPT
	);

	input clock, reset, ACL_CIPO;
	input [1:0] ACL_INTERRUPT;

	output ACL_COPI, ACL_SCLK, ACL_CSN;

	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut;



	// SPI Controller
	wire input_data_valid, output_data_valid, next_byte_ready;
	wire [7:0] COPI_BYTE, CIPO_BYTE;

	assign ACL_CSN = 1'b0; //active low, enable accelerometer

	SPIController SPI(.i_clk(clock), .i_reset_n(reset),
		.i_tx_byte(COPI_BYTE), .i_tx_dv(input_data_valid), .o_tx_ready(next_byte_ready),
		.o_rx_dv(output_data_valid), .o_rx_byte(CIPO_BYTE),
		.o_spi_clk(ACL_SCLK), .i_spi_cipo(ACL_CIPO), .o_spi_copi(ACL_COPI));

	// need to create instructions to send a byte to accelerometer (COPI_BYTE)
	// stall cpu until receive a byte back from a read (output_data_valid) or (next_byte_ready)
	//



	// MEMORY FILE
	localparam INSTR_FILE = "addi_basic";
	
	// Main Processing Unit
	processor CPU(.clock(clock), .reset(reset), 
								
		// ROM
		.address_imem(instAddr), .q_imem(instData),
									
		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
									
		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataIn), .q_dmem(memDataOut)); 
	
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));
	
	// Register File
	regfile RegisterFile(.clock(clock), 
		.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
		.ctrl_writeReg(rd),
		.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB));
						
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock),
		.wEn(mwe), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn), 
		.dataOut(memDataOut));

endmodule
