# ============================================================
# Clock
# ============================================================
create_clock -period 20.000 -name clk [get_ports clk]

# ============================================================
# Configuration Bank Voltage (fixes CFGBVS-1 warning)
# AC701 config bank uses 3.3V VCCO path
# ============================================================
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# ============================================================
# Logical I/O standard assignment (fixes NSTD-1 root cause)
# NOTE: This does not assign package pins (LOC).
# ============================================================
set_property IOSTANDARD LVCMOS33 [get_ports -quiet {clk rst start busy done ready {plaintext[*]} {key[*]} {ciphertext[*]}}]

# ============================================================
# Generic external interface timing model
# (fixes TIMING-18 missing input/output delay methodology warnings)
# ============================================================
set _xlnx_shared_i0 [get_ports -quiet {rst start {plaintext[*]} {key[*]}}]
set_input_delay -clock [get_clocks clk] -max 2.500 $_xlnx_shared_i0
set_input_delay -clock [get_clocks clk] -min 0.000 $_xlnx_shared_i0

# Top-level ports are used as a lab/demo interface (not board-timed system I/O).
# Exclude these outputs from strict external timing closure and focus on internal paths.
set_false_path -to [get_ports -quiet {busy done ready {ciphertext[*]}}]

# ============================================================
# Proposed duplicated architecture timing model
# - Lanes in aes_top_parallel are CE-gated and advance once every 2 clocks
# - Apply multicycle between sequential cells inside u_core_ce lane instances
# ============================================================
set _xlnx_shared_i1 [get_cells -hier -quiet -filter {NAME =~ *GEN_LANES*u_core_ce* && IS_SEQUENTIAL}]
set_multicycle_path -setup -from $_xlnx_shared_i1 -to $_xlnx_shared_i1 2 -quiet
set_multicycle_path -hold -from $_xlnx_shared_i1 -to $_xlnx_shared_i1 1 -quiet

# ============================================================
# Bitstream unblock for lab-only wide top-level ports
# IMPORTANT: Recommended only when using unconstrained lab/demo I/O.
# For deployment, replace with full per-port LOC constraints.
# ============================================================

# catch {set_load 5.000 [all_outputs]}
set_operating_conditions -voltage {vccint 0.950}
set_operating_conditions -voltage {vccaux 1.710}
set_operating_conditions -voltage {vcco33 3.000}
set_operating_conditions -voltage {vcco25 2.380}
set_operating_conditions -voltage {vcco18 1.710}
set_operating_conditions -voltage {vcco15 1.430}
set_operating_conditions -voltage {vcco135 1.300}
set_operating_conditions -voltage {vcco12 1.140}
set_operating_conditions -voltage {vccaux_io 1.710}
set_operating_conditions -voltage {vccbram 0.950}
set_operating_conditions -voltage {mgtavcc 0.950}
set_operating_conditions -voltage {mgtavtt 1.140}
set_operating_conditions -voltage {vccadc 1.710}
