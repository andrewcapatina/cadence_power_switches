# Create the initial floorplan, power domains, and power grids. 
set top_design top
set init_lef_file "/u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/tech.lef /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef"
set init_design_nettlist_type Verilog
set init_verilog ../../syn/outputs/top.genus_syn.vg
set init_top_cell $top_design
set init_pwr_net {VDD}
set init_gnd_net VSS
set power_intent_file "../../syn/outputs/top_genus_upf.upf"

#Has standard cell libraries, level shifters, and power switches. 
set link_library_worst "/pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_dlvl_ss0p75vn40c_i0p95v.lib /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_dlvl_ss0p75vn40c_i0p75v.lib /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_ulvl_ss0p75vn40c_i0p75v.lib /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_ss0p95vn40c.lib /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_ss0p75vn40c.lib /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_pg_ss0p95vn40c.lib"
set init_lef_file "/u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/tech.lef /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef "
set library $link_library_worst

#echo create_library_set -name worst_libs -timing \"$link_library_worst\" > mmmc.tcl

#echo create_rc_corner -name cmax -T -40 -preRoute_cap 1.0 -preRoute_res 1.0 -postRoute_cap 1.0 -postRoute_res 1.0 >> mmmc.tcl

#echo create_constraint_mode -name const_mode -sdc_files {"../../constraints/top.sdc"} >> mmmc.tcl

#echo create_delay_corner -name worst_corner -library_set worst_libs -rc_corner cmax >> mmmc.tcl

#echo create_analysis_view -name func_worst_scenario -delay_corner worst_corner -constraint_mode const_mode >> mmmc.tcl

#echo set_analysis_view -setup func_worst_scenario -hold func_worst_scenario >> mmmc.tcl

#set init_mmmc_file mmmc.tcl


init_design

set_ccopt_property target_max_trans 0.3ns

floorplan -s {500 500 50 50 50 50}

#set_interactive_constraint_modes [all_constraint_modes -active]
#source -echo -verbose ../../constraints/$top_design.sdc

read_power_intent -1801 ${power_intent_file} 
commit_power_intent -verbose 



#modifyPowerDomainAttr PD_TOP -rsExts {4 4 4 4}
modifyPowerDomainAttr mips/CPU -rsExts {20 20 20 20} -minGaps {20 20 20 20} 
modifyPowerDomainAttr dmem/MEM -rsExts {20 20 20 20} -minGaps {20 20 20 20} 
modifyPowerDomainAttr imem/MEM -rsExts {20 20 20 20} -minGaps {20 20 20 20} 

setPlanDesignMode -useGuideBoundary fence -effort high -incremental false -boundaryPlace true -fixPlacedMacros false -fenceSpacing 10 -macroSpacing 10 -util 0.40

planDesign

globalNetConnect VSS -type pgpin -pin VSS -all 

globalNetConnect VDD -type pgpin -pin VDD -powerDomain mips/CPU -instBaseName * 
globalNetConnect VDD -type pgpin -pin VDD -powerDomain dmem/MEM -instBaseName *
globalNetConnect VDD -type pgpin -pin VDD -powerDomain imem/MEM -instBaseName *
globalNetConnect VDD -type pgpin -pin VDD -powerDomain PD_TOP -instBaseName *

# power switch connection.
#globalNetConnect VDD -type pgpin -pin VDDG -instBaseName *HEADX2* -all -override
globalNetConnect VDD -type pgpin -pin VDDG -instBaseName *HEADX2*
globalNetConnect VDD -type pgpin -pin VDDG -instBaseName *ISO*


# Power switches are double the row height. Include -noDoubleHeightCheck
addPowerSwitch -powerDomain mips/CPU -globalSwitchCellName HEADX2_RVT -1801PowerSwitchRuleName mips/sw1 -column -horizontalPitch 50 -noDoubleHeightCheck



addRing -type core_rings -nets {VDD VSS} -layer {top M7 bottom M7 left M8 right M8} -offset 1 -width 4 -spacing 1.0 -follow core

