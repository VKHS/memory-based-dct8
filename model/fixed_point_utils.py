# =============================================================================
# fixed_point_utils.py
# -----------------------------------------------------------------------------
# Helpers for fixed-point quantization and dequantization.
# Useful for matching Python models to RTL behavior.
# =============================================================================

from typing import List, Tuple


def _saturate(value: int, bits: int, signed: bool = True) -> int:
    """
    Saturate integer 'value' to the range representable by 'bits' bits.
    If signed=True, range is [-2^(bits-1), 2^(bits-1)-1].
    If signed=False, range is [0, 2^bits-1].
    """
    if signed:
        min_val = -(1 << (bits - 1))
        max_val = (1 << (bits - 1)) - 1
    else:
        min_val = 0
        max_val = (1 << bits) - 1

    if value < min_val:
        return min_val
    if value > max_val:
        return max_val
    return value


def float_to_fixed(x: float, bits: int, frac_bits: int,
                   signed: bool = True, saturate: bool = True) -> int:
    """
    Convert float -> fixed-point integer.
    bits: total number of bits
    frac_bits: number of fractional bits (e.g. 15 => Q1.15)
    """
    scaled = int(round(x * (1 << frac_bits)))
    if saturate:
        scaled = _saturate(scaled, bits, signed)
    return scaled


def fixed_to_float(x_int: int, bits: int, frac_bits: int,
                   signed: bool = True) -> float:
    """
    Convert fixed-point integer -> float.
    bits: total number of bits
    frac_bits: number of fractional bits
    """
    if signed:
        # Interpret x_int as signed two's complement
        sign_bit = 1 << (bits - 1)
        mask = (1 << bits) - 1
        x_int = x_int & mask
        if x_int & sign_bit:
            x_int = x_int - (1 << bits)

    return float(x_int) / float(1 << frac_bits)


def quantize_vector(vec: List[float], bits: int, frac_bits: int,
                    signed: bool = True) -> List[int]:
    """
    Quantize a list of floats into fixed-point integers.
    """
    return [float_to_fixed(v, bits, frac_bits, signed=signed, saturate=True)
            for v in vec]


def dequantize_vector(vec_int: List[int], bits: int, frac_bits: int,
                      signed: bool = True) -> List[float]:
    """
    Convert a list of fixed-point ints back to floats.
    """
    return [fixed_to_float(v, bits, frac_bits, signed=signed)
            for v in vec_int]


if __name__ == "__main__":
    # Simple demo
    val = 0.75
    bits = 16
    frac_bits = 15  # Q1.15
    fi = float_to_fixed(val, bits, frac_bits)
    back = fixed_to_float(fi, bits, frac_bits)
    print(f"val={val}, fi={fi}, back={back}")
