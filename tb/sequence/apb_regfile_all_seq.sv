//==============================================================================
// File    : apb_regfile_all_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 15/05/2026
//------------------------------------------------------------------------------
// Description:
//  Ghi 8 giá trị random vào mem[0..7], đọc lại từng register → 8/8 match.
//==============================================================================

class apb_regfile_all_seq extends ahb_base_seq;
    `uvm_object_utils(apb_regfile_all_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    // 8 word random data
    rand logic [31:0] wr_data [8];

    logic [31:0] rd_data;

    function new(string name = "apb_regfile_all_seq");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info("APB_REGFILE_ALL_SEQ", "=== APB RegFile All Sequence START ===", UVM_LOW)

        //--------------------------------------------
        // Randomize all data
        //--------------------------------------------
        if (!randomize(wr_data)) begin
            `uvm_fatal("APB_REGFILE_ALL_SEQ", "Randomization failed")
        end

        //--------------------------------------------
        // Write mem[0..7]
        //--------------------------------------------
        for (int i = 0; i < 8; i++) begin

            do_write(32'h4002_0000 + i*4, wr_data[i]);

            `uvm_info("APB_REGFILE_ALL_SEQ", $sformatf("WRITE mem[%0d] = 0x%08h", i, wr_data[i]), UVM_LOW)
        end

        //--------------------------------------------
        // Read & compare
        //--------------------------------------------
        for (int i = 0; i < 8; i++) begin

            do_read(32'h4002_0000 + i*4, rd_data);

            `uvm_info("APB_REGFILE_ALL_SEQ", $sformatf("READ  mem[%0d] = 0x%08h", i, rd_data), UVM_LOW)
        end
        #100ns; // Đợi monitor/scoreboard xử lý xong
        `uvm_info("APB_REGFILE_ALL_SEQ", "=== APB RegFile All Sequence DONE ===", UVM_LOW)
    endtask

endclass