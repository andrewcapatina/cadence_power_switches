# Create the initial floorplan, power domains, and power grids. 
set top_design fa
set init_lef_file "/u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/tech.lef /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef"
set init_design_nettlist_type Verilog
set init_verilog ../../syn/outputs/$top_design.genus_syn.vg
set init_top_cell $top_design
set init_pwr_net {VDD VDD_SW}
set init_gnd_net VSS
set power_intent_file "../../syn/outputs/fa_genus_upf.upf"
#Has standard cell libraries, level shifters, and power switches. 
set link_library_worst "/pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_ss0p95vn40c.lib /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_ss0p75vn40c.lib /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_pg_ss0p95vn40c.lib"
set init_lef_file "/u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/tech.lef /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef"
set library $link_library_worst

# slow = worst = max = setup
# fast = best = min = hold

echo create_library_set -name worst_libs -timing \"$link_library_worst\" > mmmc.tcl

echo create_rc_corner -name cmax -T -40 -cap_table /u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/saed32nm_1p9m_Cmax.cap >> mmmc.tcl
echo create_rc_corner -name cmin -T -40 -cap_table /u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/saed32nm_1p9m_Cmin.cap >> mmmc.tcl

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

create_floorplan -site unit -core_size {10 20 10 10 10 10}

create_place_blockage -name pd1 -rects {10 10 20 11.7}
#create_place_blockage -name pd2 -rects {10 18.4 20 20}

connect_global_net VSS -type pgpin -pin VSS -all 

connect_global_net VDD -type pgpin -pin VDD -power_domain PD_TOP -inst_base_name *

connect_global_net VDD -type pgpin -pin VDDG -inst_base_name *HEADX2*
connect_global_net VDD_SW -type pgpin -pin VDD -power_domain PD_TOP -inst_base_name *HEADX2* -override

# Power switches are double the row height. Include -noDoubleHeightCheck
add_power_switches -power_domain PD_TOP -global_switch_cell_name HEADX2_RVT -1801power_switch_rule_name SW_CPU -column -horizontal_pitch 50 -no_double_height_check 
#-top_offset 3

create_physical_pin -layer M1 -rect { 0.5 25 2 27} -name VDD -net VDD -same_port
create_physical_pin -layer M1 -rect { 0.5 17.5 2 19.5} -name VSS -net VSS -same_port

create_physical_pin -layer M1 -rect { 0.5 5 2 6} -name sw_ctrl_net -net VSS -same_port

create_physical_pin -layer M1 -rect { 0.5 6.5 2 8.5} -name x[0] -net x[0] -same_port
create_physical_pin -layer M1 -rect { 0.5 9 2 11} -name x[1] -net x[1] -same_port
create_physical_pin -layer M1 -rect { 2.5 9 4.5 11} -name x[2] -net x[2] -same_port
create_physical_pin -layer M1 -rect { 5 9 7 11} -name x[3] -net x[3] -same_port

create_physical_pin -layer M1 -rect { 0.5 22.5 2 24.5} -name y[0] -net y[0] -same_port
create_physical_pin -layer M1 -rect { 0.5 20 2 22} -name y[1] -net y[1] -same_port
create_physical_pin -layer M1 -rect { 2.5 22.5 4 24.5} -name y[2] -net y[2] -same_port
create_physical_pin -layer M1 -rect { 2.5 20 4 22} -name y[3] -net y[3] -same_port

create_physical_pin -layer M1 -rect { 0.5 11.5 2 13.5} -name cin -net cin -same_port

create_physical_pin -layer M1 -rect { 25 0.5 26.5 2} -name cout -net cout -same_port

create_physical_pin -layer M1 -rect { 25 2.5 26.5 4.5} -name sum[0] -net sum[0] -same_port
create_physical_pin -layer M1 -rect { 27 2.5 28.5 4.5} -name sum[1] -net sum[1] -same_port
create_physical_pin -layer M1 -rect { 25 5 26.5 7} -name sum[2] -net sum[2] -same_port
create_physical_pin -layer M1 -rect { 27 7.5 28.5 9.5} -name sum[3] -net sum[3] -same_port

set_db add_stripes_stacked_via_bottom_layer M1
set_db add_stripes_stacked_via_top_layer M7
set_db add_stripes_skip_via_on_pin {}

