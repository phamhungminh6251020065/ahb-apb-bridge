#============================================
#	Makefile for Questatim
#============================================

#===============================DIRECTORY===============================
#Workspace directory
WORK_DIR=$(shell pwd)
#Log directory
LOG_DIR=$(WORK_DIR)/log
#Compile directory
COMP_DIR=$(LOG_DIR)/comp
#Simulation directory
SIM_DIR=$(LOG_DIR)/sim
#Wave directory
WAVE_DIR=$(LOG_DIR)/wave
#Coverage directory
COV_DIR=$(WORK_DIR)/cov

#Top module name
TOP=tb_top
# TOP=tb_apb_slave_timer
# TOP=tb_apb_slave_regfile
# TOP=tb_bridge_apb_slave
# TOP=tb_ahb_arbiter
# TOP=tb_ahb_master
# TOP=tb_ahb_system
# TOP=tb_smoke_test

#Working library name
WORK=work
#File containing compilation list
COMP=run.f

# Default test name (can be overridden on command line)
TEST ?= base_test
# Default UVM Verbosity (can be overridden on command line)
VERBOSITY ?= UVM_HIGH
# Default seed (can be overridden on command line)
SEED ?= random

#===============================SIMULATION OPTIONS===============================
SIM_OPTIONS += +UVM_VERBOSITY=$(VERBOSITY) 
SIM_OPTIONS +=-sv_seed $(SEED)
SIM_OPTIONS += +UVM_TESTNAME=$(TEST)

#===============================COMMANDS===============================

.PHONY: all comp sim wave clean

wave:
	mkdir -p $(WAVE_DIR)
# 	vsim -debugdb=+acc -l $(WAVE_DIR)/$(TEST)_wave.log $(WORK).$(TOP)
# 	vsim -sv_lib $(UVM_HOME)/win64/uvm_dpi -debugdb=+acc \
# 	     -l $(WAVE_DIR)/$(TEST)_wave.log \
# 	     $(WORK).$(TOP) $(SIM_OPTIONS)
# 	vsim -sv_lib $(UVM_HOME)/win64/uvm_dpi \
#      -debugdb=+acc \
#      -uvmcontrol=all \
#      -classdebug \
#      -l $(WAVE_DIR)/$(TEST)_wave.log \
#      $(WORK).$(TOP) $(SIM_OPTIONS)

	vsim -coverage \
	     -sv_lib $(UVM_HOME)/win64/uvm_dpi \
		 -debugdb=+acc \
	     -uvmcontrol=all \
	     -classdebug \
	     -l $(WAVE_DIR)/$(TEST)_wave.log \
	     $(WORK).$(TOP) $(SIM_OPTIONS)


comp:
	mkdir -p $(COMP_DIR)
	vlog -sv +acc -cover bcesf +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv -l $(COMP_DIR)/$(TEST)_compile.log -f $(COMP)

sim:
	mkdir -p $(SIM_DIR)
#	vsim -c -sv_lib $(UVM_HOME)/win64/uvm_dpi -do "run -all; quit" -l simulate.log $(WORK).$(TOP) -f $(SIM) +UVM_TESTNAME=$(TEST) 
#	vsim -c -sv_lib $(UVM_HOME)/win64/uvm_dpi -do "run -all; quit" -l $(SIM_DIR)/$(TEST)_simulate.log $(WORK).$(TOP) $(SIM_OPTIONS)
	vsim -coverage -c -sv_lib $(UVM_HOME)/win64/uvm_dpi -do "run -all; coverage save -onexit vsim.ucdb; quit -f" -l $(SIM_DIR)/$(TEST)_simulate.log $(WORK).$(TOP) $(SIM_OPTIONS)

cov:
	mkdir -p $(SIM_DIR) $(COV_DIR)
# 	vcover report vsim.ucdb -html -htmldir $(COV_DIR)/covhtmlreport
# 	start msedge $(COV_DIR)/covhtmlreport/index.html

	vcover report vsim.ucdb \
	    -details \
	    -html -htmldir $(COV_DIR)/covhtmlreport

clean:
#	rm -rf $(WORK) $(COMP_DIR) $(SIM_DIR) $(WAVE_DIR) transcript
	rm -rf $(WORK) $(COMP_DIR) $(SIM_DIR) $(WAVE_DIR) $(COV_DIR) transcript vsim.ucdb covhtmlreport *.log *.tcl *.vstf

all:	clean comp sim
