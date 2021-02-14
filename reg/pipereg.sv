`include "interface.svh"
module pipereg
    import common::*; #(
    parameter type T = logic,
    parameter T INIT = '0
)(
    input logic clk, resetn,
    input T in, 
    output T out,
    input logic flush, en
);
    always_ff @(posedge clk) begin
        if (~resetn | flush) begin
            out <= INIT; 
        end else if (en) begin
            out <= in;
        end
    end
    
endmodule
