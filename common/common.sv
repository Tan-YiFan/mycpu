//  Package: common
//
package common;
    //  Group: Parameters
    
    parameter CREG_NUM = 32;
    parameter PCINIT = 32'hbfc0_0000;

    //  Group: Typedefs
    typedef logic[31:0] word_t;
    typedef logic[31:0] vaddr_t;
    typedef logic[31:0] paddr_t;
    typedef logic[63:0] dword_t;
    typedef logic[31:0] instr_t;
    
    
    typedef logic[$clog2(CREG_NUM)-1:0] creg_addr_t;
    typedef enum logic[4:0] {
        ALU_ADDU, ALU_AND, ALU_OR, ALU_ADD, ALU_SLL, 
        ALU_SRL, ALU_SRA, ALU_SUB, ALU_SLT, ALU_NOR, 
        ALU_XOR, ALU_SUBU, ALU_SLTU, ALU_PASSA, ALU_LUI, 
        ALU_PASSB, ALU_MOVN, ALU_MOVZ
    } alufunc_t;
    typedef enum logic[1:0] { REGB, IMM} alusrcb_t;
    typedef enum logic[2:0] { T_BEQ, T_BNE, T_BGEZ, T_BLTZ, T_BGTZ, T_BLEZ } branch_t;
    typedef enum logic [1:0] {
        M_MULT, M_MULTU, M_DIV, M_DIVU
    } multicycle_t;
    typedef enum logic [2:0] {
        MEM_LB, MEM_LBU, 
        MEM_LH, MEM_LHU,
        MEM_LW,
        MEM_SB,
        MEM_SH,
        MEM_SW
    } mem_t;
    
    
    
    typedef struct packed {
        logic valid;
        word_t data;
    } hilo_write_req;
    typedef struct packed {
        logic valid;
        creg_addr_t id;
        word_t data;
    } creg_write_req;
    typedef struct packed {
        logic valid;
        vaddr_t addr;
        word_t data;
        logic[1:0] size;
    } mem_write_req;
    typedef struct packed {
        logic valid;
        vaddr_t addr;
        logic[1:0] size;
    } mem_read_req;
    
    
    
endpackage: common
