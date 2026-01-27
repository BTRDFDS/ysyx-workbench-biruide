yosys -import
read_verilog water.v
show -format png -prefix ./water0
hierarchy -check -top water
show -format png -prefix ./water1hierarchy
write_rtlil water1hierarchy.rtlil
yosys proc
show -format png -prefix ./water2proc
opt fsm memory
show -format png -prefix ./water3opt
techmap
splitnets -ports
#show -format png -prefix ./water4techmap
opt -full
#show -format png -prefix ./water5opt2
dfflibmap -liberty cell.lib
read_liberty -lib cell.lib
#show -format png -prefix ./water6dfflibmap
abc -liberty cell.lib
#show -format png -prefix ./water7abc
write_verilog water_netlist.v
stat -liberty cell.lib