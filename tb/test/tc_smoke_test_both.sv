//==============================================================================
// File    : tc_smoke_test_both.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 08/05/2026
//------------------------------------------------------------------------------
// Description:
//   Test case smoke để kiểm tra hoạt động với cả hai master active.
//   - Cả Master 1 và Master 2 đều active
//   - Chạy smoke_seq trên cả hai master đồng thời (parallel)
//   - Arbiter sẽ điều phối giữa hai master
//   - Verify data flow từ cả hai AHB Master Driver → Bridge → APB Slave
//==============================================================================

class tc_smoke_test_both extends base_test;
    `uvm_component_utils(tc_smoke_test_both)

    smoke_seq m_smoke_seq_m1;
    smoke_seq m_smoke_seq_m2;

    function new(string name = "tc_smoke_test_both", uvm_component parent);
        super.new(name, parent);
    endfunction

    //========================================================
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Kích hoạt cả hai master
        uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.ahb_ag_m1", "is_active", UVM_ACTIVE);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.ahb_ag_m2", "is_active", UVM_ACTIVE);

        `uvm_info("SMOKE_TEST_BOTH", "Both Master 1 and Master 2 are active", UVM_LOW)
    endfunction

    //========================================================
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("SMOKE_TEST_BOTH", "Starting smoke test with both masters active", UVM_LOW)

        // Fork để chạy sequence trên cả hai master đồng thời
        fork
            begin
                // Master 1 sequence
                m_smoke_seq_m1 = smoke_seq::type_id::create("m_smoke_seq_m1");
                m_smoke_seq_m1.master_id = 0;  // Master 1

                if (!m_smoke_seq_m1.randomize())
                    `uvm_error("SMOKE_TEST_BOTH", "Failed to randomize M1 smoke sequence")

                m_smoke_seq_m1.start(m_env.ahb_ag_m1.sequencer);
            end

            begin
                // Master 2 sequence
                m_smoke_seq_m2 = smoke_seq::type_id::create("m_smoke_seq_m2");
                m_smoke_seq_m2.master_id = 1;  // Master 2

                if (!m_smoke_seq_m2.randomize())
                    `uvm_error("SMOKE_TEST_BOTH", "Failed to randomize M2 smoke sequence")

                m_smoke_seq_m2.start(m_env.ahb_ag_m2.sequencer);
            end
        join

        `uvm_info("SMOKE_TEST_BOTH", "Smoke test with both masters completed", UVM_LOW)

        // Add delay to allow monitor/scoreboard to finish processing
        #100ns;

        phase.drop_objection(this);
    endtask

endclass : tc_smoke_test_both