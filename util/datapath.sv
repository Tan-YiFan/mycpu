module datapath
    import common::*;
    import fetch_pkg::*;
    import decode_pkg::*;
    import execute_pkg::*;
    import memory_pkg::*;
    import writeback_pkg::*; (
    input logic clk, resetn,
    input logic[5:0] ext_int,
    
    output word_t pc,
    input word_t raw_instr,

    output mem_read_req mread,
    output mem_write_req mwrite,
    output creg_write_req rfwrite,
    input word_t rd,
    output word_t wb_pc,
    
    input logic i_data_ok, d_data_ok
);
    // interfaces
    pcselect_intf pcselect_intf();
    freg_intf freg_intf(.pc);
    dreg_intf dreg_intf();
    ereg_intf ereg_intf();
    mreg_intf mreg_intf();
    wreg_intf wreg_intf();
    regfile_intf regfile_intf(.rfwrite);
    hilo_intf hilo_intf();
    // cp0_intf cp0_intf();
    forward_intf forward_intf();
    hazard_intf hazard_intf(.i_data_ok, .d_data_ok);
    // exception_intf exception_intf(.ext_int);

    // instances
    pcselect pcselect(
        .self(pcselect_intf.pcselect),
        .freg(freg_intf.pcselect)
    );
    fetch fetch(
        .pcselect(pcselect_intf.fetch),
        .freg(freg_intf.fetch),
        .dreg(dreg_intf.fetch),
        .raw_instr
    );
    decode decode(
        .clk, .resetn,
        .pcselect(pcselect_intf.decode),
        .dreg(dreg_intf.decode),
        .ereg(ereg_intf.decode),
        .forward(forward_intf.decode),
        .hazard(hazard_intf.decode),
        .regfile(regfile_intf.decode)
    );
    execute execute(
        .clk, .resetn,
        .ereg(ereg_intf.execute),
        .mreg(mreg_intf.execute),
        .forward(forward_intf.execute),
        .hazard(hazard_intf.execute)
    );
    memory memory(
        .mread, .mwrite, .rd,
        .mreg(mreg_intf.memory),
        .wreg(wreg_intf.memory),
        .forward(forward_intf.memory),
        .hazard(hazard_intf.memory)
    );
    writeback writeback(
        .wreg(wreg_intf.writeback),
        .regfile(regfile_intf.writeback),
        .hilo(hilo_intf.writeback),
        .hazard(hazard_intf.writeback),
        .forward(forward_intf.writeback),
        .pc(wb_pc)
    );
    hazard hazard (
        .self(hazard_intf.hazard)
    );
    forward forward(
        .self(forward_intf.forward)
    );
    regfile regfile (
        .clk,
        .self(regfile_intf.regfile)
    );

    hilo hilo (
        .clk,
        .self(hilo_intf.hilo)
    );
    pipereg #(.T(word_t), .INIT(PCINIT)) freg(
        .clk, .resetn,
        .in(freg_intf.freg.pc_new),
        .out(freg_intf.freg.pc),
        .flush(1'b0),
        .en(~hazard_intf.stallF)
    );

    pipereg #(.T(fetch_data_t)) dreg (
        .clk, .resetn,
        .in(dreg_intf.dreg.dataF_new),
        .out(dreg_intf.dreg.dataF),
        .flush(hazard_intf.flushD),
        .en(~hazard_intf.stallD)
    );

    pipereg #(.T(decode_data_t)) ereg (
        .clk, .resetn,
        .in(ereg_intf.ereg.dataD_new),
        .out(ereg_intf.ereg.dataD),
        .flush(hazard_intf.flushE),
        .en(~hazard_intf.stallE)
    );

    pipereg #(.T(execute_data_t)) mreg (
        .clk, .resetn,
        .in(mreg_intf.mreg.dataE_new),
        .out(mreg_intf.mreg.dataE),
        .flush(hazard_intf.flushM),
        .en(~hazard_intf.stallM)
    );

    pipereg #(.T(memory_data_t)) wreg (
        .clk, .resetn,
        .in(wreg_intf.wreg.dataM_new),
        .out(wreg_intf.wreg.dataM),
        .flush(hazard_intf.flushW),
        .en(1'b1)
    );
endmodule
