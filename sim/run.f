+incdir+$UVM_HOME/src
-timescale 1ns/1ns

+incdir+../tb
+incdir+../tb/interface
+incdir+../tb/pkg
+incdir+../tb/transaction
+incdir+../tb/sequence
+incdir+../tb/agent/ahb_agent
+incdir+../tb/agent/apb_agent
+incdir+../tb/env
+incdir+../tb/test
+incdir+../tb/config

// Interface
../tb/interface/ahb_if.sv
../tb/interface/apb_if.sv

// Package
../tb/pkg/ahb_pkg.sv
../tb/pkg/apb_pkg.sv
../tb/pkg/env_pkg.sv
../tb/pkg/test_pkg.sv

// ============ RTL ============
// [DONE] apb_slave_regfile
../rtl/apb_slave_gpio.v
../rtl/apb_slave_timer.v
../rtl/apb_slave_regfile.v
../rtl/bridge_addr_decoder.v
../rtl/bridge_prdata_mux.v
../rtl/bridge_fsm.v
../rtl/bridge_top.v
../rtl/ahb_arbiter.v
../rtl/ahb_master.v
../rtl/ahb_interconnect.v
../rtl/top.v
../rtl/dut_top.v

// ============ TB ============

// Testbench top
../tb/tb_top.sv

// Các testbench tạm thời dùng trong lúc design RTL
// ../temp/tb_apb_slave_timer.sv
// ../temp/tb_apb_slave_regfile.sv
// ../temp/tb_bridge_apb_slave.sv
// ../temp/tb_ahb_arbiter.sv
// ../temp/tb_ahb_master.sv
// ../temp/tb_ahb_system.sv
// ../temp/tb_smoke_test.sv

