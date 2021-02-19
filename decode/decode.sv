module decode
    import common::*; 
    import decode_pkg::*;
    import forward_pkg::*;(
    input logic clk, resetn,
    pcselect_intf.decode pcselect,
    dreg_intf.decode dreg,
    ereg_intf.decode ereg,
    regfile_intf.decode regfile,
    forward_intf.decode forward,
    hazard_intf.decode hazard
);
    decode_data_t dataD;

    word_t raw_instr;
    assign raw_instr = dreg.dataF.raw_instr;
    decoded_instr_t instr;
    decoder decoder_inst(
        .raw_instr,
        .instr,
        .pcplus4(dreg.dataF.pcplus4)
    );

    logic in_delay_slot;
    always_ff @(posedge clk) begin
        if (~resetn | hazard.flushD) begin
            in_delay_slot <= '0;
        end else if (~hazard.stallD) begin
            in_delay_slot <= 
            instr.ctl.jump | instr.ctl.branch;
        end
    end
    
    logic branch_taken;
    word_t rd1, rd2;
    always_comb begin : forwardAD
        unique case(forward.forwardAD)
            FORWARDM: begin
                rd1 = forward.dataM.aluout;
            end
            FORWARDW: begin
                rd1 = forward.dataW.result;
            end
            default: begin
                rd1 = regfile.src1;
            end
        endcase
    end : forwardAD
    always_comb begin : forwardBD
        unique case(forward.forwardBD)
            FORWARDM: begin
                rd2 = forward.dataM.aluout;
            end
            FORWARDW: begin
                rd2 = forward.dataW.result;
            end
            default: begin
                rd2 = regfile.src2;
            end
        endcase
    end : forwardBD
    always_comb begin : branch
        branch_taken = '0;
        if (instr.ctl.branch) begin
            unique case(instr.ctl.branch_type)
                T_BEQ: begin
                    branch_taken = rd1 == rd2;
                end
                T_BNE: begin
                    branch_taken = rd1 != rd2;
                end
                T_BGEZ: begin
                    branch_taken = ~rd1[31];
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
        
    end
    
    assign dataD.instr = instr;
    assign dataD.in_delay_slot = in_delay_slot;
    assign dataD.pcplus4 = dreg.dataF.pcplus4;
    assign dataD.rd1 = rd1;
    assign dataD.rd2 = rd2;

    assign ereg.dataD_new = dataD;

    assign pcselect.pcjump = {dreg.dataF.pcplus4[31:28], raw_instr[25:0], 2'b0};
    assign pcselect.pcjr = rd1;
    assign pcselect.pcbranch = dreg.dataF.pcplus4 + {instr.imm[29:0], 2'b00};
    assign pcselect.branch_taken = branch_taken;
    assign pcselect.is_jr = instr.ctl.jr;
    assign pcselect.is_jump = instr.ctl.jump;

    assign regfile.ra1 = instr.srca;
    assign regfile.ra2 = instr.srcb;

    assign forward.dataD = dataD;
    assign hazard.dataD = dataD;
endmodule
