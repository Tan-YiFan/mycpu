
module divider_top
    import common::*;(
    input logic clk, resetn,
    input word_t a, b,
    input logic is_signed,
    output word_t hi, lo
);

    dword_t out;
    word_t a_u, b_u;
    // divider_u divider_u(.clk, .resetn(reset), .flush, .valid, .a_in(a_u), .b_in(b_u), .out);
    div_gen_0 div_gen_0(
        .aclk(clk),
        .s_axis_divisor_tvalid(1'b1), 
        .s_axis_divisor_tdata(a), 
        .s_axis_dividend_tvalid(1'b1), 
        .s_axis_dividend_tdata(b), 
        // .m_axis_dout_tvalid, 
        .m_axis_dout_tdata(out)
    );
    assign a_u = (is_signed & a[31]) ? -a:a;
    assign b_u = (is_signed & b[31]) ? -b:b;

    /* |b| = |aq| + |r|
    *   1) b > 0, a < 0 ---> b = (-a)(-q) + r
    *   2) b < 0, a > 0 ---> -b = a(-q) + (-r) */
    assign lo = (is_signed & (a[31] ^ b[31])) ? -out[31:0] : out[31:0];
    assign hi = (is_signed & (a[31] ^ out[63])) ? -out[63:32] : out[63:32];
    
endmodule
