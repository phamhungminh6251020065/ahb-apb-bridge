//==============================================================================
// File    : bridge_cross_slave_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 19/05/2026
//------------------------------------------------------------------------------
// Description:
// M1 ghi GPIO, ghi Timer PERIOD, ghi RegFile, rồi đọc lại 3 Slave → tất cả match.
//==============================================================================

class bridge_cross_slave_seq extends ahb_base_seq;
    `uvm_object_utils(bridge_cross_slave_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)


    function new(string name = "bridge_cross_slave_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rd_data;

        `uvm_info("CROSS_SLAVE_SEQ", "=== AHB CROSS-SLAVE TEST START ===", UVM_LOW)

        // Ghi GPIO
        do_write(32'h4000_0004, 32'h0000_00FF); // DIR = all output
        // Ghi Timer PERIOD
        do_write(32'h4001_0008, 32'h0000_0006); // PERIOD = 6
        // Ghi RegFile
        do_write(32'h4002_0000, 32'hDEAD_BEEF);

        // Đọc lại để verify
        do_read(32'h4000_0004, rd_data);
        do_read(32'h4001_0008, rd_data);
        do_read(32'h4002_0000, rd_data);

        `uvm_info("CROSS_SLAVE_SEQ", "=== AHB CROSS-SLAVE TEST DONE ===", UVM_LOW)
    endtask : body
endclass : bridge_cross_slave_seq