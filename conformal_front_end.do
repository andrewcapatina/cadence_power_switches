//lec -Gui -lp -1801

read design syn/verilog/top.sv -SystemVerilog -Golden -sensitive -continuousassignment Bidirectional -nokeep_unreach -nosupply

read library -Revised -Replace -sensitive -Statetable -Verilog saed32nm.v

read design syn/outputs/top.genus_syn.v -Verilog -Revised -sensitive -continuousassignment Bidirectional -nokeep_unreach -nosupply

read power intent -1801 -Both -replace syn/outputs/top_genus_upf.upf

commit power intent -golden -functional_insertion

commit power intent -revised -functional_insertion

set system mode lec

add compared points -all

Compare
