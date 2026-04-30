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

    function new(string name = "reset_all_regs_seq");
        super.new(name);
    endfunction

    virtual task body();
        logic [31:0] rdata;

        `uvm_info("RESET_SEQ", "=== RESET ALL REGS TEST START ===", UVM_LOW)

        // =========================================================
        // 1. RegFile (0x4002_xxxx) → expect = 0
        // =========================================================
        `uvm_info("RESET_SEQ", "-- Check RegFile default --", UVM_LOW)

        do_read(32'h4002_0000, rdata);
        do_read(32'h4002_0004, rdata);
        do_read(32'h4002_0008, rdata);
        do_read(32'h4002_000C, rdata);
        do_read(32'h4002_0010, rdata);
        do_read(32'h4002_0014, rdata);
        do_read(32'h4002_0018, rdata);
        do_read(32'h4002_001C, rdata);

        // =========================================================
        // 2. GPIO (0x4000_xxxx) → DIR = 0, DATA = 0
        // =========================================================
        `uvm_info("RESET_SEQ", "-- Check GPIO default --", UVM_LOW)

        do_read(32'h4000_0000, rdata); // DATA
        do_read(32'h4000_0004, rdata); // DIR

        // =========================================================
        // 3. Timer (0x4001_xxxx)
        // CNT = 0
        // PERIOD = 0xFFFFFFFF
        // =========================================================
        `uvm_info("RESET_SEQ", "-- Check Timer default --", UVM_LOW)

        do_read(32'h4001_0004, rdata); // CNT
        do_read(32'h4001_0008, rdata); // PERIOD

        `uvm_info("RESET_SEQ", "=== RESET ALL REGS TEST DONE ===", UVM_LOW)

    endtask
endclass