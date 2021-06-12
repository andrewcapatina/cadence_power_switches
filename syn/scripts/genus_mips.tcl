
set_db init_lib_search_path "/pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_hvt/db_nldm /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_lvt/db_nldm /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/io_std/db_nldm /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/sram/db_nldm ."

# Includes standard cells, IOs, SRAMs, and power switches.
set_db library "saed32rvt_ss0p95v125c.lib saed32io_wb_ss0p95v125c_2p25v.lib saed32sram_ss0p95v125c.lib saed32rvt_pg_ss0p95v125c.lib"

set top_design top

set_db auto_ungroup none

read_hdl -language sv ../verilog/$top_design.sv

read_power_intent -1801 ../upf/top_down_upf.upf -module $top_design

elaborate $top_design
# elaborate cpu only for debug step.

set_db [get_db design:$top_design .modules *] .delete_unloaded_seqs false
set_db [get_db design:$top_design .modules *] .boundary_opto strict_no
set_db delete_unloaded_seqs false
set_db optimize_constant_0_flops false
set_db optimize_constant_1_flops false

apply_power_intent -design $top_design -module $top_design -summary
commit_power_intent -design $top_design

source -echo -verbose ../../constraints/$top_design.sdc

syn_generic

uniquify $top_design

syn_map

set_db [get_db design:$top_design .modules *] .preserve true

syn_opt

write_hdl ${top_design} > ../outputs/${top_design}.genus_syn.vg
write_power_intent -1801 -base_name ../outputs/${top_design}_genus_upf



