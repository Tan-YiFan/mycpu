`ifndef __INTERFACE_SVH
`define __INTERFACE_SVH

import common::*;
interface pcselect_intf();
    logic exception_valid, is_eret, branch_taken, is_jr,
          is_jump;

    word_t pcexception, pc_eret, pcbranch, pcjr,
           pcjump, pcplus4;

    modport pcselect(input exception_valid, is_eret, branch_taken,
                           is_jr, is_jump,
                           pcexception, pc_eret, pcbranch, pcjr,
                           pcjump, pcplus4);
    modport fetch(output pcplus4);
    modport decode(output pcjump, pcbranch, pcjr, branch_taken, 
                          is_jr, is_jump);
    
endinterface

interface freg_intf(output word_t pc);
    word_t pc_new;
    modport pcselect(output pc_new);
    modport freg(input pc_new, output pc);
    modport fetch(input pc);
endinterface

interface dreg_intf();
    // word_t pcplus4, pcplus4_new;
    import fetch_pkg::*;
    fetch_data_t dataF_new, dataF;
    modport fetch(output dataF_new);
    modport dreg(input dataF_new, output dataF);
    modport decode(input dataF);
    
endinterface

interface ereg_intf();
    import decode_pkg::*;
    decode_data_t dataD_new, dataD;
    modport decode(output dataD_new);
    modport ereg(input dataD_new, output dataD);
    modport execute(input dataD);
    
endinterface

interface mreg_intf();
    import execute_pkg::*;
    execute_data_t dataE_new, dataE;
    modport execute(output dataE_new);
    modport mreg(input dataE_new, output dataE);
    modport memory(input dataE);
    
endinterface

interface wreg_intf();
    import memory_pkg::*;
    memory_data_t dataM_new, dataM;
    modport memory(output dataM_new);
    modport wreg(input dataM_new, output dataM);
    modport writeback(input dataM);
    
endinterface

interface forward_intf();
    import forward_pkg::*;
    forward_t forwardAD;
    forward_t forwardBD;
    forward_t forwardAE;
    forward_t forwardBE;

    import decode_pkg::*;
    import execute_pkg::*;
    import memory_pkg::*;
    import writeback_pkg::*;
    decode_data_t dataD;
    execute_data_t dataE;
    memory_data_t dataM;
    writeback_data_t dataW;

    modport forward(output forwardAD, forwardBD, forwardAE, forwardBE,
                 input dataD, dataE, dataM, dataW);
    modport decode(input forwardAD, forwardBD, dataE, dataM, dataW,
                   output dataD);
    modport execute(input forwardAE, forwardBE, dataM, dataW,
                    output dataE);
    modport memory(output dataM);
    modport writeback(output dataW);

endinterface

interface regfile_intf(output creg_write_req rfwrite);
    creg_addr_t ra1, ra2;
    word_t src1, src2;
    modport regfile(input ra1, ra2, rfwrite, output src1, src2);
    modport decode(input src1, src2, output ra1, ra2);
    modport writeback(output rfwrite);
endinterface

interface hilo_intf();
    word_t hi, lo;
    hilo_write_req hi_req, lo_req;
    modport hilo(input hi_req, lo_req, output hi, lo);
    modport decode(input hi, lo);
    modport writeback(output hi_req, lo_req);
endinterface

interface hazard_intf(input logic i_data_ok, d_data_ok);
    import common::*;

    logic stallF, stallD, stallE, stallM, 
                  flushD, flushE, flushM, flushW;

    import decode_pkg::*;
    import execute_pkg::*;
    import memory_pkg::*;
    import writeback_pkg::*;
    decode_data_t dataD;
    execute_data_t dataE;
    memory_data_t dataM;
    writeback_data_t dataW;

    modport hazard(output stallF, stallD, stallE, stallM, 
                        flushD, flushE, flushM, flushW,
                 input dataD, dataE, dataM, dataW, i_data_ok, d_data_ok);
    modport decode(output dataD, input stallD, flushD);
    modport execute(output dataE);
    modport memory(output dataM);
    modport writeback(output dataW);
endinterface
`endif
