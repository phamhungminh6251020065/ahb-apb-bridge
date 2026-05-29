//==============================================================================
// File    : cov_timer_invalid_offset_seq.sv
// Project : AHB-to-APB Bridge
//------------------------------------------------------------------------------
// Description:
//  Coverage-directed sequence for TIMER invalid local offset.
//  Address 0x4001_000C selects TIMER but is outside its valid register map,
//  so PSLVERR2 should be asserted by apb_slave_timer.
//==============================================================================

class cov_timer_invalid_offset_seq extends ahb_base_seq;
    `uvm_object_utils(cov_timer_invalid_offset_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    function new(string name = "cov_timer_invalid_offset_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rdata;

        `uvm_info("COV_TIMER_INV_SEQ", "=== COV TIMER INVALID OFFSET START ===", UVM_LOW)

        do_write(32'h4001_000C, 32'hCAFE_BABE);

        do_write(32'h4001_0008, 32'd20);
        do_write(32'h4001_0000, 32'h0000_0001);
        do_read (32'h4001_0008, rdata);

        `uvm_info("COV_TIMER_INV_SEQ", "=== COV TIMER INVALID OFFSET DONE ===", UVM_LOW)
    endtask : body
endclass : cov_timer_invalid_offset_seq
