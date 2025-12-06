module shift #(
	parameter XLEN = 64,
	parameter SLEN = 6
) (
    input         clk,
    input         rst_n,

    input         is_sll,
    input         is_srl,
    input         is_sra,

    input  [XLEN-1:0] src,
    input  [SLEN-1:0] shamt,
    output [XLEN-1:0] rslt
);
    localparam integer LEVELS = SLEN;

    wire [XLEN-1:0] op_rslt[0:LEVELS-1];
    wire [XLEN-1:0] rslt_level[0:LEVELS-1];

    genvar l;
    generate
        for (l = 0; l < LEVELS; l = l + 1) begin
            localparam integer TEMP = 2 ** l;

            wire sign;
                 
            if (l == 0) begin
                assign sign       = src[XLEN-1];
                
                assign op_rslt[l] = is_sll ? {src[XLEN-1-TEMP:0], {TEMP{1'b0}}} :
                                    is_srl ? {{TEMP{1'b0}}, src[XLEN-1:TEMP]} :
                                    is_sra ? {{TEMP{sign}}, src[XLEN-1:TEMP]} :
                                             'b0;
                                             
                assign rslt_level[l] = shamt[l] ? op_rslt[l] : src;
            end
            else begin
                wire [XLEN-1:0] last_rslt;
                
                assign last_rslt  = rslt_level[l - 1];
                assign sign       = last_rslt[XLEN-1];
                
                assign op_rslt[l] = is_sll ? {last_rslt[XLEN-1-TEMP:0], {TEMP{1'b0}}} :
                                    is_srl ? {{TEMP{1'b0}}, last_rslt[XLEN-1:TEMP]} :
                                    is_sra ? {{TEMP{sign}}, last_rslt[XLEN-1:TEMP]} :
                                             'b0;
                                             
                assign rslt_level[l] = shamt[l] ? op_rslt[l] : last_rslt;
            end
        end
    endgenerate
    
    assign rslt = rslt_level[LEVELS-1];

endmodule