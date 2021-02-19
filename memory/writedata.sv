module writedata 
    import common::*;(
    input logic[1:0] addr,
    input word_t _wd,
    input mem_t mem_type,
    output word_t wd
);
    always_comb begin
        case (mem_type)
            MEM_SW : begin
                wd = _wd;
            end 
            MEM_SH: begin
                case (addr[1])
                    1'b0: begin
                        wd = _wd;
                    end 
                    1'b1: begin
                        wd = {_wd[15:0], 16'b0};
                    end
                    default: begin
                        wd = 'b0;
                    end
                endcase
            end
            MEM_SB: begin
                case (addr)
                    2'b00: begin
                        wd = _wd;
                    end 
                    2'b01: begin
                        wd = {_wd[23:0], 8'b0};
                    end 
                    2'b10: begin
                        wd = {_wd[15:0], 16'b0};
                    end 
                    2'b11: begin
                        wd = {_wd[7:0], 24'b0};
                    end 
                    default: begin
                        wd = 'b0;
                    end
                endcase
            end
            default: begin
                wd = '0;
            end
        endcase
    end
endmodule
