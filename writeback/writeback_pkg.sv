//  Package: writeback_pkg
//
package writeback_pkg;
    import common::*;
    import decode_pkg::*;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        decoded_instr_t instr;
        creg_addr_t writereg;
        word_t result;
        word_t hi, lo;
    } writeback_data_t;
    

    
endpackage: writeback_pkg
