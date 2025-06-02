import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
import random

@cocotb.test()
async def test_fifo_dual_domain_behavior(dut):
    """Test FIFO: Read & Write domains both independently and simultaneously"""

    # Constants
    DEPTH = 8  # Adjust this based on your FIFO depth
    WRITE_COUNT = DEPTH
    READ_COUNT = WRITE_COUNT

    # Start asynchronous clocks
    cocotb.start_soon(Clock(dut.wclk, 7, units='ns').start())   # write domain
    cocotb.start_soon(Clock(dut.rclk, 13, units='ns').start())  # read domain

    # Apply reset
    dut.wrst_n.value = 0
    dut.rrst_n.value = 0
    dut.winc.value = 0
    dut.rinc.value = 0
    dut.wdata.value = 0
    dut.ren.value = 0
    dut.wen.value = 0
    await Timer(100, units="ns")
    dut.wrst_n.value = 1
    dut.rrst_n.value = 1
    dut.ren.value = 1
    dut.wen.value = 1
    await Timer(50, units="ns")

    # Test queue for verification
    ref_queue = []

    # --- Coroutine: Writer ---
    async def writer(count):
        for _ in range(count):
            while dut.wfull.value:
                await RisingEdge(dut.wclk)
            data = random.randint(0, 255)
            dut.wdata.value = data
            dut.winc.value = 1
            await RisingEdge(dut.wclk)
            dut.winc.value = 0
            ref_queue.append(data)
            dut._log.info(f"Wrote: {data}")
            await RisingEdge(dut.wclk)

    # --- Coroutine: Reader ---
    async def reader(count):
        read_values = []
        for _ in range(count):
            while dut.rempty.value:
                await RisingEdge(dut.rclk)
            dut.rinc.value = 1
            await RisingEdge(dut.rclk)
            val = int(dut.rdata.value)
            read_values.append(val)
            dut._log.info(f"Read: {val}")
            dut.rinc.value = 0
            await RisingEdge(dut.rclk)
        assert read_values == ref_queue, f"Mismatch!\nExpected: {ref_queue}\nGot     : {read_values}"

    # --- Phase 1: Write only ---
    dut._log.info("Phase 1: Write only")
    await writer(WRITE_COUNT)

    # --- Phase 2: Read only ---
    dut._log.info("Phase 2: Read only")
    await reader(READ_COUNT)

    # --- Phase 3: Concurrent write and read ---
    dut._log.info("Phase 3: Concurrent write/read")
    ref_queue.clear()
    await Timer(50, units="ns")
    write_task = cocotb.start_soon(writer(WRITE_COUNT))
    read_task = cocotb.start_soon(reader(READ_COUNT))
    await write_task
    await read_task

    dut._log.info("✅ Test completed successfully.")
