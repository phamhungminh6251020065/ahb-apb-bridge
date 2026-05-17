//==============================================================================
// File    : bridge_single_write_read_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 17/05/2026
//------------------------------------------------------------------------------
// Description:
// AHB write: IDLE(1)→WWAIT(1)→WRITE/SETUP(1)→WENABLE/ACCESS(1). Bridge stall AHB Master 3 cycle.=> 4 cycle total
// AHB read: IDLE(1)→READ/SETUP(1)→RENABLE/ACCESS(1). Bridge stall 2 cycle. HRDATA valid khi HREADY=1. => 3 cycle total
//==============================================================================

class bridge_single_write_read_seq extends ahb_base_seq;
    `uvm_object_utils(bridge_single_write_read_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    rand logic [31:0] wr_addr;
    rand logic [31:0] wr_data;

    // Constraint: Địa chỉ nằm trong vùng 0x4000_0000 - 0x4002_FFFF, 
    //map theo từng thanh ghi cụ thể để đảm bảo test đúng chức năng của bridge và tránh lỗi do địa chỉ không hợp lệ 
    constraint addr_cnst {
        wr_addr inside {

            // 32'h4000_0000,
            // 32'h4000_0004,
            // 32'h4000_0008,

            // 32'h4001_0000,
            // 32'h4001_0004,
            // 32'h4001_0008,

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
    // Constraint: Dữ liệu random, tránh giá trị đặc biệt (0x0000_0000, 0xFFFF_FFFF)
    constraint data_cnst {
        wr_data inside {[32'h0000_0001:32'hFFFF_FFFE]};
    }

    function new(string name = "bridge_single_write_read_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rd_data;
        time wr_start, wr_end;
        time rd_start, rd_end;

        `uvm_info("SINGLE_WRITE_SEQ", "=== AHB SINGLE WRITE READ TEST START ===", UVM_LOW)

        //--------------------------------------------
        // Randomize address & data
        //--------------------------------------------
        if (!randomize(wr_addr, wr_data)) begin
            `uvm_fatal("SINGLE_WRITE_SEQ", "Randomization failed")
        end

        `uvm_info("SINGLE_WRITE_SEQ", $sformatf( "Randomized addr=0x%08h data=0x%08h", wr_addr, wr_data), UVM_LOW)

        //--------------------------------------------
        // WRITE transfer
        //--------------------------------------------
        wr_start = $time;

        do_write(wr_addr, wr_data);

        wr_end = $time;

        `uvm_info("SINGLE_WRITE_SEQ", $sformatf( "WRITE transfer: start=%0t end=%0t duration=%0t",
                wr_start,
                wr_end,
                wr_end - wr_start),
            UVM_LOW)

        //--------------------------------------------
        // Wait a few clock cycles
        //--------------------------------------------
        //repeat(3) @(posedge p_sequencer.vif.HCLK);

        //--------------------------------------------
        // READ transfer
        //--------------------------------------------
        rd_start = $time;

        do_read(wr_addr, rd_data);

        rd_end = $time;

        `uvm_info("SINGLE_WRITE_SEQ", $sformatf( "READ transfer: start=%0t end=%0t duration=%0t",
                rd_start,
                rd_end,
                rd_end - rd_start),
            UVM_LOW)


        `uvm_info("SINGLE_WRITE_SEQ", "=== AHB SINGLE WRITE READ TEST DONE ===", UVM_LOW)

    endtask
endclass : bridge_single_write_read_seq