# Create the initial floorplan, power domains, and power grids. 
set top_design top
set init_lef_file "/u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/tech.lef /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef"
set init_design_nettlist_type Verilog
set init_verilog ../../syn/outputs/top.genus_syn.vg
set init_top_cell $top_design
set init_pwr_net {VDD VDD_CPU_OUT}
set init_gnd_net VSS
set power_intent_file "../../syn/outputs/top_genus_upf.upf"
#Has standard cell libraries, level shifters, and power switches. 
set link_library_worst "/pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_ss0p95vn40c.lib /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_ss0p75vn40c.lib /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_pg_ss0p95vn40c.lib"
set init_lef_file "/u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/tech.lef /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef "
set library $link_library_worst

# slow = worst = max = setup
# fast = best = min = hold

echo create_library_set -name worst_libs -timing \"$link_library_worst\" > mmmc.tcl

#echo create_rc_corner -name cmax -T -40 -cap_table /u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/saed32nm_1p9m_Cmax.cap >> mmmc.tcl
#echo create_rc_corner -name cmin -T -40 -cap_table /u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/saed32nm_1p9m_Cmin.cap >> mmmc.tcl
echo create_rc_corner -name cmax -T -40 -cap_table /u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/saed32nm_1p9m_Cmax.cap -qrc_tech /u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/tech.lef >> mmmc.tcl
echo create_rc_corner -name cmin -T -40 -cap_table /u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/saed32nm_1p9m_Cmin.cap -qrc_tech /u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/tech.lef >> mmmc.tcl


echo create_constraint_mode -name const_mode -sdc_files {"../../constraints/top.sdc"} >> mmmc.tcl

echo create_timing_condition -name tc_worst -library_sets worst_libs >> mmmc.tcl
echo create_delay_corner -name worst_corner -timing_condition {tc_worst} -rc_corner cmax >> mmmc.tcl

echo create_timing_condition -name tc_best -library_sets worst_libs >> mmmc.tcl
echo create_delay_corner -name best_corner -timing_condition {tc_best} -rc_corner cmin >> mmmc.tcl

echo create_analysis_view -name func_worst_scenario -delay_corner worst_corner -constraint_mode const_mode >> mmmc.tcl
echo create_analysis_view -name func_best_scenario -delay_corner best_corner -constraint_mode const_mode >> mmmc.tcl

echo set_analysis_view -setup func_worst_scenario -hold func_best_scenario >> mmmc.tcl

set init_mmmc_file mmmc.tcl

read_mmmc ../work/mmmc.tcl

read_physical -lef $init_lef_file
read_netlist $init_verilog

init_design

read_power_intent -1801 ${power_intent_file} 
commit_power_intent -verbose 

create_floorplan -site unit -core_size {420 220 50 50 50 50}

update_power_domain PD_CPU -power_extend_edges {10 0 0 10} -gap_sides {10 0 0 10} -box 50 50 280 140
update_power_domain PD_IMEM -power_extend_edges {10 0 10 0} -gap_sides {10 0 10 0} -box 300 50 469.98 140
update_power_domain PD_DMEM -power_extend_edges {10 10 10 10} -gap_sides {10 10 10 10} -box 60 170 460 260

plan_design
#plan_design -constraints_file ../../constraints/plan_design.sdc

connect_global_net VSS -type pgpin -pin VSS -all 

connect_global_net VDD_CPU_OUT -type pgpin -pin VDD -power_domain PD_CPU -inst_base_name * 
connect_global_net VDD -type pgpin -pin VDD -power_domain PD_DMEM -inst_base_name *
connect_global_net VDD -type pgpin -pin VDD -power_domain PD_IMEM -inst_base_name *
connect_global_net VDD -type pgpin -pin VDD -power_domain PD_TOP -inst_base_name *

# power switch and isolation connection. 
connect_global_net VDD -type pgpin -pin VDDG -inst_base_name *HEADX2*
connect_global_net VDD -type pgpin -pin VDDG -inst_base_name *ISO*

# Power switches are double the row height. Include -noDoubleHeightCheck
add_power_switches -power_domain PD_CPU -global_switch_cell_name HEADX2_RVT -1801power_switch_rule_name SW_CPU -column -horizontal_pitch 50 -no_double_height_check -checker_board

source ../scripts/add_ports.tcl

add_rings -type core_rings -nets {VDD VSS} -layer {top M7 bottom M7 left M8 right M8} -offset 1 -width 4 -spacing 1.0 -follow core

deselect_obj -all
select_obj PD_DMEM
# Adding a power ring for a power domain boundary:
add_rings -type block_rings -nets {VDD VSS} -layer {top M7 bottom M7 left M8 right M8} -offset 1 -width 4 -spacing 1.0 -around power_domain
add_stripes -nets {VDD VSS} -direction vertical -layer M7 -width 1 -set_to_set_distance 25 -start_offset 1 -spacing 12.5 -over_power_domain 1

deselect_obj -all
select_obj PD_IMEM
# Adding a power ring for a power domain boundary:
add_rings -type block_rings -nets {VDD VSS} -layer {top M7 bottom M7 left M8 right M8} -offset 1 -width 4 -spacing 1.0 -around power_domain


