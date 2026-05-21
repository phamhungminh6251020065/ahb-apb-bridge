class tc_func_random_m1 extends base_test;
    `uvm_component_utils(tc_func_random_m1)
    func_random_m1_seq m_seq;

    function new(string name = "tc_func_random_m1", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("FUNC_RANDOM_M1", "Starting Functional Random M1 test", UVM_LOW)
        repeat (8) begin
            m_seq = func_random_m1_seq::type_id::create( $sformatf("m_seq%0t", $time));
            m_seq.master_id = 0;

            if (!m_seq.randomize()) 
                `uvm_error("FUNC_RANDOM_M1", "M1 randomize failed")
            m_seq.start( m_env.ahb_ag_m1.sequencer);
            #100ns; 
        end    
        `uvm_info("FUNC_RANDOM_M1", "Functional Random M1 test completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask : run_phase

endclass : tc_func_random_m1