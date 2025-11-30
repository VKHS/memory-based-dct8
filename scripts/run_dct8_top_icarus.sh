#!/usr/bin/env bash
# =============================================================================
# run_dct8_top_icarus.sh
# -----------------------------------------------------------------------------
# Compile and run the tb_dct8_top testbench with Icarus Verilog.
#
# Usage:
#   ./scripts/run_dct8_top_icarus.sh
# =============================================================================

set -e

TOP=tb_dct8_top
OUT=build_${TOP}.vvp

mkdir -p build

echo "[Icarus] Compiling ${TOP}..."

iverilog -g2012 \
  -o build/${OUT} \
  -I rtl \
  sim/tb_dct8_top.v \
  rtl/dct8_params.vh \
  rtl/dct8_kernel_comb.v \
  rtl/dct8_block.v \
  rtl/dct8_stream.v \
  rtl/dct8_top.v

echo "[Icarus] Running ${TOP}..."
vvp build/${OUT}
