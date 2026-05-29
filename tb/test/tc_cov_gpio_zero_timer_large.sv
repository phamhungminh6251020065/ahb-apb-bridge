class tc_cov_gpio_zero_timer_large extends base_test;
    `uvm_component_utils(tc_cov_gpio_zero_timer_large)

    cov_gpio_zero_timer_large_seq m_seq;

    function new(string name = "tc_cov_gpio_zero_timer_large", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("TC_COV_GPIO_TIMER", "Starting coverage test: GPIO zero + TIMER large", UVM_LOW)

        m_seq = cov_gpio_zero_timer_large_seq::type_id::create("m_seq");
        m_seq.vif = ahb_vif_m1;
        m_seq.start(m_env.ahb_ag_m1.sequencer);

        #100ns;

        `uvm_info("TC_COV_GPIO_TIMER", "Coverage test completed", UVM_LOW)

        phase.drop_objection(this);
    endtask : run_phase
endclass : tc_cov_gpio_zero_timer_large
