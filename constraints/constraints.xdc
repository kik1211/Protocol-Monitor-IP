## ============================================================================
## File: constraints.xdc
## Project: Protocol-Monitor-IP
## Board Target: Avnet ZedBoard (xc7z020clg484-1)
## Description: Physical pin assignments for 100 MHz clock (Y9), DIP switches
##              sw[7:0], LEDs led[7:0], and Xilinx ILA debug core u_ila_0.
## ============================================================================

## ================================
## CLOCK (100 MHz)
## ================================
set_property PACKAGE_PIN Y9 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 [get_ports clk]

## ================================
## SWITCHES SW0 - SW7
## ================================
set_property PACKAGE_PIN F22 [get_ports {sw[0]}]
set_property PACKAGE_PIN G22 [get_ports {sw[1]}]
set_property PACKAGE_PIN H22 [get_ports {sw[2]}]
set_property PACKAGE_PIN F21 [get_ports {sw[3]}]
set_property PACKAGE_PIN H19 [get_ports {sw[4]}]
set_property PACKAGE_PIN H18 [get_ports {sw[5]}]
set_property PACKAGE_PIN H17 [get_ports {sw[6]}]
set_property PACKAGE_PIN M15 [get_ports {sw[7]}]

set_property IOSTANDARD LVCMOS18 [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sw[7]}]

## ================================
## LEDs LD0 - LD7
## ================================
set_property PACKAGE_PIN T22 [get_ports {led[0]}]
set_property PACKAGE_PIN T21 [get_ports {led[1]}]
set_property PACKAGE_PIN U22 [get_ports {led[2]}]
set_property PACKAGE_PIN U21 [get_ports {led[3]}]
set_property PACKAGE_PIN V22 [get_ports {led[4]}]
set_property PACKAGE_PIN W22 [get_ports {led[5]}]
set_property PACKAGE_PIN U19 [get_ports {led[6]}]
set_property PACKAGE_PIN U14 [get_ports {led[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {dbg_d[0]} {dbg_d[1]} {dbg_d[2]} {dbg_d[3]} {dbg_d[4]} {dbg_d[5]} {dbg_d[6]} {dbg_d[7]} {dbg_d[8]} {dbg_d[9]} {dbg_d[10]} {dbg_d[11]} {dbg_d[12]} {dbg_d[13]} {dbg_d[14]} {dbg_d[15]} {dbg_d[16]} {dbg_d[17]} {dbg_d[18]} {dbg_d[19]} {dbg_d[20]} {dbg_d[21]} {dbg_d[22]} {dbg_d[23]} {dbg_d[24]} {dbg_d[25]} {dbg_d[26]} {dbg_d[27]} {dbg_d[28]} {dbg_d[29]} {dbg_d[30]} {dbg_d[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 4 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {violation_code[0]} {violation_code[1]} {violation_code[2]} {violation_code[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list dbg_r]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list dbg_v]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list protocol_violation_sticky]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_IBUF_BUFG]
