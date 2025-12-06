module logical #(
    parameter XLEN = 64
) (
    input         clk,
    input         rst_n,

    input         is_and,
    input         is_or,
    input         is_xor,

    input  [XLEN-1:0] src1,
    input  [XLEN-1:0] src2,
    output [XLEN-1:0] rslt
);
    assign rslt = is_and ? src1 & src2 :
                  is_or  ? src1 | src2 :
                  is_xor ? src1 ^ src2 :
                          'b0;
endmodule