package test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import env_pkg::*;
    import ahb_pkg::*;
    `include "tb_config.sv"
    // Test
    `include "base_test.sv"
    `include "tc_smoke_test.sv"
    //`include "tc_reset_all_regs.sv"

endpackage : test_pkg