# dct8-hw-core 🎛️

A clean, modular **8‑point DCT (Discrete Cosine Transform) hardware core** implemented in Verilog/SystemVerilog, with:

- Synthesizable RTL (`rtl/`)
- Self‑checking testbenches (`sim/`)
- Python golden models (`model/`)
- Handy build scripts (`scripts/`)

Designed as a teaching‑friendly and research‑friendly base for image/video compression, FPGA experiments, and exploring low‑power transform architectures.

---

## ✨ Features

- **8‑point DCT‑II core** in fixed‑point arithmetic
- **Streaming top‑level interface** (`dct8_top`) – feed 8 samples in, get 8 DCT coefficients out
- **Block‑based core** (`dct8_block`) – simple `start` / `done` handshake
- **Matrix‑based DCT kernel** (`dct8_kernel_comb`) – clean reference implementation
- Structured for a **future memory‑based / CORDIC architecture** (butterfly, CORDIC, memory bank, controllers)
- Python **golden model** and **test vector generator** to verify the RTL

---

## 📁 Repository structure

```text
.
├── rtl/         # All synthesizable RTL
│   ├── dct8_params.vh       # Global parameters (word lengths, etc.)
│   ├── dct8_top.v           # Streaming top-level 8-point DCT core
│   ├── dct8_stream.v        # 8-sample streaming wrapper
│   ├── dct8_block.v         # Block-level core with start/done
│   ├── dct8_kernel_comb.v   # Combinational DCT(8) matrix kernel (Q1.15)
│   ├── butterfly8.v         # Butterfly PE (sum/diff + safe scaling)
│   ├── ss_unit.v            # Safe-scaling unit
│   ├── csa_4to2.v           # 4:2 carry-save adder (optional helper)
│   ├── cla_adder.v          # Generic adder module
│   ├── dct8_mem_bank.v      # Dual-port memory bank
│   ├── dct8_addr_gen.v      # Address generator (skeleton)
│   ├── dct8_rearrange.v     # Rearrange unit (skeleton)
│   ├── dct8_controller.v    # Multi-stage controller (skeleton)
│   ├── cordic8_core.v       # Placeholder fixed-angle rotator (cos/sin)
│   ├── cordic8.v            # Wrapper + radius scaling stubs
│   └── radius_scale8.v      # Radius scaling stub (identity for now)
│
├── sim/         # Testbenches (SystemVerilog)
│   ├── tb_dct8_block.v      # Self-checking TB for dct8_block (random tests)
│   └── tb_dct8_top.v        # Streaming TB for dct8_top (prints DCT outputs)
│
├── model/       # Python golden models & utilities
│   ├── dct8_reference.py    # Floating-point DCT-II (1D & 2D 8x8)
│   ├── fixed_point_utils.py # Quantization helpers (float <-> fixed)
│   └── gen_test_vectors.py  # Random vectors + golden DCT outputs
│
├── scripts/     # Build & run helpers
│   ├── Makefile               # make sim_block / sim_top / sim_all / clean
│   ├── run_sim.sh             # small wrapper to call the Makefile
│   └── create_vivado_project.tcl # example Vivado project creation script
│
└── README.md   # You are here
