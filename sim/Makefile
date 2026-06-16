#===============================================================================
# Makefile for QuestaSim/UVM Verification Environment
# Project : AHB-to-APB Bridge
# Author  : Pham Hung Minh
#===============================================================================
#
# HOW TO USE
# ------------------------------------------------------------------------------
# 1. Compile design and testbench
#    make comp
#
# 2. Run simulation
#    make sim TEST=<test_name>
#
#    Example:
#    make sim TEST=tc_bridge_cross_slave
#
# 3. Open waveform GUI
#    make wave TEST=<test_name>
#
# 4. Re-open saved waveform
#    make rewave TEST=<test_name>
#
# 5. Generate full coverage report
#    make cov TEST=<test_name>
#
# 6. Generate Functional Coverage report only
#    make func_cov TEST=<test_name>
#
# 7. Generate Code Coverage report only
#    make code_cov TEST=<test_name>
#
# 8. Open coverage database GUI
#    make cov_gui TEST=<test_name>
#
# 9. Run regression
#    make regression
#
# 10. Merge all UCDB databases from regression
#     make merge_cov
#
# 11. Generate merged regression coverage reports
#     make regression_func_cov
#     make regression_code_cov
#
# 12. One-command flow
#     make run_cov TEST=<test_name>
#     make run_func_cov TEST=<test_name>
#     make run_code_cov TEST=<test_name>
#
# 13. Clean generated files
#     make clean
#
#===============================================================================


#===============================================================================
# DIRECTORY CONFIGURATION
#===============================================================================

# Workspace directory
# Use Windows-style paths because Questa cannot properly handle
# MSYS paths (/m/...) when saving UCDB databases.
WORK_DIR=$(shell cygpath -m "$$(pwd)")

# Log directories
LOG_DIR=$(WORK_DIR)/log
COMP_DIR=$(LOG_DIR)/comp
SIM_DIR=$(LOG_DIR)/sim
WAVE_DIR=$(LOG_DIR)/wave

# Coverage directory
COV_DIR=$(WORK_DIR)/cov


#===============================================================================
# COVERAGE OUTPUT FILES
#===============================================================================

# Single test UCDB database
UCDB=$(COV_DIR)/$(TEST).ucdb

# Functional coverage reports
FUNC_COV_TXT=$(COV_DIR)/$(TEST)_func_cov.log
FUNC_COV_HTML=$(COV_DIR)/$(TEST)_func_cov_html

# Code coverage reports
CODE_COV_TXT=$(COV_DIR)/$(TEST)_code_cov.log
CODE_COV_HTML=$(COV_DIR)/$(TEST)_code_cov_html

# Merged regression coverage database
MERGED_UCDB=$(COV_DIR)/regression_all.ucdb

# Merged regression functional coverage reports
MERGED_FUNC_COV_TXT=$(COV_DIR)/regression_all_func_cov.log
MERGED_FUNC_COV_HTML=$(COV_DIR)/regression_all_func_cov_html

# Merged regression code coverage reports
MERGED_CODE_COV_TXT=$(COV_DIR)/regression_all_code_cov.log
MERGED_CODE_COV_HTML=$(COV_DIR)/regression_all_code_cov_html

