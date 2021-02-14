//  Package: decode_pkg
//
package decode_pkg;
    import common::*;

    //  Group: Typedefs
    typedef struct packed {
        alufunc_t alufunc;
        logic memread, memwrite;
        logic regwrite;
        alusrcb_t alusrc;
        logic is_branch;
        branch_t branch_type;
        logic jump;
        logic jr;
        logic shamt_valid;
        logic zeroext;
        logic cp0write;
        logic is_eret;
        logic hiwrite;
        logic lowrite;
        logic is_bp;
        logic is_sys;
        logic is_link;
        logic is_multdiv;
        logic is_eret;
    } control_t;
    typedef enum logic [6: 0] { 
        ADDI, ADDIU, SLTI, SLTIU, ANDI, ORI, XORI, 
        ADDU, RESERVED, BEQ, BNE, BGEZ, BGTZ, BLEZ, BLTZ, BGEZAL, BLTZAL, 
        J, JAL, LB, LBU, LH, LHU, LW, SB, SH, SW, 
        MFC0, MTC0, ADD, SUB, SUBU, SLT, SLTU, DIV, DIVU, MULT, 
        MULTU, AND, NOR, OR, XOR, SLLV, SLL, SRAV, SRA, SRLV, 
        SRL, JR, JALR, MFHI, MFLO, MTHI, MTLO, BREAK, SYSCALL, LUI, 
        ERET, CLO, CLZ, MOVN, MOVZ, MADD, MADDU, MSUB, MSUBU, MUL,
        LL, SC, LWL, LWR, SWL, SWR, WAIT_EX, TLBR, TLBP, TLBWI, 
        CACHE
    } decoded_op_t;//64 left
    typedef struct packed {
        decoded_op_t op;
        word_t extended_imm;
        control_t ctl;
    } decoded_instr_t;
    
    typedef struct packed {
        decoded_instr_t instr;
        creg_addr_t srca, 
                    srcb, 
                    dest;
        logic in_delay_slot;
    } decode_data_t;

    //  Group: Parameters
    parameter logic [5:0] OP_RT       =    6'b000000;
    parameter logic [5:0] OP_ADDI     =    6'b001000;
    parameter logic [5:0] OP_ADDIU    =    6'b001001;
    parameter logic [5:0] OP_SLTI     =    6'b001010;
    parameter logic [5:0] OP_SLTIU    =    6'b001011;
    parameter logic [5:0] OP_ANDI     =    6'b001100;
    parameter logic [5:0] OP_LUI      =    6'b001111;
    parameter logic [5:0] OP_ORI      =    6'b001101;
    parameter logic [5:0] OP_XORI     =    6'b001110;
    parameter logic [5:0] OP_BEQ      =    6'b000100;
    parameter logic [5:0] OP_BNE      =    6'b000101;
    parameter logic [5:0] OP_BGEZ     =    6'b000001;
    parameter logic [5:0] OP_BGTZ     =    6'b000111;
    parameter logic [5:0] OP_BLEZ     =    6'b000110;
    parameter logic [5:0] OP_J        =    6'b000010;
    parameter logic [5:0] OP_JAL      =    6'b000011;
    parameter logic [5:0] OP_LB       =    6'b100000;
    parameter logic [5:0] OP_LBU      =    6'b100100;
    parameter logic [5:0] OP_LH       =    6'b100001;
    parameter logic [5:0] OP_LHU      =    6'b100101;
    parameter logic [5:0] OP_LW       =    6'b100011;
    parameter logic [5:0] OP_SB       =    6'b101000;
    parameter logic [5:0] OP_SH       =    6'b101001;
    parameter logic [5:0] OP_SW       =    6'b101011;
    parameter logic [5:0] OP_PRIV     =    6'b010000;
    parameter logic [5:0] OP_MUL      =    6'b011100;
    parameter logic [5:0] OP_LL       =    6'b110000;
    parameter logic [5:0] OP_SC       =    6'b111000;
    parameter logic [5:0] OP_TLB      =    6'b010000;
    parameter logic [5:0] OP_LWL      =    6'b100010;
    parameter logic [5:0] OP_LWR      =    6'b100110;
    parameter logic [5:0] OP_SWL      =    6'b101010;
    parameter logic [5:0] OP_SWR      =    6'b101110;
    parameter logic [5:0] OP_CACHE    =    6'b101111;

    parameter logic [5:0] F_ADD       =    6'b100000;
    parameter logic [5:0] F_ADDU      =    6'b100001;
    parameter logic [5:0] F_SUB       =    6'b100010;
    parameter logic [5:0] F_SUBU      =    6'b100011;
    parameter logic [5:0] F_SLT       =    6'b101010;
    parameter logic [5:0] F_SLTU      =    6'b101011;
    parameter logic [5:0] F_DIV       =    6'b011010;
    parameter logic [5:0] F_DIVU      =    6'b011011;
    parameter logic [5:0] F_MULT      =    6'b011000;
    parameter logic [5:0] F_MULTU     =    6'b011001;
    parameter logic [5:0] F_AND       =    6'b100100;
    parameter logic [5:0] F_NOR       =    6'b100111;
    parameter logic [5:0] F_OR        =    6'b100101;
    parameter logic [5:0] F_XOR       =    6'b100110;
    parameter logic [5:0] F_SLLV      =    6'b000100;
    parameter logic [5:0] F_SLL       =    6'b000000;
    parameter logic [5:0] F_SRAV      =    6'b000111;
    parameter logic [5:0] F_SRA       =    6'b000011;
    parameter logic [5:0] F_SRLV      =    6'b000110;
    parameter logic [5:0] F_SRL       =    6'b000010;
    parameter logic [5:0] F_JR        =    6'b001000;
    parameter logic [5:0] F_JALR      =    6'b001001;
    parameter logic [5:0] F_MFHI      =    6'b010000;
    parameter logic [5:0] F_MFLO      =    6'b010010;
    parameter logic [5:0] F_MTHI      =    6'b010001;
    parameter logic [5:0] F_MTLO      =    6'b010011;
    parameter logic [5:0] F_BREAK     =    6'b001101;
    parameter logic [5:0] F_SYSCALL   =    6'b001100;
    parameter logic [5:0] F_MOVZ      =    6'b001010;
    parameter logic [5:0] F_MOVN      =    6'b001011;
    
    parameter logic [5:0] M_MUL       =    6'b011000;
    parameter logic [5:0] M_CLO       =    6'b100001;
    parameter logic [5:0] M_CLZ       =    6'b100000;
    parameter logic [5:0] M_ADD       =    6'b000000;
    parameter logic [5:0] M_ADDU      =    6'b000001;
    parameter logic [5:0] M_SUB       =    6'b000100;
    parameter logic [5:0] M_SUBU      =    6'b000101;
    
    parameter logic [4:0] B_BGEZ      =    5'b00001;
    parameter logic [4:0] B_BLTZ      =    5'b00000;
    parameter logic [4:0] B_BGEZAL    =    5'b10001;
    parameter logic [4:0] B_BLTZAL    =    5'b10000;
    
    parameter logic [4:0] C_MFC0      =    5'b00000;
    parameter logic [4:0] C_MTC0      =    5'b00100;
    parameter logic [5:0] C_ERET      =    6'b011000;
    parameter logic [5:0] C_WAIT      =    6'b100000;
    parameter logic [5:0] C_TLBR      =    6'b000001;
    parameter logic [5:0] C_TLBP      =    6'b001000;
    parameter logic [5:0] C_TLBWI     =    6'b000010;
    
    
    
endpackage: decode_pkg
