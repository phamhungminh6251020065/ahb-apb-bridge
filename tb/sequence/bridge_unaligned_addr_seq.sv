//==============================================================================
// File    : bridge_unaligned_addr_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 19/05/2026
//------------------------------------------------------------------------------
// Description:
// Transfer đến địa chỉ không word-aligned (0x4000_0001, 0x4000_0002) → verify hành vi
//==============================================================================

class bridge_unaligned_addr_seq extends ahb_base_seq;
    `uvm_object_utils(bridge_unaligned_addr_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)


    function new(string name = "bridge_unaligned_addr_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rd_data;

        `uvm_info("UNALIGNED_ADDR_SEQ", "=== AHB UNALIGNED ADDRESS TEST START ===", UVM_LOW)

        // Ghi đến địa chỉ không word-aligned
        do_write(32'h4000_0001, 32'hDEAD_BEEF);
        do_write(32'h4000_0002, 32'hCAFEBABE);

        // Đọc lại để verify
        do_read(32'h4000_0001, rd_data);
        do_read(32'h4000_0002, rd_data);

        `uvm_info("UNALIGNED_ADDR_SEQ", "=== AHB UNALIGNED ADDRESS TEST DONE ===", UVM_LOW)
    endtask : body
endclass : bridge_unaligned_addr_seq