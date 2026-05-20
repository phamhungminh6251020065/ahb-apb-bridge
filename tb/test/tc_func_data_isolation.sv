class tc_func_data_isolation extends base_test;
    `uvm_component_utils(tc_func_data_isolation)
    func_data_isolation_seq m_seq_m1; // sequence chay trên Master 1
    func_data_isolation_seq m_seq_m2; // sequence chay trên Master 2

    function new(string name = "tc_func_data_isolation", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Kích hoạt cả hai master
        uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.ahb_ag_m1", "is_active", UVM_ACTIVE);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.ahb_ag_m2", "is_active", UVM_ACTIVE);

        `uvm_info("DATA_ISOLATION", "Both Master 1 and Master 2 are active for this test", UVM_LOW)
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("DATA_ISOLATION", "Starting DATA ISOLATION test", UVM_LOW)

        fork
            // Master 1 chạy sequence
            begin
                m_seq_m1 = func_data_isolation_seq::type_id::create( $sformatf("m_seq_m1_%0t", $time));
                m_seq_m1.master_id = 0;
                if (!m_seq_m1.randomize()) 
                    `uvm_error("DATA_ISOLATION", "M1 randomize failed")
                m_seq_m1.start( m_env.ahb_ag_m1.sequencer);
            end
            // Master 2 chạy sequence
            begin
                m_seq_m2 = func_data_isolation_seq::type_id::create( $sformatf("m_seq_m2_%0t", $time));
                m_seq_m2.master_id = 1;
                if (!m_seq_m2.randomize())
                    `uvm_error("DATA_ISOLATION", "M2 randomize failed")
                m_seq_m2.start( m_env.ahb_ag_m2.sequencer);
            end
        join
        #100ns; // Chờ cho cả hai sequence hoàn thành
        phase.drop_objection(this);
    endtask : run_phase
endclass : tc_func_data_isolation