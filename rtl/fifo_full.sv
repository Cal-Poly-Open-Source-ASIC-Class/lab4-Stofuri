module fifo_full #(
    parameter int ADDR_SIZE = 4
)(
    output logic wfull,                      // Full flag
    input  logic [ADDR_SIZE:0] wgray_next,   // Next write pointer (gray code)
    input  logic [ADDR_SIZE:0] wq2_rptr,     // Synchronized read pointer (gray)
    input  logic wclk,                       // Write clock
    input  logic wrst_n                      // Active-low reset
);

    logic wfull_val;

    // Full condition: MSBs inverted, lower bits equal
    assign wfull_val = (wgray_next == {~wq2_rptr[ADDR_SIZE:ADDR_SIZE-1], wq2_rptr[ADDR_SIZE-2:0]});

    // Sequential logic to update full flag
    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n)
            wfull <= 1'b0;
        else
            wfull <= wfull_val;
    end

endmodule
