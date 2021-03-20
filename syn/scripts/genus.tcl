
#set_db init_lib_search_path "/pkgs/synopsys/2020/saed14nm/stdcell_rvt/db_nldm /pkgs/synopsys/2020/saed14nm/SAED14nm_EDK_SRAM_v_05072020/lib/sram/logic_synth/single /pkgs/synopsys/2020/saed14nm/SAED14nm_EDK_IO_v_06052019/SAED14_EDK/lib/io_std/db_nldm"

#set_db library "saed14rvt_ss0p72v25c.lib saed14rvt_pg_ss0p72v25c.lib saed14sram_ss0p72v25c.lib saed14io_wb_ss0p72v25c_1p62v.lib"

set_db init_lib_search_path "/pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_hvt/db_nldm /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/stdcell_lvt/db_nldm /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/io_std/db_nldm /pkgs/synopsys/2020/32_28nm/SAED32_EDK/lib/sram/db_nldm ."

# Includes standard cells, IOs, SRAMs, and power switches.
set_db library "saed32rvt_ss0p95v125c.lib saed32io_wb_ss0p95v125c_2p25v.lib saed32sram_ss0p95v125c.lib saed32rvt_pg_ss0p95v125c.lib"

set top_design top

set_db auto_ungroup none

read_hdl -language sv ../verilog/top.sv

read_power_intent -1801 ../upf/upf.upf -module top

elaborate $top_design
# elaborate cpu only for debug step.

apply_power_intent -design $top_design -module $top_design -summary
commit_power_intent -design $top_design

source -echo -verbose ../../constraints/top.sdc

syn_generic

uniquify $top_design

syn_map

syn_opt

write_hdl ${top_design} > ../outputs/${top_design}.genus_syn.vg
write_power_intent -1801 -base_name ../outputs/${top_design}_genus_upf
