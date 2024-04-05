module count_64(q, clock, reset);
    input clock, reset;

    output [5:0] q;

    wire one, zero;
    assign one = 1'b1;

    tff t0(q[0], one, clock, one, reset); // (q, t, clk, en, clr);
    tff t1(q[1], q[0], clock, one, reset);
    tff t2(q[2], q[0] & q[1], clock, one, reset);
    tff t3(q[3], q[0] & q[1] & q[2], clock, one, reset);
    tff t4(q[4], q[0] & q[1] & q[2] & q[3], clock, one, reset);
    tff t5(q[5], q[0] & q[1] & q[2] & q[3] & q[4], clock, one, reset);

endmodule