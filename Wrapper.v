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
	SERVO_PWM);

	input clock, reset;
	
	output reg [5:0] SERVO_PWM;
	always @(servo_pwm) begin
	   SERVO_PWM = servo_pwm;
    end

	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut;

	// MEMORY FILE
	localparam INSTR_FILE = "addi_basic";

	//servo control

	//add PWM serializer for each servo
	// make instruction that outputs from processor to serializer
	// change duty cycle as needed
	wire [6:0] SERVO0_DUTY,  SERVO1_DUTY,  SERVO2_DUTY,  SERVO3_DUTY,  SERVO4_DUTY,  SERVO5_DUTY;
	assign SERVO0_DUTY = 7'd10;
	assign SERVO1_DUTY = 7'd10;
	assign SERVO2_DUTY = 7'd10;
	assign SERVO3_DUTY = 7'd10;
	assign SERVO4_DUTY = 7'd10;
	assign SERVO5_DUTY = 7'd10;
	wire [5:0] servo_pwm;
	PWMSerializer servo0(
    .clk(clock),              // System Clock
    .reset(reset),            // Reset the counter
    .duty_cycle(SERVO0_DUTY),       // Duty Cycle of the Wave, between 0 and 99
    .signal(servo_pwm[0])   // Output PWM signal
    );
	PWMSerializer servo1(
    .clk(clock),              // System Clock
    .reset(reset),            // Reset the counter
    .duty_cycle(SERVO1_DUTY),       // Duty Cycle of the Wave, between 1 and 99
    .signal(servo_pwm[1])   // Output PWM signal
    );
	PWMSerializer servo2(
    .clk(clock),              // System Clock
    .reset(reset),            // Reset the counter
    .duty_cycle(SERVO2_DUTY),       // Duty Cycle of the Wave, between 2 and 99
    .signal(servo_pwm[2])   // Output PWM signal
    );
	PWMSerializer servo3(
    .clk(clock),              // System Clock
    .reset(reset),            // Reset the counter
    .duty_cycle(SERVO3_DUTY),       // Duty Cycle of the Wave, between 3 and 99
    .signal(servo_pwm[3])   // Output PWM signal
    );
	PWMSerializer servo4(
    .clk(clock),              // System Clock
    .reset(reset),            // Reset the counter
    .duty_cycle(SERVO4_DUTY),       // Duty Cycle of the Wave, between 4 and 99
    .signal(servo_pwm[4])   // Output PWM signal
    );
	PWMSerializer servo5(
    .clk(clock),              // System Clock
    .reset(reset),            // Reset the counter
    .duty_cycle(SERVO5_DUTY),       // Duty Cycle of the Wave, between 5 and 99
    .signal(servo_pwm[5])   // Output PWM signal
    );

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
