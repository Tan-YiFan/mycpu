module hilo 
    import common::*;(
    input logic clk, 
    output word_t hi, lo,
    input hilo_write_req hi_req, lo_req
);
    always_ff @(posedge clk) begin
        if (hi_req.valid) begin
            hi <= hi_req.data;
        end
    end

    always_ff @(posedge clk) begin
        if (lo_req.valid) begin
            lo <= lo_req.data;
        end
    end
endmodule
