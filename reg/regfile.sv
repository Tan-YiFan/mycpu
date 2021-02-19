`include "interface.svh"
module regfile 
    import common::*;(
    input logic clk,
    regfile_intf.regfile self
);
    word_t [CREG_NUM-1:1] regs, regs_nxt;

    always_ff @(posedge clk) begin
        regs <= regs_nxt;
    end
    
    for (genvar i = 1; i < CREG_NUM; i++) begin
        always_comb begin
            regs_nxt[i] = regs[i];
            if (self.rfwrite.valid && 
                self.rfwrite.id == i) begin
                regs_nxt[i] = self.rfwrite.data;
            end
        end
    end
    
    assign self.src1 = (self.ra1 == '0) ? 32'b0 : regs[self.ra1];
    assign self.src2 = (self.ra2 == '0) ? 32'b0 : regs[self.ra2];
endmodule
