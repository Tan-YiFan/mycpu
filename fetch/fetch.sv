module fetch 
    import common::*;(
    pcselect_intf.fetch pcselect,
    freg_intf.fetch freg,
    dreg_intf.fetch dreg
);
    word_t pc, pcplus4F;
    word_t raw_instr;

    assign pcplus4F = pc + 32'b100;

    assign pc = freg.pc;
    assign dreg.pcplus4_new = pcplus4F;
    assign pcselect.pcplus4 = pcplus4F;

endmodule