deselectAll
selectGroup mips/CPU
#selectGroup mips/PD_CPU
# Adding a power ring for a power domain boundary:
addRing -type block_rings -nets {VDD VSS} -layer {top M7 bottom M7 left M8 right M8} -offset 1 -width 4 -spacing 1.0 -around power_domain
#addStripe -nets {VDD VSS} -direction vertical -layer M7 -width 1 -set_to_set_distance 24.75 -start_offset 1 -spacing 12.5 -over_power_domain 1
addStripe -nets {VDD} -direction vertical -layer M7 -master *HEADX2* -width 2  -over_power_domain 1 -spacing 12.5 -start_offset 0 -set_to_set_distance 25 -over_pins 1
addStripe -nets {VSS} -direction vertical -layer M7 -master *HEADX2* -width 2  -over_power_domain 1 -spacing 12.5 -start_offset 10 -set_to_set_distance 25 

deselectAll
selectGroup dmem/MEM
# Adding a power ring for a power domain boundary:
addRing -type block_rings -nets {VDD VSS} -layer {top M7 bottom M7 left M8 right M8} -offset 1 -width 4 -spacing 1.0 -around power_domain
addStripe -nets {VDD VSS} -direction vertical -layer M7 -width 1 -set_to_set_distance 25 -start_offset 1 -spacing 12.5 -over_power_domain 1

deselectAll
selectGroup imem/MEM
# Adding a power ring for a power domain boundary:
addRing -type block_rings -nets {VDD VSS} -layer {top M7 bottom M7 left M8 right M8} -offset 1 -width 4 -spacing 1.0 -around power_domain -follow core 
addStripe -nets {VDD VSS} -direction vertical -layer M7 -width 1 -set_to_set_distance 25 -start_offset 1 -spacing 12.5 -over_power_domain 1  

deselectAll

# Adding the follow pins to mips/CPU domain.
sroute -nets {VDD} -allowLayerChange 1 -allowJogging 1 -corePinTarget {stripe ring blockring} -powerDomains mips/CPU -blockPinTarget {nearestTarget} -connect {blockPin padPin padRing corePin floatingStripe} 
sroute -nets {VSS} -allowLayerChange 1 -allowJogging 1 -corePinTarget {stripe ring blockring} -powerDomains mips/CPU -blockPinTarget {nearestTarget} -connect {blockPin padPin padRing corePin floatingStripe} 
# Connecting the power switch input supply pins.
sroute -nets {VDD} -allowLayerChange 1 -allowJogging 1 -corePinTarget {stripe} -powerDomains mips/CPU -blockPinTarget {nearestTarget} -connect {secondaryPowerPin}

# Adding follow pins to imem/MEM domain.
sroute -nets {VDD VSS} -allowLayerChange 1 -allowJogging 1 -corePinTarget {stripe ring blockring} -powerDomains imem/MEM -blockPinTarget {nearestTarget} -connect {blockPin padPin padRing corePin floatingStripe} 
# Adding follow pins to dmem/MEM domain. 
sroute -nets {VDD VSS} -allowLayerChange 1 -allowJogging 1 -corePinTarget {stripe ring blockring} -powerDomains dmem/MEM -blockPinTarget {nearestTarget} -connect {blockPin padPin padRing corePin floatingStripe} 

addStripe -nets {VDD VSS} -direction vertical -layer M7 -number_of_sets 10 -width 4 -spacing 15

#setPGPinUseSignalRoute HEADX2_RVT:VDDG
#routePGPinUseSignalRoute -nets {VDD}


place_opt_design

ccopt_design

setNanoRouteMode -drouteEndIteration 10 -routewithTimingDriven true 

routeDesign

saveDesign ${top_design}_route.innovus

# Save netlist along with power and ground connections for LP verification.
saveNetlist ../outputs/innovus_netlist_with_pg.vg -phys -includePowerGround 

#defOut -floorplan -noStdCells "../outputs/${top_design}.floorplan.innovus.def"

