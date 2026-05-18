class tc_bridge_unaligned_addr extends base_test;
    `uvm_component_utils(tc_bridge_unaligned_addr);
    bridge_unaligned_addr_seq m_seq;

    function new(string name = "tc_bridge_unaligned_addr", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("UNALIGNED_ADDR_TEST", "Starting AHB Bridge Unaligned Address test", UVM_LOW)

        m_seq = bridge_unaligned_addr_seq::type_id::create("m_seq");
        m_seq.vif = ahb_vif_m1;
        // chạy sequence trên AHB sequencer
        m_seq.start(m_env.ahb_ag_m1.sequencer);

        #100ns; // Đợi monitor/scoreboard xử lý xong

        `uvm_info("UNALIGNED_ADDR_TEST", "AHB Bridge Unaligned Address test completed", UVM_LOW)
        phase.drop_objection(this);
    endtask : run_phase
endclass : tc_bridge_unaligned_addr