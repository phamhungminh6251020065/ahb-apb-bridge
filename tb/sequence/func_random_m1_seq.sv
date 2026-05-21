//==============================================================================
// File    : func_random_m1_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 21/05/2026
//------------------------------------------------------------------------------
// Description:
// Random HADDR ∈ [0x4002_0000..0x4002_001C], random HWDATA. Scoreboard verify đọc khớp ghi.
//==============================================================================

class func_random_m1_seq extends ahb_base_seq;
    `uvm_object_utils(func_random_m1_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    rand logic [31:0] wr_addr;
    rand logic [31:0] wr_data;

    // Constraint địa chỉ nằm trong vùng reg[0..7]
    constraint addr_cnst {
        wr_addr inside {
            32'h4002_0000,
            32'h4002_0004,
            32'h4002_0008,
            32'h4002_000C,
            32'h4002_0010,
            32'h4002_0014,
            32'h4002_0018,
            32'h4002_001C
        };
    }
    // Constraint dữ liệu nằm trong khoảng hợp lệ
    constraint data_cnst {
        wr_data inside {[32'h0000_0001:32'hFFFF_FFFE]};
    }

    function new(string name = "func_random_m1_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rd_data;

        `uvm_info("RANDOM_M1_SEQ", "=== RANDOM M1 TEST START ===", UVM_LOW)

        // Randomize address and data
        if (!randomize(wr_addr, wr_data)) begin
            `uvm_error("RANDOM_M1_SEQ", "Randomization failed")
            return;
        end

        // Ghi 8 địa chỉ ngẫu nhiên với dữ liệu ngẫu nhiên
        do_write(wr_addr, wr_data);

        // Đọc lại và verify dữ liệu khớp ghi
        do_read(wr_addr, rd_data);

        `uvm_info("RANDOM_M1_SEQ", "=== RANDOM M1 TEST DONE ===", UVM_LOW)
    endtask : body

endclass : func_random_m1_seq
