//==============================================================================
// File    : apb_timer_enable_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 14/05/2026
//------------------------------------------------------------------------------
// Description:
//  Set PERIOD=5, EN=1. Sau 5 cycle TIMER_IRQ=1 trong đúng 1 cycle khi CNT==PERIOD.
//==============================================================================

class apb_timer_irq_seq extends ahb_base_seq;
    `uvm_object_utils(apb_timer_irq_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    // APB virtual interface
    virtual apb_if apb_vif;
    
    function new(string name = "apb_timer_irq_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rdata;

        `uvm_info("TIMER_IRQ_SEQ", "=== APB TIMER IRQ TEST START ===", UVM_LOW)

        //--------------------------------------------
        // Get APB interface
        //--------------------------------------------
        if (!uvm_config_db#(virtual apb_if)::get(
                null,
                "",
                "apb_vif",
                apb_vif))
        begin
            `uvm_fatal("GPIO_READ_INPUT_SEQ",
                "Cannot get apb_vif")
        end

        // Ghi vào các register của Timer
        do_write(32'h4001_0008, 32'h0000_0005); // PERIOD = 5
        do_write(32'h4001_0000, 32'h0000_0001); // CTRL[0] = 1 (enable timer)

         // Wait until IRQ asserted
        wait(apb_vif.TIMER_IRQ == 1'b1);

        // IRQ phải chỉ tồn tại đúng 1 cycle
        @(posedge p_sequencer.vif.HCLK);

        do_read(32'h4001_0004, rdata); // Đọc CNT để debug nếu cần



        `uvm_info("TIMER_IRQ_SEQ", "=== APB TIMER IRQ TEST DONE ===", UVM_LOW)
    endtask : body
endclass : apb_timer_irq_seq