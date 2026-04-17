module fp_perm(input [63:0] in64, output [63:0] out64);
    function [0:0] S; input [6:0] p; input [63:0] x; begin S = x[64-p]; end endfunction
    assign out64 = {
        S(40,in64),S(8 ,in64),S(48,in64),S(16,in64),S(56,in64),S(24,in64),S(64,in64),S(32,in64),
        S(39,in64),S(7 ,in64),S(47,in64),S(15,in64),S(55,in64),S(23,in64),S(63,in64),S(31,in64),
        S(38,in64),S(6 ,in64),S(46,in64),S(14,in64),S(54,in64),S(22,in64),S(62,in64),S(30,in64),
        S(37,in64),S(5 ,in64),S(45,in64),S(13,in64),S(53,in64),S(21,in64),S(61,in64),S(29,in64),
        S(36,in64),S(4 ,in64),S(44,in64),S(12,in64),S(52,in64),S(20,in64),S(60,in64),S(28,in64),
        S(35,in64),S(3 ,in64),S(43,in64),S(11,in64),S(51,in64),S(19,in64),S(59,in64),S(27,in64),
        S(34,in64),S(2 ,in64),S(42,in64),S(10,in64),S(50,in64),S(18,in64),S(58,in64),S(26,in64),
        S(33,in64),S(1 ,in64),S(41,in64),S(9 ,in64),S(49,in64),S(17,in64),S(57,in64),S(25,in64)
    };
endmodule