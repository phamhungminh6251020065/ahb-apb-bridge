package ahb_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    // AHB 
    `include "ahb_trans.sv"
    `include "ahb_driver.sv"
    `include "ahb_sequencer.sv"
    `include "ahb_monitor.sv"
    `include "ahb_agent.sv"
    // Các sequences
    `include "ahb_base_seq.sv"
    `include "smoke_seq.sv"
    `include "reset_all_regs_seq.sv"
endpackage : ahb_pkg