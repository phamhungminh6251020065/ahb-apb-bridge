class tc_apb_regfile_all extends base_test;
    `uvm_component_utils(tc_apb_regfile_all)

    apb_regfile_all_seq m_seq;

    function new(string name = "tc_apb_regfile_all", uvm_component parent = null);
        super.new(name, parent);   
    endfunction : new

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("REGFILE_ALL_TEST", "Starting APB RegFile All test", UVM_LOW)

        m_seq = apb_regfile_all_seq::type_id::create("m_seq");
        m_seq.vif = ahb_vif_m1;
        // chạy sequence trên AHB sequencer
        m_seq.start(m_env.ahb_ag_m1.sequencer);

        #100ns; // Đợi monitor/scoreboard xử lý xong

        `uvm_info("REGFILE_ALL_TEST", "APB RegFile All test completed", UVM_LOW)

        phase.drop_objection(this);
    endtask : run_phase
endclass : tc_apb_regfile_all