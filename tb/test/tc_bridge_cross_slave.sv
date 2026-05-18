class tc_bridge_cross_slave extends base_test;
    `uvm_component_utils(tc_bridge_cross_slave);
    bridge_cross_slave_seq m_seq;

    function new(string name = "tc_bridge_cross_slave", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("CROSS_SLAVE_TEST", "Starting AHB Bridge Cross-Slave test", UVM_LOW)

        m_seq = bridge_cross_slave_seq::type_id::create("m_seq");
        m_seq.vif = ahb_vif_m1;
        // chạy sequence trên AHB sequencer
        m_seq.start(m_env.ahb_ag_m1.sequencer);

        #100ns; // Đợi monitor/scoreboard xử lý xong

        `uvm_info("CROSS_SLAVE_TEST", "AHB Bridge Cross-Slave test completed", UVM_LOW)

        phase.drop_objection(this);
    endtask : run_phase
endclass : tc_bridge_cross_slave