set_db add_stripes_ignore_block_check false
set_db add_stripes_break_at {block_ring outer_ring}
set_db add_stripes_route_over_rows_only false
set_db add_stripes_rows_without_stripes_only false 
set_db add_stripes_extend_to_closest_target ring 
set_db add_stripes_stop_at_last_wire_for_area false 
set_db add_stripes_partial_set_through_domain false 
set_db add_stripes_ignore_non_default_domains false 
set_db add_stripes_trim_antenna_back_to_shape none 
set_db add_stripes_spacing_type edge_to_edge 
set_db add_stripes_spacing_from_block 0 
set_db add_stripes_stripe_min_length stripe_width 
set_db add_stripes_stacked_via_top_layer MRDL 
set_db add_stripes_stacked_via_bottom_layer M1 
set_db add_stripes_via_using_exact_crossover_size false 
set_db add_stripes_split_vias false 
set_db add_stripes_orthogonal_only true 
set_db add_stripes_allow_jog {padcore_ring block_ring} 
set_db add_stripes_skip_via_on_pin {standardcell} 
set_db add_stripes_skip_via_on_wire_shape {noshape}

add_stripes -nets {VDD VSS} -direction vertical -layer M7 -width 1 -set_to_set_distance 25 -start_offset 1 -spacing 12.5 -over_power_domain 1

deselect_obj -all
select_obj PD_CPU
# Adding a power ring for a power domain boundary:
add_rings -nets {VDD VSS} -type block_rings -around power_domain -layer {top M7 bottom M7 left M8 right M8} -width {top 4 bottom 4 left 4 right 4} -spacing {top 1 bottom 1 left 1 right 1} -offset {top 1 bottom 1 left 1 right 1} -center 0 -extend_corners {tl rb } -skip_side {bottom left } -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none

# Add stripes over header cells and ground stripes over power domain.
add_stripes -nets {VDD} -direction vertical -layer M7 -master *HEADX2* -width 2  -over_power_domain 1 -spacing 12.5 -start_offset 0 -set_to_set_distance 25 -over_pins 1
add_stripes -nets {VSS} -direction vertical -layer M7 -master *HEADX2* -width 2  -over_power_domain 1 -spacing 12.5 -start_offset 10 -set_to_set_distance 25


# Adding the follow pins to mips/CPU domain.
#route_special -nets {VDD_CPU_OUT} -allow_layer_change 1 -allow_jogging 1 -core_pin_target {stripe ring block_ring} -power_domains PD_CPU -block_pin_target {nearest_target} -connect {block_pin pad_pin pad_ring core_pin floating_stripe} -block_pin use_lef 

route_special -nets {VDD_CPU_OUT VDD} -allow_layer_change 1 -allow_jogging 1 -core_pin_target {none} -power_domains PD_CPU -block_pin_target {nearest_target} -connect {block_pin pad_pin pad_ring core_pin floating_stripe secondary_power_pin} -block_pin use_lef -secondary_pin_net {VDD}

route_special -nets {VSS} -allow_layer_change 1 -allow_jogging 1 -core_pin_target {stripe ring block_ring} -power_domains PD_CPU -block_pin_target {nearest_target} -connect {block_pin pad_pin pad_ring core_pin floating_stripe} 
# Connecting the power switch input supply pins.
#route_special -nets {VDD} -allow_layer_change 1 -allow_jogging 1 -core_pin_target {stripe} -power_domains PD_CPU -block_pin_target {nearest_target} -connect {secondary_power_pin} 

deselect_obj -all

# dmem follow pins.
route_special -nets {VDD VSS} -allow_layer_change 1 -allow_jogging 1 -core_pin_target {stripe ring block_ring} -power_domains PD_DMEM -block_pin_target {nearest_target} -connect {block_pin pad_pin pad_ring core_pin floating_stripe} 

# imem follow pins.
route_special -nets {VDD VSS} -allow_layer_change 1 -allow_jogging 1 -core_pin_target {stripe ring block_ring} -power_domains PD_IMEM -block_pin_target {nearest_target} -connect {block_pin pad_pin pad_ring core_pin floating_stripe} 

# top domain follow pins.
route_special -nets {VDD VSS} -allow_layer_change 1 -allow_jogging 1 -core_pin_target {stripe ring block_ring} -power_domains PD_TOP -block_pin_target {nearest_target} -connect {block_pin pad_pin pad_ring core_pin floating_stripe} 

place_design
opt_design -pre_cts
# Does logic optimization, may not want that.
#place_opt_design

ccopt_design

set_db route_design_detail_end_iteration 7
set_db route_design_detail_min_length_for_spread_wire {M1 0.40 M2 0.08 M3 0.08 M4 0.08}
set_db route_design_detail_post_route_spread_wire true
set_db route_design_strict_honor_route_rule true
set_route_attributes -route_rule_effort hard -nets [get_nets *]

route_design 

write_power_intent ../outputs/top_innov_upf.upf -1801

write_db top_route.innovus

# Save netlist along with power and ground connections for LP verification.
write_netlist ../outputs/top_netlist.vg -phys -include_pg_ports
write_netlist ../outputs/top_netlist_no_pg.vg

write_def ../outputs/top_def.def -floorplan

