import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, ReadOnly, RisingEdge

NUM_BLOCKS = 8


def gmul(a, b):
    p = 0
    for _ in range(8):
        if b & 1:
            p ^= a
        hi = a & 0x80
        a = (a << 1) & 0xFF
        if hi:
            a ^= 0x1B
        b >>= 1
    return p


def gf_inv(a):
    result = 1
    base = a
    exp = 254
    while exp:
        if exp & 1:
            result = gmul(result, base)
        base = gmul(base, base)
        exp >>= 1
    return result


def aes_sbox(x):
    b = gf_inv(x) if x else 0
    s = b
    for _ in range(4):
        b = ((b << 1) | (b >> 7)) & 0xFF
        s ^= b
    return s ^ 0x63


def sub_bytes(block):
    return bytes(aes_sbox(b) for b in block)


async def drive_blocks(dut, blocks):
    """Apply a new block every 4 sampling edges (i_text is held for a block)."""
    for block in blocks[1:]:
        for _ in range(4):
            await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        dut.i_text.value = int.from_bytes(block, "little")


@cocotb.test()
async def subbytes_stream(dut):
    """Stream back-to-back 128-bit blocks and check every valid output."""
    blocks = [random.randbytes(16) for _ in range(NUM_BLOCKS)]
    expected = [sub_bytes(block) for block in blocks]

    dut.i_text.value = int.from_bytes(blocks[0], "little")
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start(start_high=False))
    driver = cocotb.start_soon(drive_blocks(dut, blocks))

    for want in expected:
        while True:
            await RisingEdge(dut.clk)
            await ReadOnly()
            if int(dut.valid.value):
                break

        got = int(dut.o_text.value).to_bytes(16, "little")
        assert got == want, f"got {got.hex()}, expected {want.hex()}"

    await driver
