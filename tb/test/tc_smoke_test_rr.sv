//==============================================================================
// File    : tc_smoke_test_rr.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 08/05/2026
//------------------------------------------------------------------------------
// Description:
//   Test case smoke để kiểm tra hoạt động cơ bản của hệ thống AHB-to-APB
//   với Round Robin arbitration mode.
//   - Cấu hình DUT với ARBITER_MODE=1 (Round Robin)
//   - Chạy smoke_seq trên Master 1 (vẫn dùng M1 active, M2 passive)
//   - Verify data flow từ AHB Master 1 Driver → Bridge → APB Slave
//==============================================================================

class tc_smoke_test_rr extends base_test;
    `uvm_component_utils(tc_smoke_test_rr)

    smoke_seq m_smoke_seq;

    function new(string name = "tc_smoke_test_rr", uvm_component parent);
        super.new(name, parent);
    endfunction

    //========================================================
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Không thể set config DB từ test cho DUT parameter
        // Sẽ dùng plusargs khi run: make sim TEST=tc_smoke_test_rr ARBITER_MODE=1

        `uvm_info("SMOKE_TEST_RR", "Use 'make sim TEST=tc_smoke_test_rr ARBITER_MODE=1' for Round Robin mode", UVM_LOW)
    endfunction

    //========================================================
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("SMOKE_TEST_RR", "Starting smoke test with Round Robin arbitration", UVM_LOW)

        // Create and start smoke sequence
        m_smoke_seq = smoke_seq::type_id::create("m_smoke_seq");
        m_smoke_seq.master_id = 0;  // Master 1

        // Start sequence on AHB Master 1 agent sequencer
        if (!m_smoke_seq.randomize())
            `uvm_error("SMOKE_TEST_RR", "Failed to randomize smoke sequence")

        m_smoke_seq.start(m_env.ahb_ag_m1.sequencer);

        `uvm_info("SMOKE_TEST_RR", "Smoke test completed", UVM_LOW)

        // Add delay to allow monitor/scoreboard to finish processing
        #100ns;

        phase.drop_objection(this);
    endtask

endclass : tc_smoke_test_rr