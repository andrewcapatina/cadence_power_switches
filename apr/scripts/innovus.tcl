# Create the initial floorplan, power domains, and power grids. 
set top_design top
set init_lef_file "/u/capatina/ASIC/PSU_RTL2GDS/cadence_cap_tech/tech.lef /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef"
set init_design_nettlist_type Verilog
set init_verilog ../../syn/outputs/top.genus_syn.vg
set init_top_cell $top_design
set init_pwr_net {VDD}
set init_gnd_net VSS
#set power_intent_file "../../syn/upf/upf.upf"
set power_intent_file "../../syn/outputs/top_genus_upf.upf"


init_design

floorplan -s {500 500 50 50 50 50}

read_power_intent -1801 ${power_intent_file} 
commit_power_intent -verbose 



#modifyPowerDomainAttr PD_TOP -rsExts {4 4 4 4}
modifyPowerDomainAttr mips/CPU -rsExts {20 20 20 20} -minGaps {20 20 20 20} 
#modifyPowerDomainAttr mips/PD_CPU -rsExts {20 20 20 20} -minGaps {20 20 20 20} 
modifyPowerDomainAttr dmem/MEM -rsExts {20 20 20 20} -minGaps {20 20 20 20} 
modifyPowerDomainAttr imem/MEM -rsExts {20 20 20 20} -minGaps {20 20 20 20} 

setPlanDesignMode -useGuideBoundary fence -effort high -incremental false -boundaryPlace true -fixPlacedMacros false -fenceSpacing 10 -macroSpacing 10 -util 0.40

planDesign

# Power switches are double the row height. Include -noDoubleHeightCheck
addPowerSwitch -powerDomain mips/CPU -globalSwitchCellName HEADX2_RVT -1801PowerSwitchRuleName mips/sw1 -column -horizontalPitch 100 -noDoubleHeightCheck
#globalNetConnect VDD -type pgpin -pin VDD -instBaseName * 

#globalNetConnect VSS -type pgpin -pin VSS -instBaseName * -powerDomain {PD_TOP} -all 
globalNetConnect VSS -type pgpin -pin VSS -all 

globalNetConnect VDD -type pgpin -pin VDD -powerDomain mips/CPU -instBaseName * 
globalNetConnect VDD -type pgpin -pin VDD -powerDomain dmem/MEM -instBaseName *
globalNetConnect VDD -type pgpin -pin VDD -powerDomain imem/MEM -instBaseName *
globalNetConnect VDD -type pgpin -pin VDD -powerDomain PD_TOP -instBaseName *


addRing -type core_rings -nets {VDD VSS} -layer {top M7 bottom M7 left M8 right M8} -offset 1 -width 4 -spacing 1.0 -follow core

deselectAll
selectGroup mips/CPU
#selectGroup mips/PD_CPU
# Adding a power ring for a power domain boundary:
addRing -type block_rings -nets {VDD VSS} -layer {top M7 bottom M7 left M8 right M8} -offset 1 -width 4 -spacing 1.0 -around power_domain
addStripe -nets {VDD VSS} -direction vertical -layer M7 -width 1 -set_to_set_distance 25 -start_offset 1 -spacing 12.5 -over_power_domain 1

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

sroute -nets {VDD} -allowLayerChange 1 -allowJogging 1 -corePinTarget {stripe ring blockring} -powerDomains mips/CPU -blockPinTarget {nearestTarget} -connect {blockPin padPin padRing corePin floatingStripe} 
sroute -nets {VSS} -allowLayerChange 1 -allowJogging 1 -corePinTarget {stripe ring blockring} -powerDomains mips/CPU -blockPinTarget {nearestTarget} -connect {blockPin padPin padRing corePin floatingStripe} 

sroute -nets {VDD VSS} -allowLayerChange 1 -allowJogging 1 -corePinTarget {stripe ring blockring} -powerDomains imem/MEM -blockPinTarget {nearestTarget} -connect {blockPin padPin padRing corePin floatingStripe} 
sroute -nets {VDD VSS} -allowLayerChange 1 -allowJogging 1 -corePinTarget {stripe ring blockring} -powerDomains dmem/MEM -blockPinTarget {nearestTarget} -connect {blockPin padPin padRing corePin floatingStripe} 

addStripe -nets {VDD VSS} -direction vertical -layer M7 -width 1 -set_to_set_distance 25 -start_offset 1 -spacing 12.5


# Look into saving netlist with power connections.
#saveNetlist ../outputs/innovus_netlist.vg


#addStripe -nets {VDD VSS} -direction horizontal -layer M7 -width 1 -set_to_set_distance 25 -start_offset 1 -spacing 12.5
#sroute -nets {VDD VSS} -allowLayerChange 1 -allowJogging 1 -corePinTarget {stripe ring blockring}


#sroute -nets {VDD_CPU_OUT VSS} -allowLayerChange 1 -allowJogging 1 -corePinTarget {stripe ring blockring} -powerDomains PD_CPU  


#addRing -type core_rings -nets {VDD VSS} -layer {top M7 bottom M7 left M8 right M8} -offset 1 -width 4 -spacing 1.0

#addStripe -nets {VDD VSS} -direction horizontal -layer M7 -width 1 -set_to_set_distance 50 -ybottom_offset 1 -spacing 25

#addStripe -nets {VDD VSS} -direction vertical -layer M6 -width 1 -set_to_set_distance 50 -xleft_offset 1 -spacing 25

# TODO Need to implement follow pins (power rails)

# Full power grid generation from M8 to M6 using wires.
# # M2 to M5 are pretty much vias - on top of each other:
#sroute -nets {VDD VSS} -allowLayerChange 1 -allowJogging 1 -corePinTarget {stripe ring} 

#defOut -floorplan "../outputs/${top_design}.floorplan.innovus.def"

