module w_pointer #(
    parameter int ADDR_SIZE = 4
)(
    output logic [ADDR_SIZE-1:0] waddr,        // Write address
    output logic [ADDR_SIZE:0]   wptr,         // Write pointer (gray code)
    output logic [ADDR_SIZE:0]   wbin,         // Binary write pointer
    output logic [ADDR_SIZE:0]   wgray_next,   // Next gray pointer (for full detection)
    input  logic                 winc,         // Write increment
    input  logic                 wfull,        // FIFO full flag
    input  logic                 wclk,         // Write clock
    input  logic                 wrst_n        // Write reset (active-low)
);

    logic [ADDR_SIZE:0] wbin_reg;              // Binary write pointer register
    logic [ADDR_SIZE:0] wbin_next;             // Next binary write pointer

    // Sequential logic for pointer update
    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wbin_reg <= '0;
            wptr     <= '0;
        end else begin
            wbin_reg <= wbin_next;
            wptr     <= wgray_next;
        end
    end

    // Combinational logic
    assign wbin        = wbin_reg;
    assign waddr       = wbin_reg[ADDR_SIZE-1:0];
    assign wbin_next   = wbin_reg + {3'b000,(winc & ~wfull)};
    assign wgray_next  = (wbin_next >> 1) ^ wbin_next; // Binary to gray

endmodule
