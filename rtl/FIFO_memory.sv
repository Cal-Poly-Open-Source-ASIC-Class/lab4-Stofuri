module FIFO_memory #(
    parameter int DATA_SIZE = 8,               // Width of each data entry
    parameter int ADDR_SIZE = 4                // Width of the address
)(
    output  [DATA_SIZE-1:0] rdata,        // Output data to be read
    input   [DATA_SIZE-1:0] wdata,        // Input data to be written
    input   [ADDR_SIZE-1:0] waddr,        // Write address
    input   [ADDR_SIZE-1:0] raddr,        // Read address
    input   wclk_en,                      // Write clock enable
    input   wfull,                        // FIFO full flag
    input   wclk,                         // Write clock
    input   wen,                          // Write enable
    input   ren                           // Read enable
);

    // Local parameter for memory depth
    localparam int DEPTH = 1 << ADDR_SIZE;

    // Memory array declaration
    logic [DATA_SIZE-1:0] mem [0:DEPTH-1];

    // Read port: asynchronous read
    assign rdata = ren ? mem[raddr] : '0;

    // Write port: synchronous write
    always_ff @(posedge wclk) begin
        if (!wfull && wen)
            mem[waddr] <= wdata;
    end

endmodule
