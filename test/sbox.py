import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def sbox(dut):
    clock = Clock(dut.clk, 10, units="ns")

    cocotb.start_soon(clock.start())

    expected = [int(x, 16) & 0xFF for x in open("../common/sbox.mem") if x.strip()]

    for addr in range(256):
        dut.rd_addr.value = addr
        for _ in range(4):
            await RisingEdge(dut.clk)
        assert int(dut.data_out.value) == expected[addr]
