//==============================================================================
// File    : tc_smoke_test.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 22/04/2026
//------------------------------------------------------------------------------
// Description:
//   Test case smoke để kiểm tra hoạt động cơ bản của hệ thống AHB-to-APB.
//   - Chạy smoke_seq để test write/read operations
//   - Verify data flow từ AHB Driver → Bridge → APB Slave
//==============================================================================

class tc_smoke_test extends base_test;
    `uvm_component_utils(tc_smoke_test)

    smoke_seq m_smoke_seq;

    function new(string name = "tc_smoke_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    //========================================================
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("SMOKE_TEST", "Starting smoke test", UVM_LOW)

        // Create and start smoke sequence
        m_smoke_seq = smoke_seq::type_id::create("m_smoke_seq");
        m_smoke_seq.master_id = 0;  // Master 1

        // Start sequence on AHB agent sequencer
        if (!m_smoke_seq.randomize())
            `uvm_error("SMOKE_TEST", "Failed to randomize smoke sequence")

        m_smoke_seq.start(m_env.ahb_ag.sequencer);

        `uvm_info("SMOKE_TEST", "Smoke test completed", UVM_LOW)

        // Add delay to allow monitor/scoreboard to finish processing
        #1000;

        phase.drop_objection(this);
    endtask

    //========================================================
    // function void end_of_elaboration_phase(uvm_phase phase);
    //     super.end_of_elaboration_phase(phase);
        
    //     `uvm_info("SMOKE_TEST", "Smoke test elaboration complete", UVM_LOW)
    // endfunction

endclass : tc_smoke_test
