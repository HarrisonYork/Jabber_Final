module divider(result, A, B, ctrl_DIV, clock, exception, ready, remainder, write);
    input [31:0] A, B; // A is dividend, B is divisor
    input ctrl_DIV, clock;

    output [31:0] result;
    output exception, ready, write;
    output [31:0] remainder;

    wire [63:0] write_quotient, read_quotient, starter_quotient, shifted_quotient;
    wire enable, reset;
    assign starter_quotient[63:32] = 32'b0;
    assign starter_quotient[31:0] = A[31:0];
    
    assign enable = 1'b1;
    assign reset = 1'b0;

    wire [31:0] read_q, read_r, shift_r;
    assign read_q[31:0] = read_quotient[31:0];
    assign read_r[31:0] = read_quotient[63:32];
    assign shift_r[31:0] = shifted_quotient[63:32];

    wire [63:0] adder_quotient;
    mux_2_64 choose_quotient(write_quotient, ctrl_DIV, adder_quotient, starter_quotient);
    
    register_64 quotient(clock, ~(ready), write_quotient, read_quotient, reset); // (clock, inEnable, inVal, outVal, reset);

    
    leftshift1_64 lefts(shifted_quotient, read_quotient, enable);

    wire [31:0] adder_out;
    wire add_ovf, add_ovf2, add_ovfR;
    adder adder_(adder_out, shifted_quotient[63:32], B, add_ovf, ~(read_quotient[63]));

    
    assign adder_quotient[63:32] = adder_out[31:0];
    assign adder_quotient[31:1] = shifted_quotient[31:1];
    assign adder_quotient[0] = ~(adder_out[31]);

    
    wire or_divisor;
    assign or_divisor = (B[0] | B[1] | B[2] | B[3] | B[4] | B[5] | B[6] | B[7] | B[8] | B[9] | B[10] | B[11] | B[12] | B[13] | B[14] | B[15] | B[16] | B[17] | B[18] | B[19] | B[20] | B[21] | B[22] | B[23] | B[24] | B[25] | B[26] | B[27] | B[28] | B[29] | B[30] | B[31]);

    assign exception = ~(or_divisor) | add_ovf;

    assign result[31:0] = read_quotient[31:0];

    wire [31:0] true_remainder, add_remainder;
    assign remainder[31:0] = true_remainder[31:0];

    mux_2_32 mux_r(true_remainder, read_quotient[63], read_quotient[63:32], add_remainder[31:0]);
    adder add_r(add_remainder, read_quotient[63:32], B, add_ovfR, ~(read_quotient[63]));

    wire [5:0] c;
    count_64 counter_64(c, clock, ctrl_DIV);

    assign ready = (c[5] & ~c[4] & ~c[3] & ~c[2] & ~c[1] & ~c[0]);
    assign write = (c[5] & ~c[4] & ~c[3] & ~c[2] & ~c[1] & c[0]);


endmodule