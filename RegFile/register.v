module register(clock, inEnable, inVal, outVal, reset);

    input clock, inEnable, reset;
    input [31:0] inVal;

    output [31:0] outVal;

    genvar i;
    generate
        for (i=0; i<32; i = i+1) begin: loop1
            dffe dff_e(outVal[i], inVal[i], clock, inEnable, reset); //dffe(q, d, clk, en, clr);
        end
    endgenerate

endmodule