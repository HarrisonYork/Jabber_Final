module count_16(q, clock, reset);
    input clock, reset;

    output [3:0] q;

    wire one, zero;
    assign one = 1'b1;
    assign zero = 1'b0;

    tff t0(q[0], one, clock, one, reset); // (q, t, clk, en, clr);
    tff t1(q[1], q[0], clock, one, reset);
    tff t2(q[2], q[0] & q[1], clock, one, reset);
    tff t3(q[3], q[0] & q[1] & q[2], clock, one, reset);

endmodule