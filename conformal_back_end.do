//lec -Gui -lp -1801

read design syn/verilog/top.sv -SystemVerilog -Golden -sensitive -continuousassignment Bidirectional -nokeep_unreach -nosupply

read library -Revised -Replace -sensitive -Statetable -Verilog saed32nm.v

read design apr/outputs/top_netlist_no_pg.vg -Verilog -Revised -sensitive -continuousassignment Bidirectional -nokeep_unreach -nosupply

read power intent -1801 -Both -replace syn/upf/top_down_upf.upf

commit power intent -golden -functional_insertion

read power intent -1801 -Both -replace apr/outputs/top_innov_upf.upf

commit power intent -revised -functional_insertion

set system mode lec

add compared points -all

Compare
