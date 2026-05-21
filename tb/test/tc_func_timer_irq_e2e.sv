class tc_func_timer_irq_e2e extends base_test;
    `uvm_component_utils(tc_func_timer_irq_e2e)
    func_timer_irq_e2e_seq m_seq;

    function new(string name = "tc_func_timer_irq_e2e", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("FUNC_IRQ_E2E", "Starting Functional IRQ E2E test", UVM_LOW)
        m_seq = func_timer_irq_e2e_seq::type_id::create("m_seq");
        m_seq.vif = ahb_vif_m1;

        m_seq.start(m_env.ahb_ag_m1.sequencer);
        #100ns;
        `uvm_info("FUNC_IRQ_E2E", "Functional IRQ E2E test completed", UVM_LOW)
        phase.drop_objection(this);

    endtask : run_phase

endclass : tc_func_timer_irq_e2e