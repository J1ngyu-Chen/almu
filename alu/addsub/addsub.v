module addsub #(
    parameter XLEN = 64
) (
    input         clk,
    input         rst_n,

    input         is_add,
    input         is_sub,

    input  [XLEN-1:0] src1,
    input  [XLEN-1:0] src2,
    output [XLEN-1:0] rslt
);
    wire adder_cin;
    wire [XLEN-1:0] adder_src1, adder_src2;

    assign adder_cin = is_sub ? 'b1 :
                                'b0;
    assign adder_src1 = src1;
    assign adder_src2 = is_sub ? ~adder_src2 :
                                  adder_src2;

    localparam integer LEVELS = $clog2(XLEN) + 1;
    wire [XLEN-1:0] adder_p[0:LEVELS-1], adder_g[0:LEVELS-1];
    wire [XLEN-1:0] adder_c, adder_s;

    genvar l, i;
    generate
        // Initial propagate / generate
        for (i = 0; i < XLEN; i = i + 1) begin
            assign adder_p[0][i] = adder_src1[i] ^ adder_src2[i];
            assign adder_g[0][i] = adder_src1[i] & adder_src2[i];
        end

        // Prefix-tree
        for (l = 1; l < LEVELS; l = l + 1) begin
            for (i = 0; i < XLEN; i = i + 1) begin
                parameter TEMP = 2 ** (l - 1);
                if (i < TEMP) begin
                    assign adder_p[l][i] = adder_p[l-1][i];
                    assign adder_g[l][i] = adder_g[l-1][i];
                end
                else begin
                    assign adder_p[l][i] = adder_p[l-1][i] & adder_p[l - 1][i - TEMP];
                    assign adder_g[l][i] = adder_g[l-1][i] | (adder_p[l-1][i] & adder_g[l-1][i - TEMP]);            
                end
            end
        end
        
        // Carry and Sum
        for (i = 0; i < XLEN; i = i + 1) begin
            assign adder_c[i] = adder_g[LEVELS-1][i] | (adder_p[LEVELS-1][i] & adder_cin);
        end
        for (i = 0; i < XLEN; i = i + 1) begin
            if (i == 0)
                assign adder_s[i] = adder_p[0][i] ^ adder_cin;
            else
                assign adder_s[i] = adder_p[0][i] ^ adder_c[i-1];
        end
        
        // Output
        assign rlst = adder_s;
        // assign cout = adder_c[XLEN-1];
        
    endgenerate

endmodule