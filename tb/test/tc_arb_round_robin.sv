class tc_arb_round_robin extends base_test;
    `uvm_component_utils(tc_arb_round_robin)
    arb_round_robin_seq m_seq_m1; // sequence chay trên Master 1
    arb_round_robin_seq m_seq_m2; // sequence chay trên Master 2

    function new(string name = "tc_arb_round_robin", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Kích hoạt cả hai master
        uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.ahb_ag_m1", "is_active", UVM_ACTIVE);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.ahb_ag_m2", "is_active", UVM_ACTIVE);

        `uvm_info("ARB_ROUND_ROBIN", "Both Master 1 and Master 2 are active for this test", UVM_LOW)
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("ARB_ROUND_ROBIN", "Starting ARB ROUND ROBIN test", UVM_LOW)

         //--------------------------------------------
        // Repeat contention multiple rounds
        //--------------------------------------------
        repeat (4) begin

            fork
                //------------------------------------
                // Master 1
                //------------------------------------
                begin
                    m_seq_m1 = arb_round_robin_seq::type_id::create( $sformatf("m_seq_m1_%0t", $time));
                    m_seq_m1.master_id = 0;

                    if (!m_seq_m1.randomize()) 
                        `uvm_error("ARB_ROUND_ROBIN", "M1 randomize failed")

                    m_seq_m1.start( m_env.ahb_ag_m1.sequencer);
                end
                //------------------------------------
                // Master 2
                //------------------------------------
                begin
                    m_seq_m2 = arb_round_robin_seq::type_id::create( $sformatf("m_seq_m2_%0t", $time));
                    m_seq_m2.master_id = 1;

                    if (!m_seq_m2.randomize())
                        `uvm_error("ARB_ROUND_ROBIN", "M2 randomize failed")

                    m_seq_m2.start( m_env.ahb_ag_m2.sequencer);
                end
            join
            //----------------------------------------
            // Small delay between arbitration rounds
            //----------------------------------------
            #20ns;
        end

        //--------------------------------------------
        // Wait scoreboard/monitor finish processing
        //--------------------------------------------
        #100ns;

        `uvm_info("ARB_ROUND_ROBIN", "=== ROUND ROBIN TEST DONE ===", UVM_LOW)

        phase.drop_objection(this);
    endtask : run_phase
endclass : tc_arb_round_robin