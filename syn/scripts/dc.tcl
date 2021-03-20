# Barebones design compiler synthesis flow.

set top_design top



set search_path "/pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm"

set synthetic_library dw_foundation.sldb

#set link_library "/pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_ss0p95v125c.db"
set link_library "saed32rvt_ss0p95v125c.db saed32rvt_pg_ss0p95v125c.db"
lappend link_library $synthetic_library 

lappend search_path .

#set target_library "/pkgs/synopsys/2020/32_28nm/SAED32_EDK/stdcell_rvt/db_nldm/saed32rvt_ss0p95v125c.db"
set target_library "saed32rvt_ss0p95v125c.db saed32rvt_pg_ss0p95v125c.db"

analyze ../verilog/top.sv -autoread -define SYNTHESIS

elaborate ${top_design}

# Load the UPF intent.
#load_upf ../upf/top.upf
load_upf ../upf/upf.upf

set_operating_conditions ss0p95v125c -library saed32rvt_ss0p95v125c

set_voltage -object_list VDD 0.95
set_voltage -object_list VSS 0.0
#set_voltage -object_list imem/VDD 0.95
#set_voltage -object_list dmem/VDD 0.95

set_voltage -object_list mips/VDD_in 0.95
set_voltage -object_list mips/VDD 0.95
#change_names -rules verilog -hierarchy

source -echo -verbose ../../constraints/top.sdc

#uniquify

#compile_ultra -no_autoungroup -no_boundary_optimization
#set ungroup_keep_original_design true
#set compile_ultra_ungroup_small_hierarchies false

set compile_seqmap_propagate_constants false
set compile_seqmap_propagate_high_effort false

set compile_enable_constant_propagation_with_no_boundary_opt false
dont_touch mips/dp/rf/*


compile_ultra -no_autoungroup -no_seq_output_inversion -exact_map -no_boundary_optimization -no_design_rule
#compile

#change_names -rules verilog -hierarchy

write -hier -format verilog -output ../outputs/${top_design}.syn.dc.vg
save_upf ../outputs/${top_design}.upf
