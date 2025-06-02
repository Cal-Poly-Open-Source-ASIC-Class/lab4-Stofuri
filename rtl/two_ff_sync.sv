module two_ff_sync #(
    parameter int SIZE = 4
)(
    output logic [SIZE-1:0] q2,     // Output of the second flip-flop
    input  logic [SIZE-1:0] din,    // Input data
    input  logic clk,               // Clock
    input  logic rst_n              // Active-low reset
);

    logic [SIZE-1:0] q1;            // Output of the first flip-flop

    // Two-stage shift register for synchronization
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q1 <= '0;
            q2 <= '0;
        end else begin
            q1 <= din;
            q2 <= q1;
        end
    end

endmodule
