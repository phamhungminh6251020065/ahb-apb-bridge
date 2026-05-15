class tc_apb_timer_irq extends base_test;
    `uvm_component_utils(tc_apb_timer_irq);

    apb_timer_irq_seq m_seq;

    function new(string name = "tc_apb_timer_irq", uvm_component parent = null);
        super.new(name, parent);
    endfunction 

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("TIMER_IRQ_TEST", "Starting APB Timer IRQ test", UVM_LOW)

        m_seq = apb_timer_irq_seq::type_id::create("m_seq");
        m_seq.vif = ahb_vif_m1;
        // chạy sequence trên AHB sequencer
        m_seq.start(m_env.ahb_ag_m1.sequencer);

        #100ns; // Đợi monitor/scoreboard xử lý xong

        `uvm_info("TIMER_IRQ_TEST", "APB Timer IRQ test completed", UVM_LOW)

        phase.drop_objection(this);
    endtask : run_phase
endclass : tc_apb_timer_irq