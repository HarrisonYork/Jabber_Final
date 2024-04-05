module leftshift(data_out, data_in, shift_amount);
    input [31:0] data_in;
    input [4:0] shift_amount;

    output [31:0] data_out;

    wire [31:0] shift16, shift8, shift4, shift2;

    leftshift16 ls16(shift16, data_in, shift_amount[4]);
    
    leftshift8 ls8(shift8, shift16, shift_amount[3]);

    leftshift4 ls4(shift4, shift8, shift_amount[2]);

    leftshift2 ls2(shift2, shift4, shift_amount[1]);

    leftshift1 ls1(data_out, shift2, shift_amount[0]);

endmodule