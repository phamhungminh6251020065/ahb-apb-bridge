//==============================================================================
// File    : ahb_hresp_okay_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 16/05/2026
//------------------------------------------------------------------------------
// Description:
// Write/read đến 3 Slave range → HRESP=00(OKAY) trong toàn bộ transfer.
//==============================================================================

class ahb_hresp_okay_seq extends ahb_base_seq;

    `uvm_object_utils(ahb_hresp_okay_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    function new(string name = "ahb_hresp_okay_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rdata;
        `uvm_info("HRESP_OKAY_SEQ", "=== AHB HRESP OKAY TEST START ===", UVM_LOW)

        // Write to Slave 0
        do_write(32'h4000_0004, 32'h0000_00FF);
        // Read from Slave 0
        do_read(32'h4000_0004, rdata);
        // Write to Slave 1
        do_write(32'h4001_0000, 32'h0000_0001);
        // Read from Slave 1
        do_read(32'h4001_0000, rdata);
        // Write to Slave 2
        do_write(32'h4002_0000, 32'hABCD_EF01);
        // Read from Slave 2
        do_read(32'h4002_0000, rdata);
        `uvm_info("HRESP_OKAY_SEQ", "=== AHB HRESP OKAY TEST DONE ===", UVM_LOW)
    endtask
endclass : ahb_hresp_okay_seq