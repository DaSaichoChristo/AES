import random

import cocotb
from cocotb.triggers import Timer


def fips_state(block):
    """FIPS 197 section 3.4: in[r + 4c] is stored at state[r][c]."""
    return [[block[4 * c + r] for c in range(4)] for r in range(4)]


def read_state(dut):
    """Read the 2D port, which Icarus flattens to state[0]..state[15]."""
    return [[int(dut[f"state[{4 * r + c}]"].value) for c in range(4)] for r in range(4)]


@cocotb.test()
async def state_unpack(dut):
    """Check the input byte-to-state mapping against FIPS 197."""
    fips_block = bytes.fromhex("00112233445566778899aabbccddeeff")
    blocks = [fips_block] + [random.randbytes(16) for _ in range(16)]

    for block in blocks:
        dut.i_text.value = int.from_bytes(block, "little")
        await Timer(1, unit="ns")

        want = fips_state(block)
        got = read_state(dut)
        assert got == want, f"{block.hex()}: got {got}, expected {want}"
