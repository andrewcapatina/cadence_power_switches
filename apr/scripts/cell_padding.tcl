

file delete ../scripts/cell_padding_commands.tcl

set fp [open ../scripts/cell_padding_commands.tcl w]

set coll [get_cells *]

foreach_in_collection i $coll {

	
	set cell [get_object_name $i]	
	set to_write "set_db place_global_module_padding {$cell 1.8}"

	puts $fp $to_write
}

set coll [get_cells mips/*/*/*]

foreach_in_collection i $coll {

	
	set cell [get_object_name $i]	
	set to_write "set_db place_global_module_padding {$cell 1.8}"

	puts $fp $to_write
}

set coll [get_cells dmem/*]

foreach_in_collection i $coll {

	
	set cell [get_object_name $i]	
	set to_write "set_db place_global_module_padding {$cell 1.5}"

	puts $fp $to_write
}

set coll [get_cells imem/*]

foreach_in_collection i $coll {

	
	set cell [get_object_name $i]	
	set to_write "set_db place_global_module_padding {$cell 1.7}"

	puts $fp $to_write
}

close $fp
