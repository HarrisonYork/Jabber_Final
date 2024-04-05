module register_64(clock, inEnable, inVal, outVal, reset);

    input clock, inEnable, reset;
    input [63:0] inVal;

    output [63:0] outVal;

    genvar i;
    generate
        for (i=0; i<64; i = i+1) begin: loop1
            dffe dff_e(outVal[i], inVal[i], clock, inEnable, reset); //dffe(q, d, clk, en, clr);
        end
    endgenerate

endmodule