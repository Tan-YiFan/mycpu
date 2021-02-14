module decode
    import common::*; 
    import decode_pkg::*;(
    input logic clk, resetn,
    pcselect_intf.decode pcselect,
    dreg_intf.decode dreg,
    ereg_intf.decode ereg,
    regfile_intf.decode regfile
);
    decode_data_t dataD;

    word_t raw_instr;
    decoded_instr_t instr;
    decoder decoder_inst(
        .raw_instr,
        .instr,
        .pcplus4(dreg.pcplus4)
    );

    logic in_delay_slot;
    always_ff @(posedge clk) begin
        if (~resetn) begin
            in_delay_slot <= '0;
        end else if () begin
            in_delay_slot <= 
            instr.ctl.is_jump | instr.ctl.is_branch;
        end
    end
    
    logic branch_taken;
    word_t rd1, rd2;
    always_comb begin : branch_taken
        unique case(instr.ctl.branch_type)
            T_BEQ: begin
                branch_taken = rd1 == rd2;
            end
            T_BNE: begin
                branch_taken = rd1 != rd2;
            end
            T_BGEZ: begin
                branch_taken = rd1[31];
            end 
            T_BLTZ: begin
                branch_taken = rd1[31];
            end
            T_BGTZ: begin
                branch_taken = ~rd1[31] && (rd1 != '0);
            end
            T_BLEZ: begin
                branch_taken = rd1[31] || (rd1 == '0);
            end
            default: begin
                branch_taken = '0;
            end
        endcase
    end
    
    assign dataD.instr = instr;
    assign dataD.in_delay_slot = in_delay_slot;
    assign dataD.pcplus4 = dreg.pcplus4;
    assign dataD.rd1 = rd1;
    assign dataD.rd2 = rd2;

    assign ereg.dataD_new = dataD;

    assign pcselect.pcjump = {dreg.pcplus4[31:28], raw_instr[25:0], 2'b0};
    assign pcselect.pcbranch = dreg.pcplus4 + {instr.imm[29:0], 2'b00};
    assign pcselect.branch_taken = branch_taken;
    assign pcselect.is_jr = instr.ctl.is_jr;
    assign pcselect.is_jump = instr.ctl.is_jump;

    assign regfile.ra1 = instr.srca;
    assign regfile.ra2 = instr.srcb;
endmodule
