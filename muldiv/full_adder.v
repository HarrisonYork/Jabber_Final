module full_adder(S, Cout, A, B, Cin);
    input A, B, Cin;

    output S, Cout;

    wire xor1, and1, and2;

    xor xor_1(xor1, A, B);
    xor summer(S, xor1, Cin);

    and AND1(and1, xor1, Cin);
    and AND2(and2, A, B);

    or orC(Cout, and2, and1);

endmodule