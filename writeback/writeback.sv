`include "interface.svh"
module writeback
    import common::*;
    import writeback_pkg::*;
    import decode_pkg::*; (
    wreg_intf.writeback wreg,
    regfile_intf.writeback regfile,
    hilo_intf.writeback hilo,
    hazard_intf.writeback hazard,
    forward_intf.writeback forward,
    // debug
    output word_t pc
);
    assign pc = wreg.dataM.pcplus4 - 4;
    word_t result;
    word_t readdataW;
    readdata readdata(
        ._rd(wreg.dataM.rd),
        .mem_type(wreg.dataM.instr.ctl.mem_type),
        .addr(wreg.dataM.aluout[1:0]),
        .rd(readdataW)
    );
    assign result = wreg.dataM.instr.ctl.memread ? 
                    readdataW : wreg.dataM.aluout;
    assign regfile.rfwrite.valid = wreg.dataM.instr.ctl.regwrite;
    assign regfile.rfwrite.id = wreg.dataM.writereg;
    assign regfile.rfwrite.data = result;

    decoded_op_t op;
    assign op = wreg.dataM.instr.op;
    assign hilo.hi_req.valid = (op == MTHI) || wreg.dataM.instr.ctl.is_multdiv;
    assign hilo.hi_req.data = (op == MTHI) ? result : wreg.dataM.hi;
    assign hilo.lo_req.valid = (op == MTLO) || wreg.dataM.instr.ctl.is_multdiv;
    assign hilo.lo_req.data = (op == MTLO) ? result : wreg.dataM.lo;
    
    writeback_data_t dataW;
    assign dataW.instr = wreg.dataM.instr;
    assign dataW.writereg = wreg.dataM.writereg;
    assign dataW.result = result;
    assign dataW.hi = wreg.dataM.hi;
    assign dataW.lo = wreg.dataM.lo;
    assign forward.dataW = dataW;

    assign hazard.dataW = dataW;

endmodule
