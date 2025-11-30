# =============================================================================
# gen_test_vectors.py
# -----------------------------------------------------------------------------
# Generate random 8-sample test vectors and their golden DCT outputs.
# Writes two text files:
#   - vec_inputs.txt   : one line per vector, 8 integer samples
#   - vec_outputs.txt  : one line per vector, 8 integer DCT coefficients
#
# The DCT is computed in floating-point (orthonormal) and rounded to int.
# =============================================================================

import random
from typing import List

from dct8_reference import dct8_1d


def generate_random_vector(n: int = 8, min_val: int = -128, max_val: int = 127) -> List[int]:
    return [random.randint(min_val, max_val) for _ in range(n)]


def main(num_vectors: int = 32):
    random.seed(0xDCT8)  # reproducible

    with open("vec_inputs.txt", "w") as f_in, open("vec_outputs.txt", "w") as f_out:
        for _ in range(num_vectors):
            x = generate_random_vector()
            # Save inputs
            f_in.write(" ".join(str(v) for v in x) + "\n")

            # Compute float DCT
            X_float = dct8_1d([float(v) for v in x])

            # Round to nearest int (this matches what a lot of RTL flows will do)
            X_int = []
            for v in X_float:
                if v >= 0:
                    X_int.append(int(v + 0.5))
                else:
                    X_int.append(int(v - 0.5))

            f_out.write(" ".join(str(v) for v in X_int) + "\n")

    print(f"Generated {num_vectors} vectors → vec_inputs.txt and vec_outputs.txt")


if __name__ == "__main__":
    main()
