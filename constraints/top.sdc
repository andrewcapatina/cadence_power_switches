# Contstraints initially done similarly to fifo1_sram.sdc

create_clock -name "clk" -period 5.0 -waveform {0.0 2.5} clk
set_clock_uncertainty -setup 0.07 clk
set_clock_uncertainty -hold 0.01 clk

# set input delays
# set output delays

set_drive 0.001 [all_inputs]
set_load 0.5 [all_outputs]


group_path -name INPUTS -from [get_ports -filter "direction==in&&full_name!~*clk*"]
group_path -name OUTPUTS -to [get_ports -filter "direction==out"]
