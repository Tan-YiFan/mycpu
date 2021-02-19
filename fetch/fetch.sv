module fetch 
    import common::*;
    import fetch_pkg::*;(
    pcselect_intf.fetch pcselect,
    freg_intf.fetch freg,
    dreg_intf.fetch dreg,
    input instr_t raw_instr
);
    word_t pc, pcplus4F;
    // word_t raw_instr;

    assign pcplus4F = pc + 32'b100;

    fetch_data_t dataF;
    assign dataF.pcplus4 = pcplus4F;
    assign dataF.raw_instr = raw_instr;
    assign pc = freg.pc;
    assign dreg.dataF_new = dataF;
    assign pcselect.pcplus4 = pcplus4F;

endmodule