# All UCDB files except merged database
REG_UCDBS=$(filter-out $(MERGED_UCDB),$(wildcard $(COV_DIR)/*.ucdb))


#===============================================================================
# DESIGN CONFIGURATION
#===============================================================================

# Top-level testbench module
TOP=tb_top

# Optional standalone tops
# TOP=tb_apb_slave_timer
# TOP=tb_apb_slave_regfile
# TOP=tb_bridge_apb_slave
# TOP=tb_ahb_arbiter
# TOP=tb_ahb_master
# TOP=tb_ahb_system
# TOP=tb_smoke_test

# Questa working library
WORK=work

# File list
COMP=run.f


#===============================================================================
# DEFAULT SIMULATION SETTINGS
#===============================================================================

# Default UVM test
TEST ?= base_test

# Default verbosity
VERBOSITY ?= UVM_HIGH

# Default random seed
SEED ?= random

# Arbiter mode
# 0 = Fixed Priority
# 1 = Round Robin
ARBITER_MODE ?= 0


#===============================================================================
# SIMULATION OPTIONS
#===============================================================================

SIM_OPTIONS += +UVM_VERBOSITY=$(VERBOSITY)
SIM_OPTIONS += -sv_seed $(SEED)
SIM_OPTIONS += +UVM_TESTNAME=$(TEST)
SIM_OPTIONS += +TESTNAME=$(TEST)
SIM_OPTIONS += -GARBITER_MODE=$(ARBITER_MODE)


#===============================================================================
# PHONY TARGETS
#===============================================================================

.PHONY: \
	all \
	comp \
	sim \
	wave \
	rewave \
	regression \
	cov \
	func_cov \
	code_cov \
	merge_cov \
	regression_func_cov \
	regression_code_cov \
	run_cov \
	run_func_cov \
	run_code_cov \
	regression_cov \
	cov_gui \
	clean


#===============================================================================
# WAVEFORM GUI
#===============================================================================

wave:
	mkdir -p $(WAVE_DIR)

	vsim -wlf $(WAVE_DIR)/$(TEST).wlf \
	     -coverage \
	     -sv_lib $(UVM_HOME)/win64/uvm_dpi \
	     -debugdb=+acc \
	     -uvmcontrol=all \
	     -classdebug \
	     -l $(WAVE_DIR)/$(TEST)_wave.log \
	     $(WORK).$(TOP) $(SIM_OPTIONS)


#===============================================================================
# RE-OPEN SAVED WAVEFORM
#===============================================================================

rewave:
	vsim -view $(WAVE_DIR)/$(TEST).wlf -do wave_$(TEST).do


#===============================================================================
# REGRESSION
#===============================================================================

regression:
	python regression/run_regression.py


#===============================================================================
# COMPILE
#===============================================================================

comp:
	mkdir -p $(COMP_DIR)

	# Create and map Questa work library
	vlib $(WORK)
	vmap $(WORK) $(WORK)

	# Compile RTL + TB with coverage enabled
	vlog -sv +acc \
	     -cover bcesf \
	     +incdir+$(UVM_HOME)/src \
	     $(UVM_HOME)/src/uvm_pkg.sv \
	     -l $(COMP_DIR)/$(TEST)_compile.log \
	     -f $(COMP)


#===============================================================================
# SIMULATION
#===============================================================================

sim:
	mkdir -p $(SIM_DIR) $(COV_DIR) $(WAVE_DIR)

	# Run simulation and save UCDB coverage database
	vsim -coverage -c \
	     -sv_lib $(UVM_HOME)/win64/uvm_dpi \
	     -do "coverage save -onexit $(UCDB); run -all; quit -f" \
	     -l $(SIM_DIR)/$(TEST)_simulate.log \
	     $(WORK).$(TOP) $(SIM_OPTIONS)


#===============================================================================
# GENERATE FULL COVERAGE REPORT
#===============================================================================

cov:
	mkdir -p $(COV_DIR)

	# HTML coverage report
	vcover report \
	    $(UCDB) \
	    -details \
	    -html -htmldir $(COV_DIR)/$(TEST)_html

	# Text coverage report
	vcover report \
	    $(UCDB) \
	    -details \
	    -output $(COV_DIR)/$(TEST)_cov.log


#===============================================================================
# FUNCTIONAL COVERAGE REPORT
#===============================================================================

func_cov:
	mkdir -p $(COV_DIR)

	# Text report
	vcover report \
	    -cvg -covered -details \
	    -output $(FUNC_COV_TXT) \
	    $(UCDB)

	# HTML report
	vcover report \
	    -html -cvg -details \
	    -htmldir $(FUNC_COV_HTML) \
	    $(UCDB)


#===============================================================================
# CODE COVERAGE REPORT
#===============================================================================

code_cov:
	mkdir -p $(COV_DIR)

	# Text report
	MSYS2_ARG_CONV_EXCL=/tb_top/dut vcover report \
	    -code bcesf -details -zeros -instance /tb_top/dut -recursive \
	    -output $(CODE_COV_TXT) \
	    $(UCDB)

	# HTML report
	MSYS2_ARG_CONV_EXCL=/tb_top/dut vcover report \
	    -html -code bcesf -details -instance /tb_top/dut \
	    -htmldir $(CODE_COV_HTML) \
	    $(UCDB)


#===============================================================================
# MERGE COVERAGE DATABASES
#===============================================================================

merge_cov:
	mkdir -p $(COV_DIR)

	vcover merge $(MERGED_UCDB) $(REG_UCDBS)


#===============================================================================
# REGRESSION FUNCTIONAL COVERAGE
#===============================================================================

regression_func_cov: merge_cov

	vcover report \
	    -cvg -covered -details \
	    -output $(MERGED_FUNC_COV_TXT) \
	    $(MERGED_UCDB)

	vcover report \
	    -html -cvg -details \
	    -htmldir $(MERGED_FUNC_COV_HTML) \
	    $(MERGED_UCDB)


#===============================================================================
# REGRESSION CODE COVERAGE
#===============================================================================

regression_code_cov: merge_cov

	MSYS2_ARG_CONV_EXCL=/tb_top/dut vcover report \
	    -code bcesf -details -zeros -instance /tb_top/dut -recursive \
	    -output $(MERGED_CODE_COV_TXT) \
	    $(MERGED_UCDB)
		
	MSYS2_ARG_CONV_EXCL=/tb_top/dut vcover report \
	    -html -code bcesf -details -instance /tb_top/dut \
	    -htmldir $(MERGED_CODE_COV_HTML) \
	    $(MERGED_UCDB)


#===============================================================================
# ONE-COMMAND FLOWS
#===============================================================================

run_cov: comp sim cov

run_func_cov: comp sim func_cov

run_code_cov: comp sim code_cov

regression_cov: comp regression regression_func_cov regression_code_cov


#===============================================================================
# OPEN COVERAGE GUI
#===============================================================================

cov_gui:
	vsim -viewcov $(UCDB)


#===============================================================================
# CLEAN GENERATED FILES
#===============================================================================

clean:
	rm -rf \
	    $(WORK) \
	    $(COMP_DIR) \
	    $(SIM_DIR) \
	    $(COV_DIR) \
	    transcript \
	    vsim.ucdb \
	    covhtmlreport \
	    *.log \
	    *.tcl \
	    *.vstf


#===============================================================================
# DEFAULT TARGET
#===============================================================================

all: clean comp sim