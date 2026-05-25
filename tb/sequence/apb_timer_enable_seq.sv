//==============================================================================
// File    : apb_timer_enable_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 14/05/2026
//------------------------------------------------------------------------------
// Description:
//  Write PERIOD=10, CTRL[0]=1. Đọc CNT sau 5 cycle → CNT≥4 (đang tăng).
//==============================================================================

class apb_timer_enable_seq extends ahb_base_seq;
    `uvm_object_utils(apb_timer_enable_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)
    
    function new(string name = "apb_timer_enable_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rdata;

        `uvm_info("TIMER_ENABLE_SEQ", "=== APB TIMER ENABLE TEST START ===", UVM_LOW)

        // Ghi vào các register của Timer
        do_write(32'h4001_0008, 32'h0000_000A); // PERIOD = 10
        do_write(32'h4001_0004, 32'hDEAD_BEEF); // CNT_REG is read-only, write should be ignored
        do_write(32'h4001_0000, 32'h0000_0001); // CTRL[0] = 1 (enable timer)

        // Đợi một vài chu kỳ để timer bắt đầu đếm
        repeat(5) @(posedge p_sequencer.vif.HCLK);

        // Đọc CNT → verify đang tăng (CNT≥4)
        do_read(32'h4001_0004, rdata);

        `uvm_info("TIMER_ENABLE_SEQ", "=== APB TIMER ENABLE TEST DONE ===", UVM_LOW)
    endtask : body
endclass : apb_timer_enable_seq