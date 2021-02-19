`include "interface.svh"
module pcselect
    import common::*; (
    pcselect_intf.pcselect self,
    freg_intf.pcselect freg
);
    assign freg.pc_new = // self.exception_valid ? self.pcexception   : 
                         // self.is_eret         ? self.pc_eret       : 
                         self.branch_taken    ? self.pcbranch      :
                         self.is_jr           ? self.pcjr          :
                         self.is_jump         ? self.pcjump        : self.pcplus4;

endmodule
