###################################################################

# Created by write_sdc on Fri Nov 22 21:09:23 2024

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_max_capacitance 0.5 [current_design]
set_max_transition 1.5 [current_design]
set_load -pin_load 0.2 [get_ports MISO]
set_load -pin_load 0.2 [get_ports MISO_enable]
set_max_fanout 1 [get_ports SCLK]
set_max_fanout 1 [get_ports MOSI]
set_max_fanout 1 [get_ports CSN]
set_max_fanout 1 [get_ports rst_n]
create_clock [get_ports SCLK]  -period 10000  -waveform {0 5}
set_clock_latency 1  [get_clocks SCLK]
set_clock_uncertainty -setup 0.7  [get_clocks SCLK]
set_clock_uncertainty -hold 0.5  [get_clocks SCLK]
set_clock_transition -max -rise 0.1 [get_clocks SCLK]
set_clock_transition -min -rise 0.1 [get_clocks SCLK]
set_clock_transition -max -fall 0.12 [get_clocks SCLK]
set_clock_transition -min -fall 0.12 [get_clocks SCLK]
create_clock -name v_SCLK  -period 10000  -waveform {0 5}
set_input_delay -clock v_SCLK  1  [get_ports MOSI]
set_input_delay -clock v_SCLK  1  [get_ports CSN]
set_input_delay -clock v_SCLK  1  [get_ports rst_n]
set_output_delay -clock v_SCLK  1  [get_ports MISO]
set_output_delay -clock v_SCLK  1  [get_ports MISO_enable]
set_input_transition -max -rise 0.1  [get_ports SCLK]
set_input_transition -max -fall 0.12  [get_ports SCLK]
set_input_transition -min -rise 0.1  [get_ports SCLK]
set_input_transition -min -fall 0.12  [get_ports SCLK]
set_input_transition -max -rise 0.1  [get_ports MOSI]
set_input_transition -max -fall 0.12  [get_ports MOSI]
set_input_transition -min -rise 0.1  [get_ports MOSI]
set_input_transition -min -fall 0.12  [get_ports MOSI]
set_input_transition -max -rise 0.1  [get_ports CSN]
set_input_transition -max -fall 0.12  [get_ports CSN]
set_input_transition -min -rise 0.1  [get_ports CSN]
set_input_transition -min -fall 0.12  [get_ports CSN]
set_input_transition -max -rise 0.1  [get_ports rst_n]
set_input_transition -max -fall 0.12  [get_ports rst_n]
set_input_transition -min -rise 0.1  [get_ports rst_n]
set_input_transition -min -fall 0.12  [get_ports rst_n]
