//==============================================================================
// File    : apb_gpio_write_all_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 13/05/2026
//------------------------------------------------------------------------------
// Description:
//  Ghi DATA_REG=0xA5, DIR_REG=0xFF, IE_REG=0x0F. Đọc lại → match từng register.
//==============================================================================

class apb_gpio_write_all_seq extends ahb_base_seq;
    `uvm_object_utils(apb_gpio_write_all_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)
    
    function new(string name = "apb_gpio_write_all_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rdata;

        `uvm_info("GPIO_WRITE_ALL_SEQ", "=== APB GPIO WRITE ALL TEST START ===", UVM_LOW)

        // Ghi vào các register của GPIO
        do_write(32'h4000_0000, 32'h0000_00A5); // DATA_REG = 0xA5
        do_write(32'h4000_0004, 32'h0000_00FF); // DIR_REG = 0xFF
        do_write(32'h4000_0008, 32'h0000_000F); // IE_REG = 0x0F

        // Đọc lại để verify
        do_read(32'h4000_0000, rdata);

        do_read(32'h4000_0004, rdata);

        do_read(32'h4000_0008, rdata);
    endtask : body

endclass : apb_gpio_write_all_seq