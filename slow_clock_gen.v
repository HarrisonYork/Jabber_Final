`timescale 1ns / 1ps
// Created by David J. Marion
// Date 7.22.2022
// For NexysA7 Accelerometer Reading

module slow_clock_gen(
    input CLK100MHZ,        // nexys a7 sys clk
    output clk_20Hz         // 4MHz clk
);

    reg [31:0] counter = 5'b0;
    reg clk_reg = 1'b1;

    always @(posedge CLK100MHZ) begin
        if(counter == 2500000)           // 0-12 is 13 ticks
            clk_reg <= ~clk_reg;
        if(counter == 5000000) begin     // 13-24 is 12 ticks
            clk_reg <= ~clk_reg;
            counter <= 31'b0;        // reset counter
        end
        else
            counter <= counter + 1;
    end

    assign clk_20Hz = clk_reg;

endmodule