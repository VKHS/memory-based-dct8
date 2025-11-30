// ============================================================================
// dct8_params.vh
// --------------------------------------------------------------------------
// Global parameters for the 8-point DCT core.
// Include this file in other RTL files with:
//
//   `include "dct8_params.vh"
//
// ============================================================================

`ifndef DCT8_PARAMS_VH
`define DCT8_PARAMS_VH

// Number of points
parameter DCT8_N          = 8;

// Input sample width (signed)
parameter DCT8_IN_W       = 16;

// Coefficient width (Q1.15)
parameter DCT8_COEFF_W    = 16;

// Output width (signed). You can increase this if you want more headroom.
parameter DCT8_OUT_W      = 18;

// Number of fractional bits in coefficients (Q1.15 -> 15)
parameter DCT8_FRAC_BITS  = 15;

`endif
