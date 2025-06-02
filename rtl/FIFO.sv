module FIFO #(
    parameter int DSIZE = 8,     // Data width
    parameter int ASIZE = 3      // Address width
)(
    output logic [DSIZE-1:0] rdata,       // Read data output
    output logic wfull,                   // Write full flag
    output logic rempty,                  // Read empty flag
    input  logic [DSIZE-1:0] wdata,       // Write data input
    input  logic winc, wclk, wrst_n, wen, // Write increment, clock, reset
    input  logic rinc, rclk, rrst_n, ren  // Read increment, clock, reset
);

    // Internal pointers and addresses
    logic [ASIZE-1:0] waddr, raddr;
    logic [ASIZE:0] wptr, rptr;
    logic [ASIZE:0] wq2_rptr, rq2_wptr;

    // Synchronize read pointer into write clock domain
    two_ff_sync #(.SIZE(ASIZE+1)) sync_r2w (
        .q2(wq2_rptr), 
        .din(rptr),
        .clk(wclk), 
        .rst_n(wrst_n)
    );

    // Synchronize write pointer into read clock domain
    two_ff_sync #(.SIZE(ASIZE+1)) sync_w2r (
        .q2(rq2_wptr), 
        .din(wptr),
        .clk(rclk), 
        .rst_n(rrst_n)
    );

    // FIFO memory
    FIFO_memory #(.DATA_SIZE(DSIZE), .ADDR_SIZE(ASIZE)) FIFO_memory (
        .ren  (ren),
        .wen  (wen),
        .rdata(rdata), 
        .wdata(wdata),
        .waddr(waddr), 
        .raddr(raddr),
        .wfull(wfull),
        .wclk(wclk)
    );

    // Read pointer logic
    logic [ASIZE:0] rbin;
    logic [ASIZE:0] rgray_next;

    r_pointer #(.ADDR_SIZE(ASIZE)) r_pointer (
        .raddr(raddr),
        .rptr(rptr),
        .rbin(rbin),
        .rinc(rinc),
        .rempty(rempty),
        .rclk(rclk),
        .rrst_n(rrst_n)
    );

    fifo_empty #(.ADDR_SIZE(3)) empty_flag (
        .rempty(rempty),
        .rgray_next(rptr),
        .rq2_wptr(rq2_wptr),
        .rclk(rclk),
        .rrst_n(rrst_n)
    );

    // Write pointer logic
    logic [ASIZE:0] wbin;
    logic [ASIZE:0] wgray_next;

    w_pointer #(.ADDR_SIZE(ASIZE)) w_pointer (
        .waddr(waddr),
        .wptr(wptr),
        .wbin(wbin),
        .wgray_next(wgray_next),
        .winc(winc),
        .wfull(wfull),
        .wclk(wclk),
        .wrst_n(wrst_n)
    );

    fifo_full #(.ADDR_SIZE(ASIZE)) full_flag (
        .wfull(wfull),
        .wgray_next(wgray_next),
        .wq2_rptr(wq2_rptr),
        .wclk(wclk),
        .wrst_n(wrst_n)
    );

endmodule
