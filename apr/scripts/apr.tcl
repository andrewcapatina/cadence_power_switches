# Place, CTS, and route.

set top_design top

# Has standard cell libraries, level shifters, and power switches. 
set link_library_worst "/pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_dlvl_ss0p75vn40c_i0p95v.lib /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_dlvl_ss0p75vn40c_i0p75v.lib /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_ulvl_ss0p75vn40c_i0p75v.lib /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_ss0p95vn40c.lib /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_ss0p75vn40c.lib /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_pg_ss0p95vn40c.lib"

#set init_lef_file "/u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/tech.lef /u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/saed32nm_1p9m_Cmax.cap /u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/saed32nm_1p9m_Cmin.cap /u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/saed32nm_1p9m_nominal.cap"

# TODO ADD CELL LEF FILES
set init_lef_file "/u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/tech.lef /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef "

set library $link_library_worst

set init_design_netlisttype Verilog

set init_verilog ../../syn/outputs/${top_design}.genus_phys.vg

set init_top_cell $top_design

echo create_library_set -name worst_libs -timing \"$link_library_worst\" > mmmc.tcl

echo create_rc_corner -name cmax -T -40 -preRoute_cap 1.0 -preRoute_res 1.0 -postRoute_cap 1.0 -postRoute_res 1.0 >> mmmc.tcl

echo create_constraint_mode -name const_mode -sdc_files {"../../constraints/top.sdc"} >> mmmc.tcl

echo create_delay_corner -name worst_corner -library_set worst_libs -rc_corner cmax >> mmmc.tcl

echo create_analysis_view -name func_worst_scenario -delay_corner worst_corner -constraint_mode const_mode >> mmmc.tcl

echo set_analysis_view -setup func_worst_scenario -hold func_worst_scenario >> mmmc.tcl

set init_mmmc_file mmmc.tcl

init_design

set_ccopt_property target_max_trans 0.3ns

# power is already in the .def file below:
defIn "../outputs/${top_design}.floorplan.innovus.def" 

# Specifying connection rules to power pins of cells. Make sure -pin parameter option matches pin names in the lib file. The PLLs for example have power pin DVDD. 
globalNetConnect VDD -type pgpin -pin VDD -inst * -autoTie
globalNetConnect VSS -type pgpin -pin VSS -inst * -autoTie


place_opt_design 

ccopt_design

setNanoRouteMode -drouteEndIteration 10 -routewithTimingDriven true 
routeDesign

saveNetlist ../outputs/${top_design}.apr.innovus.vg
    saveModel -spef -dir ${top_design}_route_spef
    foreach i [glob ../outputs/${top_design}*innovus*.spef.gz] { file delete $i  }
    foreach i [glob ${top_design}_route_spef/*.spef.gz] { 
       set newfile [regsub ${top_design}_ [file tail $i] ${top_design}.route.innovus. ]
       file copy $i  ../outputs/$newfile 
    }
