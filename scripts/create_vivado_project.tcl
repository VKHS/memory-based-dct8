# =============================================================================
# create_vivado_project.tcl
# -----------------------------------------------------------------------------
# Simple Vivado TCL script to create a project, add the RTL & TB sources,
# and set dct8_top as the top-level module.
#
# Usage (from repo root):
#   vivado -mode tcl -source scripts/create_vivado_project.tcl
# =============================================================================

# Project settings
set proj_name "dct8_project"
set proj_dir  "./vivado_${proj_name}"

# Board / part (change this to match your FPGA)
set part_name "xc7a35ticsg324-1L"

# Clean old project
file delete -force $proj_dir

# Create project
create_project $proj_name $proj_dir -part $part_name

# Add RTL sources
add_files [glob ./rtl/*.v]
add_files [glob ./rtl/*.vh]

# Add simulation sources (testbenches)
add_files -fileset sim_1 [glob ./sim/*.v]

# Set top module (for synth) – change if needed
set_property top dct8_top [current_fileset]

# Set simulation top
set_property top tb_dct8_block [get_filesets sim_1]

# Optional: create default run
launch_runs synth_1 -jobs 4
# You can comment the above line if you don't want auto-synthesis.
