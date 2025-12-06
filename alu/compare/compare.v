module compare #(
    parameter XLEN = 64
) (
    input         clk,
    input         rst_n,

    input         is_eq,
    input         is_ne,
    input         is_lt,
    input         is_ge,
    input         is_ltu,
    input         is_geu,

    input  [XLEN-1:0] src1,
    input  [XLEN-1:0] src2,
    output [XLEN-1:0] rslt
);
    localparam integer LEVELS = $clog2(XLEN);

    wire [XLEN-1:0] eq_init, eq_level[0:LEVELS-1];
    
    wire bool;

    assign eq_init = src1 ^ src2;

    genvar l,i;
    generate
        for (l = 0; l < LEVELS; l = l + 1) begin
            localparam integer TEMP = 2 ** (LEVELS-1 - l);
            if (l == 0) begin
                for (i = 0; i < TEMP; i = i + 1) begin
                    assign eq_level[l][i] = eq_init[i * 2] | eq_init[i * 2 + 1];
                end
            end
            else begin
                for (i = 0; i < TEMP; i = i + 1) begin
                    assign eq_level[l][i] = eq_level[l-1][i * 2] | eq_level[l-1][i * 2 + 1];
                end
            end
        end
    endgenerate

    assign eq_rslt = ~eq_level[LEVELS-1][0];
    assign ne_rslt = eq_level[LEVELS-1][0];
    assign lt_rslt = src1[XLEN-1]  & ~src2[XLEN-1]

    assign bool = is_eq ? ~rslt_level[LEVELS-1][0] :
                  is_ne ?  rslt_level[LEVELS-1][0] :
                  is_lt ?  src1[XLEN-1] & ~src2[XLEN-1] :
                  is_ge ? ~src1[XLEN-1] &  src2[XLEN-1] :
                          'b0;
    assign rslt = {{XLEN-1{1'b0}}, bool};
endmodule
