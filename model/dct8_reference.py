# =============================================================================
# dct8_reference.py
# -----------------------------------------------------------------------------
# Floating-point reference implementation of 8-point DCT-II:
#   - dct8_1d: 1D length-8 DCT-II (orthonormal)
#   - dct8_2d_block: 2D 8x8 DCT (row-then-column)
#
# This matches the same mathematical definition used in the RTL core.
# =============================================================================

import math
from typing import List


def dct8_1d(x: List[float]) -> List[float]:
    """
    Compute 1D 8-point DCT-II (orthonormal) on a list/tuple of 8 samples.
    x: length-8 iterable of floats
    returns: length-8 list of floats
    """
    if len(x) != 8:
        raise ValueError("dct8_1d expects length-8 input")

    N = 8
    X = [0.0] * N
    for k in range(N):
        if k == 0:
            alpha = math.sqrt(1.0 / N)
        else:
            alpha = math.sqrt(2.0 / N)
        acc = 0.0
        for n in range(N):
            angle = (math.pi / 16.0) * (2.0 * n + 1.0) * k
            acc += x[n] * math.cos(angle)
        X[k] = alpha * acc
    return X


def dct8_2d_block(block: List[List[float]]) -> List[List[float]]:
    """
    Compute 2D 8x8 DCT-II (orthonormal) on a block:
      1) Apply 1D DCT on each row
      2) Apply 1D DCT on each column of the result

    block: 8x8 nested list (block[row][col])
    returns: 8x8 nested list of floats
    """
    if len(block) != 8 or any(len(row) != 8 for row in block):
        raise ValueError("dct8_2d_block expects an 8x8 block")

    # Step 1: row-wise DCT
    tmp = [dct8_1d(row) for row in block]

    # Step 2: column-wise DCT
    # Transpose
    tmp_t = [[tmp[r][c] for r in range(8)] for c in range(8)]
    out_t = [dct8_1d(col) for col in tmp_t]
    # Transpose back
    out = [[out_t[c][r] for c in range(8)] for r in range(8)]
    return out


if __name__ == "__main__":
    # Simple self-test
    x = [1.0, 2.0, 3.0, 4.0, 3.0, 2.0, 1.0, 0.0]
    X = dct8_1d(x)
    print("Input x:", x)
    print("DCT X:", ["{:.4f}".format(v) for v in X])
