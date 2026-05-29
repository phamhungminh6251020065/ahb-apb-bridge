class tc_cov_bridge_pipeline extends base_test;
    `uvm_component_utils(tc_cov_bridge_pipeline)

    cov_bridge_pipeline_seq m_seq;

    function new(string name = "tc_cov_bridge_pipeline", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("TC_COV_PIPE", "Starting coverage test: bridge pipeline", UVM_LOW)

        m_seq = cov_bridge_pipeline_seq::type_id::create("m_seq");
        m_seq.vif = ahb_vif_m1;
        m_seq.start(m_env.ahb_ag_m1.sequencer);

        #100ns;

        `uvm_info("TC_COV_PIPE", "Coverage test completed", UVM_LOW)

        phase.drop_objection(this);
    endtask : run_phase
endclass : tc_cov_bridge_pipeline
