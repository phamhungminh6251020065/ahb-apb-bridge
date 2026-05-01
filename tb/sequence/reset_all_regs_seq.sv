//==============================================================================
// File    : reset_all_regs_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 30/04/2026
//------------------------------------------------------------------------------
// Description:
//   Reset tất cả các register về giá trị mặc định, đảm bảo hệ thống bắt đầu ở trạng thái sạch.
//==============================================================================

class reset_all_regs_seq extends ahb_base_seq;
    `uvm_object_utils(reset_all_regs_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    function new(string name = "reset_all_regs_seq");
        super.new(name);
    endfunction

    virtual task body();
        logic [31:0] rdata;

        `uvm_info("RESET_SEQ", "=== RESET REG TEST START ===", UVM_LOW)

        // 1. WRITE
        do_write(32'h4002_0000, 32'hDEAD_BEEF);
        do_write(32'h4002_0004, 32'hCAFE_BABE);
        do_write(32'h4002_0008, 32'h1234_5678);
        do_write(32'h4002_000C, 32'h8765_4321);
        do_write(32'h4000_0004, 32'h0000_00FF); // DIR = all output
        do_write(32'h4000_0000, 32'h0000_00A5); // DATA = 0xA5
        do_write(32'h4001_0008, 32'h0000_000A); // PERIOD = 10

        // 2. READ → expect written value
        do_read (32'h4002_0000, rdata);
        do_read (32'h4002_0004, rdata);
        do_read (32'h4002_0008, rdata);
        do_read (32'h4002_000C, rdata);
        do_read (32'h4000_0000, rdata);          // Read DATA
        do_read (32'h4000_0004, rdata);          // Read DIR
        do_read (32'h4001_0008, rdata);          // Read PERIOD
        repeat(2) @(posedge p_sequencer.vif.HCLK); // delay để đảm bảo read/write hoàn thành trước khi reset
        // 3. RESET
        do_reset();

        // 4. READ → expect default = 0
        do_read (32'h4002_0000, rdata);
        do_read (32'h4002_0004, rdata);
        do_read (32'h4002_0008, rdata);
        do_read (32'h4002_000C, rdata);
        do_read (32'h4000_0000, rdata);          // Read DATA
        do_read (32'h4000_0004, rdata);          // Read DIR
        do_read (32'h4001_0008, rdata);          // Read PERIOD

        `uvm_info("RESET_SEQ", "=== RESET REG TEST DONE ===", UVM_LOW)
    endtask
endclass