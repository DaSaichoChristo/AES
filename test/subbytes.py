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


def to_state(block):
    """FIPS 197 section 3.4: in[r + 4c] is stored at state[r][c]."""
    return [[block[4 * c + r] for c in range(4)] for r in range(4)]


def set_state(dut, name, st):
    for r in range(4):
        for c in range(4):
            dut[f"{name}[{4 * r + c}]"].value = st[r][c]


def read_state(dut, name):
    return [[int(dut[f"{name}[{4 * r + c}]"].value) for c in range(4)] for r in range(4)]


async def drive_blocks(dut, blocks):
    """Apply a new state every 4 sampling edges (i_state is held for a block)."""
    for block in blocks[1:]:
        for _ in range(4):
            await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        set_state(dut, "i_state", to_state(block))


@cocotb.test()
async def subbytes_stream(dut):
    """Stream back-to-back states and check every valid output."""
    blocks = [random.randbytes(16) for _ in range(NUM_BLOCKS)]
    expected = [to_state(sub_bytes(block)) for block in blocks]

    set_state(dut, "i_state", to_state(blocks[0]))
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start(start_high=False))
    driver = cocotb.start_soon(drive_blocks(dut, blocks))

    for want in expected:
        while True:
            await RisingEdge(dut.clk)
            await ReadOnly()
            if int(dut.valid.value):
                break

        got = read_state(dut, "o_state")
        assert got == want, f"got {got}, expected {want}"

    await driver
