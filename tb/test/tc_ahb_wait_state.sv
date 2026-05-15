class tc_ahb_wait_state extends base_test;
    `uvm_component_utils(tc_ahb_wait_state)

    ahb_wait_state_seq m_seq;

    function new(string name = "tc_ahb_wait_state", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("AHB_WAIT_STATE_TEST", "Starting AHB Wait State test", UVM_LOW)

        m_seq = ahb_wait_state_seq::type_id::create("m_seq");
        m_seq.vif = ahb_vif_m1;
        // chạy sequence trên AHB sequencer
        m_seq.start(m_env.ahb_ag_m1.sequencer);

        #100ns; // Đợi monitor/scoreboard xử lý xong

        `uvm_info("AHB_WAIT_STATE_TEST", "AHB Wait State test completed", UVM_LOW)

        phase.drop_objection(this);
    endtask : run_phase
endclass : tc_ahb_wait_state