#100 MHz clock

set_property PACKAGE_PIN  Y9 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10 [get_ports clk]


# reset
set_property PACKAGE_PIN R18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]


# SPI - JSTK2 (JA)
set_property PACKAGE_PIN Y19 [get_ports jstk_miso]
set_property IOSTANDARD LVCMOS33 [get_ports jstk_miso]

set_property PACKAGE_PIN AA11 [get_ports jstk_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports jstk_mosi]

set_property PACKAGE_PIN AA9 [get_ports jstk_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports jstk_sclk]

set_property PACKAGE_PIN Y11 [get_ports jstk_ss]
set_property IOSTANDARD LVCMOS33 [get_ports jstk_ss]
