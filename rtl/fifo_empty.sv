module fifo_empty #(
    parameter int ADDR_SIZE = 4
)(
    output logic rempty,                     // Empty flag
    input  logic [ADDR_SIZE:0] rgray_next,   // Next read pointer (gray code)
    input  logic [ADDR_SIZE:0] rq2_wptr,     // Synchronized write pointer (gray)
    input  logic rclk,                       // Read clock
    input  logic rrst_n                      // Active-low reset
);

    logic rempty_val;

    // Combinational empty condition
    assign rempty_val = (rgray_next == rq2_wptr);

    // Sequential logic to update empty flag
    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n)
            rempty <= 1'b1;
        else
            rempty <= rempty_val;
    end

endmodule
