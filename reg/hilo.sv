module hilo 
    import common::*;(
    input logic clk, 
    // output word_t hi, lo,
    // input hilo_write_req hi_req, lo_req
    hilo_intf.hilo self
);
    always_ff @(posedge clk) begin
        if (self.hi_req.valid) begin
            self.hi <= self.hi_req.data;
        end
    end

    always_ff @(posedge clk) begin
        if (self.lo_req.valid) begin
            self.lo <= self.lo_req.data;
        end
    end
endmodule
