class tc_apb_pslverr extends base_test;
    `uvm_component_utils(tc_apb_pslverr)

    apb_pslverr_seq m_seq;

    function new(string name = "tc_apb_pslverr", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("PSLVER_TEST", "Starting APB PSLVERR test", UVM_LOW)

        m_seq = apb_pslverr_seq::type_id::create("m_seq");
        m_seq.vif = ahb_vif_m1;
        // chạy sequence trên AHB sequencer
        m_seq.start(m_env.ahb_ag_m1.sequencer);

        #100ns; // Đợi monitor/scoreboard xử lý xong

        `uvm_info("PSLVER_TEST", "APB PSLVERR test completed", UVM_LOW)

        phase.drop_objection(this);
    endtask : run_phase
endclass : tc_apb_pslverr