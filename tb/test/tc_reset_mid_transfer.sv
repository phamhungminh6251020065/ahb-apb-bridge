class tc_reset_mid_transfer extends base_test;
    `uvm_component_utils(tc_reset_mid_transfer)

    reset_mid_transfer_seq m_seq;

    function new(string name = "tc_reset_mid_transfer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("RESET_TEST", "Starting RESET MID-TRANSFER test", UVM_LOW)

        m_seq = reset_mid_transfer_seq::type_id::create("m_seq");
        m_seq.vif = ahb_vif_m1;
        // chạy sequence trên AHB sequencer
        m_seq.start(m_env.ahb_ag_m1.sequencer);

        #100ns; // Đợi monitor/scoreboard xử lý xong

        `uvm_info("RESET_TEST", "RESET MID-TRANSFER test completed", UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass