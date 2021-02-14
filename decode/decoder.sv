`include "interface.svh"
module decoder 
    import common::*;
    import decode_pkg::*;(
    input instr_t raw_instr,
    input word_t pcplus4,
    output decoded_instr_t instr
);
    localparam type raw_op_t = logic[5:0];
    localparam type raw_func_t = logic[5:0];

    raw_op_t raw_op;
    assign raw_op = raw_instr[31:26];

    func_t raw_func;
    assign raw_func = raw_instr[5:0];
    creg_addr_t rs, rt, rd;
    assign rs = raw_instr[25:21];
    assign rt = raw_instr[20:15];
    assign rt = raw_instr[14:10];

    logic [15:0] imm;
    assign imm = raw_instr[15:0];

    control_t ctl;
    decoded_op_t op;
    assign instr.op = op;
    assign instr.ctl = ctl;
    assign instr.imm = 
    ctl.jump ? {pcplus4[31:28], raw_instr[25:0], 2'b0 }: 
    (ctl.shamt_valid ? {27'b0, raw_instr[10:6]} : 
    (ctl.zeroext ? {16'b0, raw_instr[15:0]} : 
    {{16{raw_instr[15]}}, raw_instr[15:0]}));
    logic exception_ri;
    assign instr.exception_ri = exception_ri;
    always_comb begin : ctl
        exception_ri = '0;
        ctl = '0;
        op = (decoded_op_t')0;
        unique case(raw_op)
            OP_RT: begin
                unique case(raw_func)
                    F_ADD: begin
                        op = ADD;
                        ctl.alufunc = ALU_ADD;
                        ctl.regwrite = 1'b1;
                    end
                    F_ADDU: begin
                        op = ADDU;
                        ctl.alufunc = ALU_ADDU;
                        ctl.regwrite = 1'b1;
                    end
                    F_SUB: begin
                        op = SUB;
                        ctl.alufunc = ALU_SUB;
                        ctl.regwrite = 1'b1;
                    end
                    F_SUBU: begin
                        op = SUBU;
                        ctl.alufunc = ALU_SUBU;
                        ctl.regwrite = 1'b1;
                    end
                    F_SLT: begin
                        op = SLT;
                        ctl.alufunc = ALU_SLT;
                        ctl.regwrite = 1'b1;
                    end
                    F_SLTU: begin
                        op = SLTU;
                        ctl.alufunc = ALU_SLTU;
                        ctl.regwrite = 1'b1;
                    end
                    F_DIV: begin
                        op = DIV;
                        ctl.hiwrite = 1'b1;
                        ctl.lowrite = 1'b1;
                        ctl.is_multdiv = 1'b1;
                    end
                    F_DIVU: begin
                        op = DIVU;
                        ctl.hiwrite = 1'b1;
                        ctl.lowrite = 1'b1;
                        ctl.is_multdiv = 1'b1;
                    end
                    F_MULT: begin
                        op = MULT;
                        ctl.hiwrite = 1'b1;
                        ctl.lowrite = 1'b1;
                        is_multdiv = 1'b1;
                    end
                    F_MULTU: begin
                        op = MULTU;
                        ctl.hiwrite = 1'b1;
                        ctl.lowrite = 1'b1;
                        ctl.is_multdiv = 1'b1;
                    end
                    F_AND: begin
                        op = AND;
                        ctl.alufunc = ALU_AND;
                        ctl.regwrite = 1'b1;
                    end
                    F_NOR: begin
                        op = NOR;
                        ctl.alufunc = ALU_NOR;
                        ctl.regwrite = 1'b1;
                    end
                    F_OR: begin
                        op = OR;
                        ctl.alufunc = ALU_OR;
                        ctl.regwrite = 1'b1;
                    end
                    F_XOR: begin
                        op = XOR;
                        ctl.alufunc = ALU_XOR;
                        ctl.regwrite = 1'b1;
                    end
                    F_SLLV: begin
                        op = SLLV;
                        ctl.alufunc = ALU_SLL;
                        ctl.regwrite = 1'b1;
                    end
                    F_SLL: begin
                        op = SLL;
                        ctl.alufunc = ALU_SLL;
                        ctl.regwrite = 1'b1;
                        ctl.shamt_valid = 1'b1;
                    end
                    F_SRAV: begin
                        op = SRAV;
                        ctl.alufunc = ALU_SRA;
                        ctl.regwrite = 1'b1;
                    end
                    F_SRA: begin
                        op = SRA;
                        ctl.alufunc = ALU_SRA;
                        ctl.regwrite = 1'b1;
                        ctl.shamt_valid = 1'b1;
                    end
                    F_SRLV: begin
                        op = SRLV;
                        ctl.alufunc = ALU_SRL;
                        ctl.regwrite = 1'b1;
                    end
                    F_SRL: begin
                        op = SRL;
                        ctl.alufunc = ALU_SRL;
                        ctl.regwrite = 1'b1;
                        ctl.shamt_valid = 1'b1;
                    end
                    F_JR: begin
                        op = JR;
                        ctl.jump = 1'b1;
                        ctl.jr = 1'b1;
                        ctl.alufunc = ALU_PASSA;
                    end
                    F_JALR: begin
                        op = JALR;
                        ctl.jump = 1'b1;
                        ctl.jr = 1'b1;
                        ctl.regwrite = 1'b1;
                        ctl.is_link = 'b1;
                        ctl.alufunc = ALU_PASSA;
                    end
                    F_MFHI: begin
                        op = MFHI;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_PASSA;
                        ctl.hitoreg = 1'b1;
                    end
                    F_MFLO: begin
                        op = MFLO;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_PASSB;
                        ctl.lotoreg = 1'b1;
                    end
                    F_MTHI: begin
                        op = MTHI;
                        ctl.hiwrite = 1'b1;
                        ctl.alufunc = ALU_PASSA;
                    end
                    F_MTLO: begin
                        op = MTLO;
                        ctl.lowrite = 1'b1;
                        ctl.alufunc = ALU_PASSA;
                    end
                    F_BREAK: begin
                        op = BREAK;
                        ctl.alufunc = ALU_PASSA;
                        ctl.is_bp = 1'b1;
                    end
                    F_SYSCALL: begin
                        op = SYSCALL;
                        ctl.alufunc = ALU_PASSA;
                        ctl.is_sys = 1'b1;
                    end
                    default: begin
                        exception_ri = 1'b1;
                        op = RESERVED;
                    end
                endcase
            end
            OP_ADDI: begin
                op = ADDI;
                ctl.alufunc = ALU_ADD;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
            end
            OP_ADDIU: begin
                op = ADDIU;
                ctl.alufunc = ALU_ADDU;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
            end
            OP_SLTI: begin
                op = SLTI;
                ctl.alufunc = ALU_SLT;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
            end
            OP_SLTIU: begin
                op = SLTIU;
                ctl.alufunc = ALU_SLTU;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
            end
            OP_ANDI: begin
                op = ANDI;
                ctl.alufunc = ALU_AND;
                ctl.regwrite = 1'b1;
                ctl.zeroext = 1'b1;
                ctl.alusrc = IMM;
            end
            OP_LUI: begin
                op = LUI;
                ctl.alufunc = ALU_LUI;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
            end
            OP_ORI: begin
                op = ORI;
                ctl.alufunc = ALU_OR;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
                ctl.zeroext = 1'b1;
            end
            OP_XORI: begin
                op = XORI;
                ctl.alufunc = ALU_XOR;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
                ctl.zeroext = 1'b1;
            end
            OP_BEQ: begin
                op = BEQ;
                ctl.branch = 1'b1;
                ctl.branch_type = T_BEQ;
            end
            OP_BNE: begin
                op = BNE;
                ctl.branch = 1'b1;
                ctl.branch_type = T_BNE;
            end
            OP_BGEZ: begin
                unique case (raw_instr[20:16])
                    `B_BGEZ:  begin
                        op = BGEZ;
                        ctl.branch = 1'b1;
                        ctl.branch_type = T_BGEZ;
                    end  
                    `B_BLTZ: begin
                        op = BLTZ;
                        ctl.branch = 1'b1;
                        ctl.branch_type = T_BLTZ;
                    end   
                    `B_BGEZAL: begin
                        op = BGEZAL;
                        ctl.branch = 1'b1;
                        ctl.regwrite = 1'b1;
                        ctl.branch_type = T_BGEZ;
                        ctl.is_link = 'b1;
                    end 
                    `B_BLTZAL: begin
                        op = BLTZAL;
                        ctl.branch = 1'b1;
                        ctl.regwrite = 1'b1;
                        ctl.branch_type = T_BLTZ;
                        ctl.is_link = 'b1;
                    end 
                    default: begin
                        exception_ri = 1'b1;
                        op = RESERVED;
                    end
                endcase
            end
            OP_BGTZ: begin
                op = BGTZ;
                ctl.branch = 1'b1;
                ctl.branch_type = T_BGTZ;
            end
            OP_BLEZ: begin
                op = BLEZ;
                ctl.branch = 1'b1;
                ctl.branch_type = T_BLEZ;
            end
            OP_J: begin
                op = J;
                ctl.jump = 1'b1;
            end
            OP_JAL: begin
                op = JAL;
                ctl.jump = 1'b1;
                ctl.regwrite = 1'b1;
                ctl.is_link = 'b1;
            end
            OP_LB: begin
                op = LB;
                ctl.regwrite = 1'b1;
                ctl.memread = 1'b1;
                ctl.alusrc = IMM;
            end
            OP_LBU: begin
                op = LBU;
                ctl.regwrite = 1'b1;
                ctl.memread = 1'b1;
                ctl.alusrc = IMM;
            end
            OP_LH: begin
                op = LH;
                ctl.regwrite = 1'b1;
                ctl.memread = 1'b1;
                ctl.alusrc = IMM;
            end
            OP_LHU: begin
                op = LHU;
                ctl.regwrite = 1'b1;
                ctl.memread = 1'b1;
                ctl.alusrc = IMM;
            end
            OP_LW: begin
                op = LW;
                ctl.regwrite = 1'b1;
                ctl.memread = 1'b1;
                ctl.alusrc = IMM;
            end
            OP_SB: begin
                op = SB;
                ctl.memwrite = 1'b1;
                ctl.alusrc = IMM;
            end
            OP_SH: begin
                op = SH;
                ctl.memwrite = 1'b1;
                ctl.alusrc = IMM;
            end
            OP_SW: begin
                op = SW;
                ctl.memwrite = 1'b1;
                ctl.alusrc = IMM;
            end
            OP_PRIV: begin
                case (raw_instr[25:21])
                    `C_MFC0: begin
                        op = MFC0;
                        ctl.alufunc = ALU_PASSA;
                        ctl.regwrite = 1'b1;
                    end 
                    `C_MTC0: begin
                        op = MTC0;
                        ctl.cp0write = 1'b1;
                        ctl.alufunc = ALU_PASSB;
                    end
                    default: begin
                        case (raw_instr[5: 0])
                            `C_ERET: begin
                                op = ERET;
                                ctl.is_eret = 1'b1;
                            end
                            default: begin
                                exception_ri = 1'b1;
                                op = RESERVED;
                            end
                        endcase
                    end
                endcase
            end

            default: begin
                exception_ri = 1'b1;
                op = RESERVED;
            end
        endcase
    end
    
    always_comb begin : srca
        instr.srca = rs;
        if (ctl.alufunc == ALU_PASSB) begin
            instr.srca = 7'b0;
        end
        if (ctl.is_bp || ctl.is_sys || exception_ri) begin
            instr.srca = '0;
        end
    end

    always_comb begin : srcb
        instr.srcb = ctl.alusrc == REGB ? rt : '0;
        if (ctl.alufunc == ALU_PASSA) begin
            instr.srcb = 7'b0;
        end
        if (ctl.memwrite | ctl.memtoreg) begin
            instr.srcb = rt;
        end
        if (ctl.cp0toreg) begin
            instr.srcb = rd;
        end
        if (ctl.is_bp || ctl.is_sys || exception_ri) begin
            instr.srcb = '0;
        end
    end
    
    always_comb begin : dest
        instr.dest = (raw_op != OP_RT) ? rt : rd;
        if (ctl.jump | ctl.branch) begin
            instr.dest = 5'b11111;
        end
        if (ctl.cp0write) begin
            instr.dest = rd;
        end
    end
endmodule
