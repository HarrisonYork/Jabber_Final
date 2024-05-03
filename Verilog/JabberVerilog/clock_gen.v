`timescale 1ns / 1ps
// Created by David J. Marion
// Date 7.22.2022
// For NexysA7 Accelerometer Reading

module clock_gen(
    input CLK100MHZ,        // nexys a7 sys clk
    output clk_5kHz         // 4MHz clk
);

    reg [4:0] counter = 5'b0;
    reg clk_reg = 1'b1;

    always @(posedge CLK100MHZ) begin
        if(counter == 10000)           // 0-12 is 13 ticks
            clk_reg <= ~clk_reg;
        if(counter == 20000) begin     // 13-24 is 12 ticks
            clk_reg <= ~clk_reg;
            counter <= 5'b0;        // reset counter
        end
        else
            counter <= counter + 1;
    end

    assign clk_5kHz = clk_reg;

endmodule