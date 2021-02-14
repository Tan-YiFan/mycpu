
module mycpu 
    import common::*;(
    input logic clk,
    input logic resetn,  //low active
    input logic[5:0] ext_int,  //interrupt,high active

    output logic inst_req, data_req,
    output logic inst_wr, data_wr,
    output logic [1:0]inst_size, data_size,
    output word_t inst_addr, data_addr,
    output word_t inst_wdata, data_wdata,
    input word_t inst_rdata, data_rdata,
    input logic inst_addr_ok, data_addr_ok,
    input logic inst_data_ok, data_data_ok,

    //debug
    output word_t debug_wb_pc,
    output rwen_t debug_wb_rf_wen,
    output creg_addr_t debug_wb_rf_wnum,
    output word_t debug_wb_rf_wdata
);
    mem_read_req mread;
    mem_write_req mwrite;
    creg_write_req rfwrite;
    vaddr_t vaddr;
    datapath datapath(.clk, .resetn, .ext_int, 
                      .pc(inst_addr), .raw_instr(inst_rdata),
                      .mread, .mwrite, .rfwrite, .rd(data_rdata), .wb_pc(debug_wb_pc),
                      .i_data_ok, .d_data_ok);
    assign inst_req = 1'b1;
    assign inst_wr = 1'b0;
    assign inst_size = 2'b10;
    assign inst_wdata = '0;
    assign data_req = mread.valid | mwrite.valid;
    assign data_wr = mwrite.valid;
    assign vaddr = (mwrite.valid) ? mwrite.addr : mread.addr;
    always_comb begin
        case (vaddr[31:28])
            4'h8: data_addr[31:28] = 4'b0;
            4'h9: data_addr[31:28] = 4'b1;
            4'ha: data_addr[31:28] = 4'b0;
            4'hb: data_addr[31:28] = 4'b1;
            default: begin
                data_addr[31:28] = vaddr[31:28];
            end
        endcase
    end
    assign data_addr[27:0] = vaddr[27:0];
    assign data_wdata = mwrite.wd;
    assign data_size = mwrite.valid ? mwrite.size : mread.size;
    assign debug_wb_rf_wen = {4{rfwrite.valid && (rfwrite.id != '0)}};
    assign debug_wb_rf_wnum = rfwrite.id;
    assign debug_wb_rf_wdata = rfwrite.data;
endmodule
