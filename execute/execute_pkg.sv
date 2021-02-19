//  Package: execute_pkg
//
package execute_pkg;
    import common::*;
    import decode_pkg::*;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        decoded_instr_t instr;
        logic exception_instr, exception_ri, exception_of;
        word_t aluout;
        creg_addr_t writereg;
        word_t writedata;
        word_t hi, lo;
        word_t pcplus4;
        logic in_delay_slot;
        // cp0_cause_t cp0_cause;
        // cp0_status_t cp0_status;
    } execute_data_t;
    

    
endpackage: execute_pkg

