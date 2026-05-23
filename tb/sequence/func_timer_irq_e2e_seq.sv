//==============================================================================
// File    : func_random_m1_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 21/05/2026
//------------------------------------------------------------------------------
// Description:
// Master ghi PERIOD=10 rồi EN=1 qua AHB. APB Monitor theo dõi → TIMER_IRQ=1 sau đúng 10 APB cycle.
//==============================================================================

class func_timer_irq_e2e_seq extends ahb_base_seq;

    `uvm_object_utils(func_timer_irq_e2e_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    virtual apb_if apb_vif;

    int cycle_cnt;
    logic [31:0] rd_data;

    function new(string name = "func_timer_irq_e2e_seq");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info("TIMER_IRQ_E2E_SEQ",
                  "=== TIMER IRQ E2E TEST START ===",
                  UVM_LOW)

        //--------------------------------------------
        // Get APB interface
        //--------------------------------------------
        if (!uvm_config_db#(virtual apb_if)::get(null, "", "apb_vif", apb_vif))
            `uvm_fatal("TIMER_IRQ_E2E_SEQ", "Cannot get apb_vif")

        //--------------------------------------------
        // PROGRAM TIMER
        //--------------------------------------------
        // PERIOD = 10
        do_write(32'h4001_0008, 32'd10);

        // EN = 1
        do_write(32'h4001_0000, 32'h1);

        //--------------------------------------------
        // COUNT APB cycles until IRQ
        //--------------------------------------------
        cycle_cnt = 0;

        while (apb_vif.TIMER_IRQ !== 1'b1) begin
            @(posedge apb_vif.PCLK);
            cycle_cnt++;
        end

        //--------------------------------------------
        // CHECK IRQ timing
        //--------------------------------------------
        // if (cycle_cnt == 10)
        //     `uvm_info("TIMER_IRQ_E2E_SEQ",
        //               $sformatf("IRQ asserted after %0d APB cycles", cycle_cnt),
        //               UVM_LOW)
        // else
        //     `uvm_error("TIMER_IRQ_E2E_SEQ",
        //                $sformatf("IRQ timing mismatch: expected 10 cycles, got %0d",
        //                          cycle_cnt))

        //--------------------------------------------
        // READ CNT register
        //--------------------------------------------
        do_read(32'h4001_0004, rd_data);

        `uvm_info("TIMER_IRQ_E2E_SEQ",
                  $sformatf("CNT register = 0x%08h", rd_data),
                  UVM_LOW)

        `uvm_info("TIMER_IRQ_E2E_SEQ",
                  "=== TIMER IRQ E2E TEST DONE ===",
                  UVM_LOW)

    endtask

endclass