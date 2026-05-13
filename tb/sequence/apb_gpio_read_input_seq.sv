//==============================================================================
// File    : apb_gpio_read_input_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 13/05/2026
//------------------------------------------------------------------------------
// Description:
// Set DIR=0x00, GPIO_IN=0x5A. Read DATA_REG → gpio_read=(~dir&GPIO_IN)=0x5A.
//==============================================================================

class apb_gpio_read_input_seq extends ahb_base_seq;

    `uvm_object_utils(apb_gpio_read_input_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    // APB virtual interface
    virtual apb_if apb_vif;

    function new(string name = "apb_gpio_read_input_seq");
        super.new(name);
    endfunction : new

    virtual task body();

        logic [31:0] rdata;

        `uvm_info("GPIO_READ_INPUT_SEQ",
            "=== APB GPIO READ INPUT TEST START ===",
            UVM_LOW)

        //--------------------------------------------
        // Get APB interface
        //--------------------------------------------
        if (!uvm_config_db#(virtual apb_if)::get(
                null,
                "",
                "apb_vif",
                apb_vif))
        begin
            `uvm_fatal("GPIO_READ_INPUT_SEQ",
                "Cannot get apb_vif")
        end

        //--------------------------------------------
        // Set DIR = 0x00 (all input)
        //--------------------------------------------
        do_write(32'h4000_0004, 32'h0000_0000);

        //--------------------------------------------
        // Drive GPIO input
        //--------------------------------------------
        apb_vif.GPIO_IN = 8'h5A;

        //--------------------------------------------
        // Read DATA_REG
        //--------------------------------------------
        do_read(32'h4000_0000, rdata);

        `uvm_info("GPIO_READ_INPUT_SEQ", "=== APB GPIO READ INPUT TEST DONE ===", UVM_LOW)

    endtask : body

endclass : apb_gpio_read_input_seq