add_ring -type core_rings -nets {VDD VSS} -layer {top M7 bottom M7 left M8 right M8} -offset 1 -width 0.2 -spacing 1.0 -follow core

deselect_obj -all
select_obj PD_TOP
# Adding stripes over header cells. 
#add_stripes -nets {VDD} -direction vertical -layer M7 -master *HEADX2* -width 2  -over_power_domain 1 -spacing 12.5 -start_offset 0 -set_to_set_distance 4
add_stripes -nets {VDD VSS} -layer M7 -master *HEADX2* -width 1.5  -over_power_domain 1 -spacing 4 -set_to_set_distance 10 -power_domains PD_TOP
#add_stripes -nets {VDD} -direction vertical -layer M7 -width 0.2  -over_power_domain 1 -spacing 12.5 -start_offset 5 - set_to_set_distance 25 

#place_connected -attractor_pin x[0] -level 1 -attractor x[0]


#add_stripes -nets {VSS} -direction vertical -layer M7 -width 0.2 -over_power_domain 1 -number_of_sets 2
# Connecting the power switch input supply pins.
route_special -nets {VDD} -allow_layer_change 1 -allow_jogging 1 -core_pin_target {stripe} -block_pin_target {nearest_target} -connect {secondary_power_pin} -power_domains PD_TOP

deselect_obj -all

# Add the follow pins and connect VSS.
route_special -nets {VDD_SW} -allow_layer_change 1 -allow_jogging 1 -core_pin_target {none} -power_domains PD_TOP -block_pin_target {nearest_target} -connect {block_pin pad_pin pad_ring core_pin floating_stripe} 
route_special -nets {VSS} -allow_layer_change 1 -allow_jogging 1 -core_pin_target {stripe ring block_ring} -power_domains PD_TOP -block_pin_target {nearest_target} -connect {block_pin pad_pin pad_ring core_pin floating_stripe}

# Connect VDD port to core ring.
route_special -nets {VDD} -allow_layer_change 1 -allow_jogging 1 -core_pin_target {block_ring} -power_domains PD_TOP -block_pin_target {nearest_target} -connect {block_pin pad_pin pad_ring core_pin floating_stripe}

#place_opt_design
place_design

#disconnect_pin -inst [get_cell fa1] -pin [get_pin fa1/x]
disconnect_pin -pin A -inst fa1/g78__8780
create_inst -base_cell AOBUFX1_RVT -name always_on_buf
connect_pin -pin A -inst always_on_buf -net x[0]
create_net -name buf_out
connect_pin -pin Y -inst always_on_buf -net buf_out
connect_pin -pin A -inst fa1/g78__8780 -net buf_out

connect_global_net VDD -type pgpin -pin VDDG -power_domain PD_TOP -inst_base_name always_on_buf
connect_global_net VDD_SW -type pgpin -pin VDD -power_domain PD_TOP -inst_base_name always_on_buf

place_design 
#-incremental
# or place_detail

#set_pg_pins_use_signal_route (give cell name, *VDD*, signal: always_on_buffer:VDDG)
#route_secondary_pg_pins - just run this. 
#set_pg_pins_use_signal_route AOBUFX1_RVT:VDDG  

#report_power_domains -insts always_on_buf
# May need to add the VDD in the PD_TOP.

# Check log file for specific commands for routing single net. Log #: 731

proc COMMENTED_OUT {} {

#add_stripes -nets {VDD} -direction vertical -layer M8 -master *always_on_buf* -width 1.5 -over_power_domain 1 -power_domains PD_TOP

add_stripes -nets {VDD} -direction horizontal -layer M8 -master *always_on_buf* -width 3.2 -start_offset 0 -set_to_set_distance 8 

route_special -nets {VDD} -allow_layer_change 1 -allow_jogging 1 -core_pin_target {none} -power_domains PD_TOP -block_pin_target {nearest_target} -connect {block_pin pad_pin pad_ring core_pin floating_stripe secondary_power_pin} -block_pin use_lef -secondary_pin_net {VDD}


ccopt_design

set_db route_design_detail_end_iteration 10
route_design 

write_db fa_route.innovus

write_power_intent ../outputs/fa_innov_upf.upf -1801

# Save netlist along with power and ground connections for LP verification.
write_netlist ../outputs/fa_netlist.vg -phys -include_pg_ports

write_def ../outputs/fa_def.def -floorplan

}

