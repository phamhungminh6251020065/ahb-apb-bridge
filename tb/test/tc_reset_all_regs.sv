class tc_reset_all_regs extends base_test;
    `uvm_component_utils(tc_reset_all_regs)

    reset_all_regs_seq m_seq;

    function new(string name = "tc_reset_all_regs", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    
    //========================================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Kích hoạt Master 2 agent, vô hiệu hóa Master 1
        uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.ahb_ag_m1", "is_active", UVM_ACTIVE);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.ahb_ag_m2", "is_active", UVM_ACTIVE);
        
        `uvm_info("SMOKE_TEST_M2", "Master 2 will be active in this test", UVM_LOW)
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("RESET_TEST", "Starting RESET ALL REGS test", UVM_LOW)

        m_seq = reset_all_regs_seq::type_id::create("m_seq");
         m_seq.vif = ahb_vif_m1;
        // chạy sequence trên AHB sequencer
        m_seq.start(m_env.ahb_ag_m1.sequencer);

        #100ns; // Đợi monitor/scoreboard xử lý xong

        `uvm_info("RESET_TEST", "RESET ALL REGS test completed", UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass