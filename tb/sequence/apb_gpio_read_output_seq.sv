//==============================================================================
// File    : apb_gpio_read_output_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 13/05/2026
//------------------------------------------------------------------------------
// Description:
//  Set DIR=0xFF, write DATA=0xA5. Read DATA_REG → gpio_read=(dir&data)=0xA5.
//==============================================================================

class apb_gpio_read_output_seq extends ahb_base_seq;
    `uvm_object_utils(apb_gpio_read_output_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)
    
    function new(string name = "apb_gpio_read_output_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rdata;

        `uvm_info("GPIO_READ_OUTPUT_SEQ", "=== APB GPIO READ OUTPUT TEST START ===", UVM_LOW)

        // Set DIR=0xFF
        do_write(32'h4000_0004, 32'h0000_00FF); // DIR_REG = 0xFF

        // Write DATA=0xA5
        do_write(32'h4000_0000, 32'h0000_00A5); // DATA_REG = 0xA5

        // Read DATA_REG → gpio_read=(dir&data)=0xA5
        do_read(32'h4000_0000, rdata);
    endtask : body

endclass : apb_gpio_read_output_seq