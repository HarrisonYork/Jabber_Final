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
	SERVO_PWM, JS1, JS2, LED, BTN, CUSTOM_BTN);

	input clock, reset;
	input BTN, CUSTOM_BTN;
	input [3:0] JS1, JS2;
	
	output reg [4:0] SERVO_PWM;
	output reg [15:0] LED;
	
//	reg JS1_U, JS1_D, JS1_L, JS1_R, JS2_U, JS2_D, JS2_L, JS2_R;
	
//	always @(posedge clock_20Hz) begin
//	   JS1_U = JS1[0];
//	   JS1_D = JS1[1];
//	   JS1_L = JS1[2];
//	   JS1_R = JS1[3];
	   
//	   JS2_U = JS2[0];
//	   JS2_D = JS2[1];
//	   JS2_L = JS2[2];
//	   JS2_R = JS2[3];
//	end

	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut;

	// MEMORY FILE
	localparam INSTR_FILE = "pls_work";

	// SERVO CONTROL
	wire clock_20Hz;
	slow_clock_gen cgen(clock, clock_20Hz);

//	always @(posedge clock_20Hz) begin
//		if (JS_U == 0) begin
//			if (SERVO1_DUTY < 99) begin
//				SERVO1_DUTY = SERVO1_DUTY + 1;
//			end
//		end
//		if (JS_D == 0) begin
//			if (SERVO1_DUTY > 0) begin
//				SERVO1_DUTY = SERVO1_DUTY - 1;
//			end
//		end
//		if (JS_L == 0) begin
//			if (SERVO2_DUTY < 99) begin
//				SERVO2_DUTY = SERVO2_DUTY + 1;
//			end
//		end
//		if (JS_R == 0) begin
//			if (SERVO2_DUTY > 0) begin
//				SERVO2_DUTY = SERVO2_DUTY - 1;
//			end
//		end
//	end
	
	reg [6:0] SERVO_DUTY, SERVO0_DUTY,  SERVO1_DUTY,  SERVO2_DUTY,  SERVO3_DUTY,  SERVO4_DUTY;
	wire [6:0] servo0, servo1, servo2, servo3, servo4;
	wire [15:0] led;
	
	wire [3:0] js1, js2;
	assign js1[3:0] = JS1[3:0];
	assign js2[3:0] = JS2[3:0];
	
	wire lsb_25;
	
	always @(posedge clock) begin
		SERVO0_DUTY = servo0; //reg1
		SERVO1_DUTY = servo1; //reg2
		SERVO2_DUTY = servo2; //reg3
		SERVO3_DUTY = servo3; //reg4
		SERVO4_DUTY = servo4; //reg5
		LED[6:0] = SERVO0_DUTY[6:0];
		LED[15] = lsb_25;
		LED[14:7] = led[14:7];
	end
	
	wire [4:0] servo_pwm;
	always @(servo_pwm) begin
	   SERVO_PWM = servo_pwm;
   	end
	
	PWMSerializerBigBoy servo0_(
    .clk(clock),              // System Clock
    .reset(reset),            // Reset the counter
    .duty_cycle(SERVO0_DUTY),       // Duty Cycle of the Wave, between 0 and 99
    .signal(servo_pwm[0])   // Output PWM signal
    );
	PWMSerializer servo1_(
    .clk(clock),              // System Clock
    .reset(reset),            // Reset the counter
    .duty_cycle(SERVO1_DUTY),       // Duty Cycle of the Wave, between 1 and 99
    .signal(servo_pwm[1])   // Output PWM signal
    );
	PWMSerializer servo2_(
    .clk(clock),              // System Clock
    .reset(reset),            // Reset the counter
    .duty_cycle(SERVO2_DUTY),       // Duty Cycle of the Wave, between 2 and 99
    .signal(servo_pwm[2])   // Output PWM signal
    );
	PWMSerializer servo3_(
    .clk(clock),              // System Clock
    .reset(reset),            // Reset the counter
    .duty_cycle(SERVO3_DUTY),       // Duty Cycle of the Wave, between 3 and 99
    .signal(servo_pwm[3])   // Output PWM signal
    );
	PWMSerializerMini servo4_(
    .clk(clock),              // System Clock
    .reset(reset),            // Reset the counter
    .duty_cycle(SERVO4_DUTY),       // Duty Cycle of the Wave, between 4 and 99
    .signal(servo_pwm[4])   // Output PWM signal
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
		.data(memDataIn), .q_dmem(memDataOut)
		); 
	
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
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
		
		// SERVO
		.servo0(servo0), .servo1(servo1),
		.servo2(servo2), .servo3(servo3),
		.servo4(servo4),
		.js1(js1), .js2(js2), .BTN(BTN), .custom_btn(CUSTOM_BTN),
		
		//Test output cgen
		.test_reg(led), .test_val(lsb_25)
		);
	
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock),
		.wEn(mwe), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn), 
		.dataOut(memDataOut));

endmodule
