#!/usr/bin/env bash
# =============================================================================
# run_dct8_block_icarus.sh
# -----------------------------------------------------------------------------
# Compile and run the tb_dct8_block testbench with Icarus Verilog.
#
# Assumes the following repo layout:
#   rtl/  - all RTL .v/.vh
#   sim/  - testbenches
#
# Usage:
#   ./scripts/run_dct8_block_icarus.sh
# =============================================================================

set -e

TOP=tb_dct8_block
OUT=build_${TOP}.vvp

mkdir -p build

echo "[Icarus] Compiling ${TOP}..."

iverilog -g2012 \
  -o build/${OUT} \
  -I rtl \
  sim/tb_dct8_block.v \
  rtl/dct8_params.vh \
  rtl/dct8_kernel_comb.v \
  rtl/dct8_block.v

echo "[Icarus] Running ${TOP}..."
vvp build/${OUT}
