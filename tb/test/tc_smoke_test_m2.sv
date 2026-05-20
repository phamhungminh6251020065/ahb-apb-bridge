//==============================================================================
// File    : tc_smoke_test_m2.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 08/05/2026
//------------------------------------------------------------------------------
// Description:
//   Test case smoke để kiểm tra hoạt động cơ bản của hệ thống AHB-to-APB
//   sử dụng Master 2.
//   - Kích hoạt Master 2 (ahb_ag_m2) để active mode
//   - Chạy smoke_seq trên Master 2
//   - Verify data flow từ AHB Master 2 Driver → Bridge → APB Slave
//==============================================================================

class tc_smoke_test_m2 extends base_test;
    `uvm_component_utils(tc_smoke_test_m2)

    smoke_seq m_smoke_seq;

    function new(string name = "tc_smoke_test_m2", uvm_component parent);
        super.new(name, parent);
    endfunction

    //========================================================
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Kích hoạt Master 2 agent, vô hiệu hóa Master 1
        uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.ahb_ag_m1", "is_active", UVM_PASSIVE);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.ahb_ag_m2", "is_active", UVM_ACTIVE);
        
        `uvm_info("SMOKE_TEST_M2", "Master 2 will be active in this test", UVM_LOW)
    endfunction

    //========================================================
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("SMOKE_TEST_M2", "Starting smoke test on Master 2", UVM_LOW)

        // Create and start smoke sequence
        m_smoke_seq = smoke_seq::type_id::create("m_smoke_seq");
        m_smoke_seq.master_id = 1;  // Master 2

        // Start sequence on AHB Master 2 agent sequencer
        if (!m_smoke_seq.randomize())
            `uvm_error("SMOKE_TEST_M2", "Failed to randomize smoke sequence")

        m_smoke_seq.start(m_env.ahb_ag_m2.sequencer);

        `uvm_info("SMOKE_TEST_M2", "Smoke test completed", UVM_LOW)

        // Add delay to allow monitor/scoreboard to finish processing
        #100ns;

        phase.drop_objection(this);
    endtask

endclass : tc_smoke_test_m2
