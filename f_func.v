module f_func(input [31:0] R, input [47:0] K, output [31:0] F);
    wire [47:0] e;
    e_expand uE(.in32(R), .out48(e));
    wire [47:0] x = e ^ K;
    wire [31:0] s;
    des_sboxes uS(.in48(x), .out32(s));
    p_permutation32 uP(.in32(s), .out32(F));
endmodule