package test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import env_pkg::*;
    import ahb_pkg::*;
    `include "tb_config.sv"
    // Test
    `include "base_test.sv"
    `include "tc_smoke_test.sv"
    `include "tc_smoke_test_m2.sv"
    `include "tc_smoke_test_rr.sv"
    `include "tc_smoke_test_both.sv"
    `include "tc_reset_all_regs.sv"
    `include "tc_reset_mid_transfer.sv"
    `include "tc_apb_pslverr.sv"
    `include "tc_apb_gpio_write_all.sv"
    `include "tc_apb_gpio_read_output.sv"
    `include "tc_apb_gpio_read_input.sv"
    `include "tc_apb_timer_enable.sv"
    `include "tc_apb_timer_irq.sv"
    `include "tc_apb_timer_disable.sv"
    `include "tc_apb_regfile_all.sv"
    `include "tc_ahb_wait_state.sv"
    `include "tc_ahb_hresp_okay.sv"
    `include "tc_ahb_invalid_addr.sv"
    `include "tc_ahb_busreq_grant.sv"
endpackage : test_pkg