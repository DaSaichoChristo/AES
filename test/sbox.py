from collections import deque

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, ReadOnly, RisingEdge

# raddr -> BRAM RDATA -> data_out
LAT = 1


def load_sbox():
    with open("../common/sbox.mem") as f:
        return [int(x, 16) & 0xFF for x in f if x.strip()]


@cocotb.test()
async def sbox_lookup(dut):
    """Hold each address and check that valid_out tracks one-cycle valid_in pulses."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    expected = load_sbox()

    dut.valid_in.value = 0
    dut.raddr.value = 0

    # Flush the valid pipeline so valid_out is 0 even though it starts as X.
    for _ in range(LAT):
        await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.valid_out.value) == 0

    for addr in range(256):
        await FallingEdge(dut.clk)
        dut.raddr.value = addr
        dut.valid_in.value = 1

        # First edge captures the address and valid_in.
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        dut.valid_in.value = 0

        # Remaining LAT-1 stages: BRAM read, then data_out register.
        for _ in range(LAT - 1):
            await RisingEdge(dut.clk)
        await ReadOnly()

        assert int(dut.valid_out.value) == 1, (
            f"valid_out not asserted for address {addr:#04x}"
        )
        got = int(dut.data_out.value)
        assert got == expected[addr], (
            f"address {addr:#04x}: got {got:#04x}, expected {expected[addr]:#04x}"
        )

        # A one-cycle valid_in pulse must produce a one-cycle valid_out pulse.
        await RisingEdge(dut.clk)
        await ReadOnly()
        assert int(dut.valid_out.value) == 0


@cocotb.test()
async def sbox_stream(dut):
    """Change the address every cycle and check outputs arrive LAT cycles later."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    expected = load_sbox()

    dut.valid_in.value = 1
    dut.raddr.value = 0

    pending = deque()

    for addr in range(256):
        await FallingEdge(dut.clk)
        dut.raddr.value = addr
        pending.append(expected[addr])

        await RisingEdge(dut.clk)
        await ReadOnly()

        if len(pending) >= LAT:
            assert int(dut.valid_out.value) == 1
            got = int(dut.data_out.value)
            want = pending.popleft()
            assert got == want, f"stream: got {got:#04x}, expected {want:#04x}"

    # Drain the remaining LAT-1 results still in the pipeline.
    for _ in range(LAT - 1):
        await RisingEdge(dut.clk)
        await ReadOnly()
        assert int(dut.valid_out.value) == 1
        got = int(dut.data_out.value)
        want = pending.popleft()
        assert got == want, f"drain: got {got:#04x}, expected {want:#04x}"

    assert not pending
