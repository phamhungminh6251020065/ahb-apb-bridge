//==============================================================================
// File    : bridge_b2b_write_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 18/05/2026
//------------------------------------------------------------------------------
// Description:
// Ghi liên tiếp 4 register khác nhau không idle cycle. Đọc lại → 4/4 data không bị lẫn.
//==============================================================================

class bridge_b2b_write_read_seq extends ahb_base_seq;
    `uvm_object_utils(bridge_b2b_write_read_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    rand logic [31:0] wr_data [4]; // Dữ liệu cho 4 register liên tiếp

    constraint data_cnst {
        foreach (wr_data[i]) {
            wr_data[i] inside {[32'h0000_0001:32'hFFFF_FFFE]};
        }

        // đảm bảo 4 data khác nhau
        unique {wr_data[0], wr_data[1], wr_data[2], wr_data[3]};
    }

    function new(string name = "bridge_b2b_write_read_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rd_data;
        

        `uvm_info("B2B_WRITE_SEQ", "=== AHB BACK-TO-BACK WRITE TEST START ===", UVM_LOW)
        
        // Randomize data
        if (!randomize(wr_data)) begin
            `uvm_error("B2B_WRITE_SEQ", "Randomization failed")
            return;
        end
        // Ghi liên tiếp 4 register khác nhau không idle cycle
        do_write(32'h4002_0000, wr_data[0]);
        do_write(32'h4002_0004, wr_data[1]);
        do_write(32'h4002_0008, wr_data[2]);
        do_write(32'h4002_000C, wr_data[3]);
        // Đọc lại → 4/4 data không bị lẫn
        do_read(32'h4002_0000, rd_data);
        do_read(32'h4002_0004, rd_data);
        do_read(32'h4002_0008, rd_data);
        do_read(32'h4002_000C, rd_data);
    endtask : body
endclass : bridge_b2b_write_read_seq