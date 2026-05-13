class tc_apb_gpio_read_input extends base_test;
    `uvm_component_utils(tc_apb_gpio_read_input)

    apb_gpio_read_input_seq m_seq;

    function new(string name = "tc_apb_gpio_read_input", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("GPIO_READ_INPUT_TEST", "Starting APB GPIO Read Input test", UVM_LOW)

        m_seq = apb_gpio_read_input_seq::type_id::create("m_seq");
        m_seq.vif = ahb_vif_m1;
        // chạy sequence trên AHB sequencer
        m_seq.start(m_env.ahb_ag_m1.sequencer);

        #100ns; // Đợi monitor/scoreboard xử lý xong

        `uvm_info("GPIO_READ_INPUT_TEST", "APB GPIO Read Input test completed", UVM_LOW)

        phase.drop_objection(this);
    endtask : run_phase
endclass : tc_apb_gpio_read_input