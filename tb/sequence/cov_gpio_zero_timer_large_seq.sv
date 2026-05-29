//==============================================================================
// File    : cov_gpio_zero_timer_large_seq.sv
// Project : AHB-to-APB Bridge
//------------------------------------------------------------------------------
// Description:
//  Coverage-directed sequence:
//  - Write GPIO DATA_REG with 0x00 to hit GPIO ZERO bin
//  - Write TIMER PERIOD with a large value to hit TIMER LARGE bin
//  - Enable timer to keep the timer path active
//==============================================================================

class cov_gpio_zero_timer_large_seq extends ahb_base_seq;
    `uvm_object_utils(cov_gpio_zero_timer_large_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    function new(string name = "cov_gpio_zero_timer_large_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rdata;

        `uvm_info("COV_GPIO_TIMER_SEQ", "=== COV GPIO ZERO + TIMER LARGE START ===", UVM_LOW)

        do_write(32'h4000_0000, 32'h0000_0000);
        do_read (32'h4000_0000, rdata);

        do_write(32'h4001_0008, 32'd32);
        do_write(32'h4001_0000, 32'h0000_0001);
        repeat (4) @(posedge p_sequencer.vif.HCLK);
        do_read (32'h4001_0008, rdata);
        do_read (32'h4001_0000, rdata);

        `uvm_info("COV_GPIO_TIMER_SEQ", "=== COV GPIO ZERO + TIMER LARGE DONE ===", UVM_LOW)
    endtask : body
endclass : cov_gpio_zero_timer_large_seq
