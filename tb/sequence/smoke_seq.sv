//==============================================================================
// File    : smoke_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 22/04/2026
//------------------------------------------------------------------------------
// Description:
//   Smoke sequence — kiểm tra cơ bản hệ thống trước khi chạy các test khác.
//   Ghi/đọc đến cả 3 APB Slave, không tự verify (để Scoreboard làm).
//   Đơn giản, nhanh, cover đủ path cơ bản.
//==============================================================================

class smoke_seq extends ahb_base_seq;
    `uvm_object_utils(smoke_seq)

    function new(string name = "smoke_seq");
        super.new(name);
    endfunction

    virtual task body();
        logic [31:0] rdata;

        `uvm_info("SMOKE_SEQ", "=== Smoke Sequence START ===", UVM_LOW)

        // ── 1. RegFile: ghi 4 register, đọc lại ─────────────────────────────
        `uvm_info("SMOKE_SEQ", "-- RegFile write/read --", UVM_LOW)
        do_write(32'h4002_0000, 32'hDEAD_BEEF);
        do_write(32'h4002_0004, 32'hCAFE_BABE);
        do_write(32'h4002_0008, 32'h1234_5678);
        do_write(32'h4002_000C, 32'h8765_4321);
        do_read (32'h4002_0000, rdata);
        do_read (32'h4002_0004, rdata);
        do_read (32'h4002_0008, rdata);
        do_read (32'h4002_000C, rdata);

        // ── 2. GPIO: set DIR=output, ghi DATA, đọc lại ───────────────────────
        `uvm_info("SMOKE_SEQ", "-- GPIO write/read --", UVM_LOW)
        do_write(32'h4000_0004, 32'h0000_00FF); // DIR = all output
        do_write(32'h4000_0000, 32'h0000_00A5); // DATA = 0xA5
        do_read (32'h4000_0000, rdata);          // Read DATA
        do_read (32'h4000_0004, rdata);          // Read DIR

        // ── 3. Timer: set PERIOD, enable, đọc CNT ────────────────────────────
        `uvm_info("SMOKE_SEQ", "-- Timer write/read --", UVM_LOW)
        do_write(32'h4001_0008, 32'h0000_000A); // PERIOD = 10
        do_write(32'h4001_0000, 32'h0000_0001); // CTRL EN=1
        do_write(32'h4001_0000, 32'h0000_0000); // CTRL EN=0 → CNT hold
        do_read (32'h4001_0008, rdata);          // Read PERIOD
        do_read (32'h4001_0004, rdata);          // Read CNT (hold, không đổi)
        // do_write(32'h4001_0000, 32'h0000_0000); // CTRL EN=0

        `uvm_info("SMOKE_SEQ", "=== Smoke Sequence DONE ===", UVM_LOW)
    endtask

endclass : smoke_seq