module r_pointer #(
    parameter int ADDR_SIZE = 4
)(
    output logic [ADDR_SIZE-1:0] raddr,      // Read address
    output logic [ADDR_SIZE:0]   rptr,       // Read pointer (gray code)
    output logic [ADDR_SIZE:0]   rbin,       // Binary read pointer
    input  logic                 rinc,       // Read increment
    input  logic                 rempty,     // FIFO empty flag
    input  logic                 rclk,       // Read clock
    input  logic                 rrst_n      // Active-low reset
);

    logic [ADDR_SIZE:0] rbin_reg;            // Binary read pointer register
    logic [ADDR_SIZE:0] rbin_next;           // Next binary pointer
    logic [ADDR_SIZE:0] rgray_next;          // Next gray code pointer

    // Sequential logic for pointer update
    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rbin_reg <= '0;
            rptr     <= '0;
        end else begin
            rbin_reg <= rbin_next;
            rptr     <= rgray_next;
        end
    end

    // Combinational logic
    assign rbin       = rbin_reg;
    assign raddr      = rbin_reg[ADDR_SIZE-1:0];
    assign rbin_next  = rbin_reg + {3'b000,(rinc & ~rempty)};
    assign rgray_next = (rbin_next >> 1) ^ rbin_next; // Binary to Gray

endmodule
