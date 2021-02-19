`include "interface.svh"
module execute 
    import common::*;
    import execute_pkg::*;
    import forward_pkg::*;(
    input logic clk, resetn,
    ereg_intf.execute ereg,
    mreg_intf.execute mreg,
    forward_intf.execute forward,
    hazard_intf.execute hazard
);
    
    logic exception_of;
    word_t aluout;
    word_t alusrca, alusrcb, writedata;
    always_comb begin : forwardAE
        unique case(forward.forwardAE)
            FORWARDM: begin
                alusrca = forward.dataM.aluout;
            end
            default: begin
                alusrca = ereg.dataD.rd1;
            end
        endcase
    end : forwardAE
    always_comb begin : forwardBE
        unique case(forward.forwardBE)
            FORWARDM: begin
                writedata = forward.dataM.aluout;
            end
            default: begin
                writedata = ereg.dataD.rd2;
            end
        endcase
    end : forwardBE
    assign alusrcb = ereg.dataD.instr.ctl.alusrc == REGB ? 
                     writedata : ereg.dataD.instr.imm;
    alu alu_inst (
        .a(~ereg.dataD.instr.ctl.shamt_valid ? alusrca : ereg.dataD.instr.imm),
        .b(alusrcb),
        .c(aluout),
        .alufunc(ereg.dataD.instr.ctl.alufunc),
        .exception_of
    );
    word_t hi, lo;
    multicycle multicycle_inst (
        .clk, .resetn,
        .a(alusrca),
        .b(alusrcb),
        .is_multdiv(ereg.dataD.instr.ctl.is_multdiv),
        .flushE(1'b0),
        .multicycle_type(ereg.dataD.instr.ctl.multicycle_type),
        .hi,
        .lo
    );
    execute_data_t dataE;
    assign dataE.instr = ereg.dataD.instr;
    assign dataE.exception_instr = ereg.dataD.exception_instr;
    assign dataE.exception_ri = ereg.dataD.instr.exception_ri;
    assign dataE.exception_of = exception_of;
    assign dataE.aluout = (ereg.dataD.instr.ctl.is_link) ? (ereg.dataD.pcplus4 + 4) : aluout;
    assign dataE.writereg = ereg.dataD.instr.dest;
    assign dataE.writedata = writedata;
    assign dataE.hi = hi;
    assign dataE.lo = lo;
    assign dataE.pcplus4 = ereg.dataD.pcplus4;
    assign dataE.in_delay_slot = ereg.dataD.in_delay_slot;
    
    assign mreg.dataE_new = dataE;

    assign hazard.dataE = dataE;
    assign forward.dataE = dataE;
endmodule
