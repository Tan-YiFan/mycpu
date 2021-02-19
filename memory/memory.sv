`include "interface.svh"
module memory
    import common::*;
    import memory_pkg::*; (
    output mem_read_req mread,
    output mem_write_req mwrite,
    input word_t rd,
    mreg_intf.memory mreg,
    wreg_intf.memory wreg,
    forward_intf.memory forward,
    hazard_intf.memory hazard
);
    assign mread.valid = mreg.dataE.instr.ctl.memread;
    assign mread.addr = mreg.dataE.aluout;
    assign mread.size = mreg.dataE.instr.ctl.mem_size;
    
    assign mwrite.valid = mreg.dataE.instr.ctl.memwrite;
    assign mwrite.addr = mreg.dataE.aluout;
    // assign mwrite.data = 
    writedata writedata(
        .addr(mwrite.addr[1:0]), 
        ._wd(mreg.dataE.writedata), 
        .mem_type(mreg.dataE.instr.ctl.mem_type), 
        .wd(mwrite.data)
    );
    assign mwrite.size = mreg.dataE.instr.ctl.mem_size;

    memory_data_t dataM;
    assign dataM.instr = mreg.dataE.instr;
    assign dataM.rd = rd;
    assign dataM.aluout = mreg.dataE.aluout;
    assign dataM.writereg = mreg.dataE.writereg;
    assign dataM.hi = mreg.dataE.hi;
    assign dataM.lo = mreg.dataE.lo;
    assign dataM.pcplus4 = mreg.dataE.pcplus4;
    
    assign wreg.dataM_new = dataM;

    assign forward.dataM = dataM;
    assign hazard.dataM = dataM;

endmodule
