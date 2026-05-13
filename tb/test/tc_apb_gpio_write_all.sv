class tc_apb_gpio_write_all extends base_test;
    `uvm_component_utils(tc_apb_gpio_write_all)

    apb_gpio_write_all_seq m_seq;

    function new(string name = "tc_apb_gpio_write_all", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("GPIO_WRITE_ALL_TEST", "Starting APB GPIO Write All test", UVM_LOW)

        m_seq = apb_gpio_write_all_seq::type_id::create("m_seq");
        m_seq.vif = ahb_vif_m1;
        // chạy sequence trên AHB sequencer
        m_seq.start(m_env.ahb_ag_m1.sequencer);

        #100ns; // Đợi monitor/scoreboard xử lý xong

        `uvm_info("GPIO_WRITE_ALL_TEST", "APB GPIO Write All test completed", UVM_LOW)

        phase.drop_objection(this);
    endtask : run_phase
endclass : tc_apb_gpio_write_all