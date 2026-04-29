package env_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import ahb_pkg::*;
    import apb_pkg::*;

    // Env
    `include "coverage.sv"
    `include "scoreboard.sv"
    `include "env.sv"

endpackage : env_pkg