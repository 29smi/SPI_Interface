##################################
# Input/Output Constraints File
##################################
set SCLK_PERIOD 10000.00 
set SCLK_LATENCY 1.00
set SCLK_SKEW 0.50
set SCLK_JITTER 0.20
set SETUP_UNCERTAINTY [expr $SCLK_SKEW + $SCLK_JITTER]
set INPUT_DELAY 1.00
set OUTPUT_DELAY 1.00

#######################
### Clock constraints
#######################
create_clock SCLK -period $SCLK_PERIOD -waveform {0.0 5.0}
    ### remember to update -waveform when you change clock period
set_clock_latency $SCLK_LATENCY SCLK
set_clock_uncertainty -setup $SETUP_UNCERTAINTY SCLK
set_clock_uncertainty -hold $SCLK_SKEW SCLK
set_clock_transition -rise 0.1 SCLK
set_clock_transition -fall 0.12 SCLK

# Virtual clock for input/output signals
create_clock -name v_SCLK -period $SCLK_PERIOD -waveform {0.0 5.0}
    ### remember to update -waveform when you change clock period

#######################
### Max transition/capacitance
#######################
set_max_transition 1.5 [current_design]
set_max_capacitance 0.5 [current_design]

#######################
#### Input constraints
#######################
set_input_delay $INPUT_DELAY -clock v_SCLK [remove_from_collection [all_inputs] SCLK]
set_max_fanout 1 [all_inputs]
set_input_transition -rise 0.1 [all_inputs]
set_input_transition -fall 0.12 [all_inputs]

#######################
#### Outputs constraints
#######################
set_output_delay $OUTPUT_DELAY -clock v_SCLK [all_outputs]
set_load 0.2 [all_outputs]
