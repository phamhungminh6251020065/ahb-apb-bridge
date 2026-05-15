//==============================================================================
// File    : apb_timer_disable_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 14/05/2026
//------------------------------------------------------------------------------
// Description:
//  EN=0 khi CNT đang tăng → đọc lại CNT sau 10 cycle → CNT không đổi (timer giữ nguyên giá trị khi disable).
//==============================================================================

class apb_timer_disable_seq extends ahb_base_seq;
    `uvm_object_utils(apb_timer_disable_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    function new(string name = "apb_timer_disable_seq");
        super.new(name);
    endfunction

    virtual task body();

        logic [31:0] cnt_before_disable;
        logic [31:0] cnt_after_disable;

        `uvm_info("TIMER_DISABLE_SEQ", "=== APB TIMER DISABLE TEST START ===", UVM_LOW)

        //--------------------------------------------
        // Configure timer
        //--------------------------------------------
        do_write(32'h4001_0008, 32'h0000_000A); // PERIOD = 10

        do_write(32'h4001_0000, 32'h0000_0001); // ENABLE = 1

        `uvm_info("TIMER_DISABLE_SEQ", "Timer enabled", UVM_LOW)

        //--------------------------------------------
        // Let counter run
        //--------------------------------------------
        repeat (20) @(posedge p_sequencer.vif.HCLK);

        //--------------------------------------------
        // Read CNT before disable
        //--------------------------------------------
        do_read(32'h4001_0004, cnt_before_disable);

        //--------------------------------------------
        // Disable timer
        //--------------------------------------------
        do_write(32'h4001_0000, 32'h0000_0000);

        `uvm_info("TIMER_DISABLE_SEQ", "Timer disabled", UVM_LOW)

        //--------------------------------------------
        // Wait more cycles
        //--------------------------------------------
        repeat (10) @(posedge p_sequencer.vif.HCLK);

        //--------------------------------------------
        // Read CNT again
        //--------------------------------------------
        do_read(32'h4001_0004, cnt_after_disable);

        `uvm_info("TIMER_DISABLE_SEQ",
                  "=== APB TIMER DISABLE TEST DONE ===",
                  UVM_LOW)
    endtask

endclass