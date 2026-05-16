//==============================================================================
// File    : ahb_invalid_addr_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 16/05/2026
//------------------------------------------------------------------------------
// Description:
// Transfer 0x4003_0000 → Valid=0 → FSM ở ST_IDLE → HREADYout=1 ngay → HRDATA=0, no stall.
//==============================================================================

class ahb_invalid_addr_seq extends ahb_base_seq;

    `uvm_object_utils(ahb_invalid_addr_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    rand logic [31:0] invalid_addr;
    rand logic [31:0] wr_data;

    constraint addr_cnst {
        // Địa chỉ ngoài vùng 0x4000_0000 - 0x4002_FFFF
        invalid_addr < 32'h4000_0000 || invalid_addr > 32'h4002_FFFF;
    }
    constraint data_cnst {
        // Dữ liệu random, tránh giá trị đặc biệt (0x0000_0000, 0xFFFF_FFFF)
        wr_data != 32'h0000_0000;
        wr_data != 32'hFFFF_FFFF;
    }

    function new(string name = "ahb_invalid_addr_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        
        `uvm_info("INVALID_ADDR_SEQ", "=== AHB INVALID ADDRESS TEST START ===", UVM_LOW)
        //--------------------------------------------
        // Randomize address & data
        //--------------------------------------------
        if (!randomize(invalid_addr, wr_data)) begin
            `uvm_fatal("INVALID_ADDR_SEQ", "Randomization failed")
        end
        `uvm_info("INVALID_ADDR_SEQ", $sformatf("Randomized invalid address: 0x%08h, data: 0x%08h", invalid_addr, wr_data), UVM_LOW)
        //--------------------------------------------
        // Do write transfer to invalid address
        //--------------------------------------------
        do_write(invalid_addr, wr_data);
        // Read back from the same invalid address to check response
        do_read(invalid_addr, wr_data);
        `uvm_info("INVALID_ADDR_SEQ", "=== AHB INVALID ADDRESS TEST DONE ===", UVM_LOW)
    endtask
endclass : ahb_invalid_addr_seq