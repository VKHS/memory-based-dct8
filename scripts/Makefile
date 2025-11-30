# =============================================================================
# Makefile for DCT8 Project
# -----------------------------------------------------------------------------
# Targets:
#   make dct8_block  - compile & run tb_dct8_block with Icarus
#   make dct8_top    - compile & run tb_dct8_top with Icarus
#   make clean       - remove build artifacts
# =============================================================================

.PHONY: all dct8_block dct8_top clean

all: dct8_block dct8_top

dct8_block:
	@echo "== Running tb_dct8_block =="
	@./scripts/run_dct8_block_icarus.sh

dct8_top:
	@echo "== Running tb_dct8_top =="
	@./scripts/run_dct8_top_icarus.sh

clean:
	@echo "== Cleaning build/ =="
	@rm -rf build
