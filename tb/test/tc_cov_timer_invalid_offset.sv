class tc_cov_timer_invalid_offset extends base_test;
    `uvm_component_utils(tc_cov_timer_invalid_offset)

    cov_timer_invalid_offset_seq m_seq;

    function new(string name = "tc_cov_timer_invalid_offset", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("TC_COV_TIMER_INV", "Starting coverage test: TIMER invalid offset", UVM_LOW)

        m_seq = cov_timer_invalid_offset_seq::type_id::create("m_seq");
        m_seq.vif = ahb_vif_m1;
        m_seq.start(m_env.ahb_ag_m1.sequencer);

        #100ns;

        `uvm_info("TC_COV_TIMER_INV", "Coverage test completed", UVM_LOW)

        phase.drop_objection(this);
    endtask : run_phase
endclass : tc_cov_timer_invalid_offset
