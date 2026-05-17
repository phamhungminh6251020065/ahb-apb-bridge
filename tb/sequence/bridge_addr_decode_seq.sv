//==============================================================================
// File    : bridge_addr_decode_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 18/05/2026
//------------------------------------------------------------------------------
// Description:
// HADDR[31:16]=4000→PSEL1=1, 4001→PSEL2=1, 4002→PSEL3=1. Chỉ 1 PSELx active tại 1 thời điểm.
//==============================================================================

class bridge_addr_decode_seq extends ahb_base_seq;
    `uvm_object_utils(bridge_addr_decode_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    function new(string name = "bridge_addr_decode_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rdata;
        `uvm_info("ADDR_DECODE_SEQ", "=== AHB ADDRESS DECODE TEST START ===", UVM_LOW)

        //--------------------------------------------
        // WRITE transfer
        //--------------------------------------------
        do_write(32'h4000_0004, 32'h0000_00FF); // DIR = all output
        do_write(32'h4001_0008, 32'h0000_000A); // PERIOD = 10
        do_write(32'h4002_0000, 32'hDEAD_BEEF); // RegFile[0] = 0xDEAD_BEEF

        //Read back to verify
        do_read (32'h4000_0004, rdata); // Read GPIO DIR
        do_read (32'h4001_0008, rdata); // Read Timer PERIOD
        do_read (32'h4002_0000, rdata); // Read RegFile
        `uvm_info("ADDR_DECODE_SEQ", "=== AHB ADDRESS DECODE TEST END ===", UVM_LOW)
    endtask : body
endclass : bridge_addr_decode_seq
