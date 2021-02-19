
module multicycle
    import common::*; 
    import execute_pkg::*;(
    input logic clk, resetn,
    input word_t a, b,
    input logic is_multdiv,
    input logic flushE,
    input multicycle_t multicycle_type,
    output word_t hi, lo,
    output logic ok
);
    // multiplier
    word_t hi_m, lo_m;
    multiplier_top multiplier_top_inst (
        .clk, .resetn,
        .a, .b,
        .hi(hi_m), .lo(lo_m),
        .is_signed(multicycle_type == M_MULT)
    );
    // divider
    word_t hi_d, lo_d;
    divider_top divider_top_inst (
        .clk, .resetn,
        .a, .b,
        .hi(hi_d), .lo(lo_d),
        .is_signed(multicycle_type == M_DIV)
    );
    assign hi = (multicycle_type == M_MULT || multicycle_type == M_MULTU) ? hi_m : hi_d;
    assign lo = (multicycle_type == M_MULT || multicycle_type == M_MULTU) ? lo_m : lo_d;
    localparam MULT_DELAY = 1 << 5;
    localparam logic[35:0] DIV_DELAY = 1 << 34;
    localparam type state_t = enum logic {INIT, DOING};
    state_t state, state_new;
    logic [19:0] counter, counter_new;
    always_ff @(posedge clk) begin
        if (~resetn | flushE) begin
            state <= INIT;
            counter <= '0;
        end else begin
            state <= state_new;
            counter <= counter_new;
        end
    end

    always_comb begin : multicycle_counter
        state_new = state;
        counter_new = counter;
        case (state)
            INIT: begin
                if (is_multdiv) begin
                    case (multicycle_type)
                        M_MULTU: begin
                            counter_new = MULT_DELAY;
                            state_new = DOING;
                        end
                        M_MULT: begin
                            counter_new = MULT_DELAY;
                            state_new = DOING;
                        end
                        M_DIVU: begin
                            counter_new = DIV_DELAY;
                            state_new = DOING;
                        end
                        M_DIV: begin
                            counter_new = DIV_DELAY;
                            state_new = DOING;
                        end
                        default: begin

                        end
                    endcase
                end
            end
            DOING: begin
                counter_new = {1'b0, counter_new[35:1]};
                if (counter_new == 0) begin
                    state_new = INIT;
                end
            end
            default: begin

            end
        endcase
    end : multicycle_counter
    assign ok = state_new == INIT;
endmodule
