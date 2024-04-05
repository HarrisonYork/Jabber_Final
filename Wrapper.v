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
	ACL_INTERRUPT,
	LED, SEG, DP, AN
	);

	input clock, reset, ACL_CIPO;
	input [1:0] ACL_INTERRUPT;

	output ACL_COPI, ACL_SCLK, ACL_CSN;
	output [14:0] LED;
	output [6:0] SEG,           // 7 segments of display
    output DP,                  // decimal point of display
    output [7:0] AN

	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut;

	//make 4MHz clock
	wire clock4MHz;

    clock_gen clock_generation(
        .CLK100MHZ(clock),
        .clk_4MHz(clock4MHz)
    );

	// SPI Controller
	assign ACL_CSN = 1'b0; //active low, enable accelerometer
	wire [14:0] acl_data;

	SPIController spi_control(
        .iclk(clock4MHz),
        .miso(ACL_CIPO),
        .sclk(ACL_SCLK),
        .mosi(ACL_COPI),
        .cs(ACL_CSN),
        .acl_data(acl_data)
    );

	//seven segment display
	seg7_control display_control(
        .CLK100MHZ(clock),
        .acl_data(acl_data),
        .seg(SEG),
        .dp(DP),
        .an(AN)
    );

	assign LED[14:10] = acl_data[14:10];    // 5 bits of x data
    assign LED[9:5]   = acl_data[9:5];     // 5 bits of y data
    assign LED[4:0]   = acl_data[4:0];      // 5 bits of z data


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
