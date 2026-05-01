//==============================================================================
// File    : ahb_sequencer.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 14/04/2026
//==============================================================================

class ahb_sequencer extends uvm_sequencer #(ahb_trans);
    `uvm_component_utils(ahb_sequencer)
    virtual ahb_if vif;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction :  new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual ahb_if)::get(this, "", "vif", vif))
            `uvm_fatal("SEQ", "Cannot get vif in sequencer")
    endfunction

endclass : ahb_sequencer