import random

import cocotb
from cocotb.triggers import Timer


def shift_rows(st):
    """FIPS 197 section 5.1.2: row r rotates left by r bytes."""
    return [[st[r][(c + r) % 4] for c in range(4)] for r in range(4)]


def set_state(dut, name, st):
    for r in range(4):
        for c in range(4):
            dut[f"{name}[{4 * r + c}]"].value = st[r][c]


def read_state(dut, name):
    return [[int(dut[f"{name}[{4 * r + c}]"].value) for c in range(4)] for r in range(4)]


@cocotb.test()
async def shiftrows_permute(dut):
    """Check the ShiftRows permutation against a Python reference."""
    states = [[[4 * r + c for c in range(4)] for r in range(4)]]
    states += [
        [[random.randrange(256) for _ in range(4)] for _ in range(4)]
        for _ in range(16)
    ]

    for st in states:
        set_state(dut, "i_state", st)
        await Timer(1, unit="ns")

        got = read_state(dut, "o_state")
        want = shift_rows(st)
        assert got == want, f"got {got}, expected {want}"
