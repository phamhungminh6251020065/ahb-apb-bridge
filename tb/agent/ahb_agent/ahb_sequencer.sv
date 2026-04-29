//==============================================================================
// File    : ahb_sequencer.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 14/04/2026
//==============================================================================

class ahb_sequencer extends uvm_sequencer #(ahb_trans);
    `uvm_component_utils(ahb_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction :  new
endclass : ahb_sequencer