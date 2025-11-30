# `scripts/` – Build & Run Helpers

This folder contains helper scripts for running simulations and (optionally)
creating an FPGA project.

## Files

- `run_dct8_block_icarus.sh`  
  Shell script that compiles and runs the `tb_dct8_block` testbench using
  **Icarus Verilog** (`iverilog` + `vvp`).

- `run_dct8_top_icarus.sh`  
  Shell script that compiles and runs the `tb_dct8_top` testbench with Icarus
  to exercise the streaming top-level core.

- `Makefile`  
  Convenience targets:
  - `make dct8_block` – run the block-level testbench
  - `make dct8_top` – run the streaming testbench
  - `make clean` – delete the `build/` directory

- `create_vivado_project.tcl`  
  Example Tcl script to create a **Vivado** project, add all RTL and simulation
  sources, and set `dct8_top` as the synthesis top module. You can adjust the
  target FPGA part in this file.

## Usage examples

From the repo root:

```sh
# Run the block-level testbench
make dct8_block

# Run the streaming testbench
make dct8_top

# Or directly call the scripts
./scripts/run_dct8_block_icarus.sh
./scripts/run_dct8_top_icarus.sh
