`include "interface.svh"
module hazard 
    import common::*;(
    hazard_intf.hazard self
);
    logic regwriteE, memreadM, memreadE;
    creg_addr_t writeregE, writeregM;
    assign regwriteE = self.dataE.instr.ctl.regwrite;
    assign memreadM = self.dataM.instr.ctl.memread;
    assign memreadE = self.dataE.instr.ctl.memread;
    assign writeregE = self.dataE.writereg;
    assign writeregM = self.dataM.writereg;
    
    logic lwstall;
    assign lwstall = ((self.dataD.instr.srca == writeregE || self.dataD.instr.srcb == writeregE) && memreadE && writeregE != '0) || 
                     ((self.dataD.instr.srca == writeregM || self.dataD.instr.srcb == writeregM) && memreadM && writeregM != '0);

    logic branchstall;
    assign branchstall = (self.dataD.instr.ctl.branch | self.dataD.instr.ctl.jump) &&
                         ((regwriteE && writeregE == self.dataD.instr.srca && writeregE != '0) ||
                         (memreadM && writeregM == self.dataD.instr.srca && writeregM != '0) || (
                             (self.dataD.instr.ctl.branch_type == T_BEQ || self.dataD.instr.ctl.branch_type == T_BNE) && (
                                (regwriteE && writeregE == self.dataD.instr.srcb && writeregE != '0) ||
                                (memreadM && writeregM == self.dataD.instr.srcb && writeregM != '0)
                             )
                         ));

    logic i_data_ok, d_data_ok;
    assign i_data_ok = self.i_data_ok;
    assign d_data_ok = self.d_data_ok;

    assign self.stallF = ~i_data_ok | ~d_data_ok | lwstall | branchstall;
    assign self.stallD = ~i_data_ok | ~d_data_ok | lwstall | branchstall;
    assign self.stallE = ~d_data_ok;
    assign self.stallM = ~d_data_ok;

    assign self.flushD = 1'b0;
    assign self.flushE = lwstall | branchstall | ~i_data_ok;
    assign self.flushM = 1'b0;
    assign self.flushW = ~d_data_ok;
endmodule
