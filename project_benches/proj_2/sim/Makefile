# Set the project home directory
export ECE745_PROJECT_HOME ?= $(PWD)/../../..

# Include other Makefiles
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile

# Clean up generated files
clean: 
	rm -rf work *.wlf transcript

# Compile I2C related VHDL files
comp_I2C_MB:
	vcom ../rtl/iicmb_int_pkg.vhd
	vcom ../rtl/iicmb_pkg.vhd
	vcom ../rtl/mbyte.vhd
	vcom ../rtl/mbit.vhd
	vcom ../rtl/bus_state.vhd
	vcom ../rtl/filter.vhd
	vcom ../rtl/conditioner.vhd
	vcom ../rtl/conditioner_mux.vhd
	vcom ../rtl/iicmb_m.vhd
	vcom ../rtl/regblock.vhd
	vcom ../rtl/wishbone.vhd
	vcom ../rtl/iicmb_m_wb.vhd

# Compile various verification IP packages and the testbench
comp_bench: comp_ncsu_pkg comp_wb_pkg comp_i2c_pkg comp_i2cmb_env_pkg
	vlog ../testbench/top.sv

# Optimize the design
optimize:
	vopt +acc top -o optimized_debug_top_tb

# Full compile step, including the I2C and testbench compilation
compile: comp_I2C_MB comp_bench optimize

# Simulation step with the necessary plusarg for GEN_TRANS_TYPE
simulate:
	vsim -i -classdebug -msgmode both +GEN_TRANS_TYPE=direct -do "set NoQuitOnFinish 1; do wave.do" optimized_debug_top_tb

# Debug step, which cleans up, compiles, and simulates
debug: clean compile simulate
