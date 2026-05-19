class tc_arb_fixed_m1_wins extends base_test;
    `uvm_component_utils(tc_arb_fixed_m1_wins)
    arb_fixed_m1_wins_seq m_seq_m1; // sequence chay trên Master 1
    arb_fixed_m1_wins_seq m_seq_m2; // sequence chay trên Master 2

    function new(string name = "tc_arb_fixed_m1_wins", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Kích hoạt cả hai master
        uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.ahb_ag_m1", "is_active", UVM_ACTIVE);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.ahb_ag_m2", "is_active", UVM_ACTIVE);

        `uvm_info("ARB_FIXED_M1_WINS", "Both Master 1 and Master 2 are active for this test", UVM_LOW)
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("ARB_FIXED_M1_WINS", "Starting ARB FIXED M1 WINS test", UVM_LOW)

        // Fork để chạy sequence trên cả hai master đồng thời
        fork
            begin
                // Master 2 sequence
                m_seq_m2 = arb_fixed_m1_wins_seq::type_id::create("m_seq_m2");
                m_seq_m2.master_id = 1;  // Master 2

                if (!m_seq_m2.randomize())
                    `uvm_error("ARB_FIXED_M1_WINS", "Failed to randomize M2 sequence")

                m_seq_m2.start(m_env.ahb_ag_m2.sequencer);
            end
            begin
                // Master 1 sequence
                m_seq_m1 = arb_fixed_m1_wins_seq::type_id::create("m_seq_m1");
                m_seq_m1.master_id = 0;  // Master 1

                if (!m_seq_m1.randomize())
                    `uvm_error("ARB_FIXED_M1_WINS", "Failed to randomize M1 sequence")

                m_seq_m1.start(m_env.ahb_ag_m1.sequencer);
            end
        join

        `uvm_info("ARB_FIXED_M1_WINS", "Both sequences started, waiting for them to complete", UVM_LOW)

        // Add delay to allow monitor/scoreboard to finish processing
        #100ns;

        phase.drop_objection(this);
    endtask : run_phase
endclass : tc_arb_fixed_m1_wins