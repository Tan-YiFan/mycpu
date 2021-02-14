`include "interface.svh"
module regfile 
    import common::*;(
    input logic clk,

);
    word_t [CREG_NUM-1:1] regs, regs_nxt;

    always_ff @(posedge clk) begin
        regs <= regs_nxt;
    end
    
    for (genvar i = 1; i < CREG_NUM; i++) begin
        always_comb @(posedge clk) begin
            regs_nxt[i] = regs[i];
            if (1) begin
                regs_nxt[i] = wd;
            end
        end
    end
    

endmodule
