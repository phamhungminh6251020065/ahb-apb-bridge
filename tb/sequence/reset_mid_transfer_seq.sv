//==============================================================================
// File    : reset_mid_transfer_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 09/05/2026
//------------------------------------------------------------------------------
// Description:
//   Reset giữa chừng một transfer đang diễn ra, đảm bảo hệ thống xử lý reset đúng cách và không bị treo.
//==============================================================================

class reset_mid_transfer_seq extends ahb_base_seq;
    `uvm_object_utils(reset_mid_transfer_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)
    
    function new(string name = "reset_mid_transfer_seq");
        super.new(name);
    endfunction : new


    virtual task body();
        logic [31:0] rdata;

        `uvm_info("RESET_SEQ", "=== RESET MID-TRANSFER TEST START ===", UVM_LOW)

        fork
            begin
                do_write(32'h4002_0000, 32'hDEAD_BEEF);
                do_write(32'h4002_0004, 32'hCAFE_BABE);
                do_write(32'h4002_0008, 32'h1234_5678);
                do_write(32'h4002_000C, 32'h8765_4321);
                do_write(32'h4000_0004, 32'h0000_00FF); // DIR = all output
                do_write(32'h4000_0000, 32'h0000_00A5); // DATA = 0xA5
                do_write(32'h4001_0008, 32'h0000_000A); // PERIOD = 10
                do_write(32'h4001_0000, 32'h0000_0001); // CTRL EN=1
            end
        join_none
        //repeat(2) @(posedge p_sequencer.vif.HCLK); // delay để đảm bảo transfer đã bắt đầu (HREADY=0) trước khi reset
        wait(p_sequencer.vif.HREADY == 0); // Đợi transfer bắt đầu (HREADY=0) → reset ngay lúc này
        do_reset();
        disable fork;

        wait(p_sequencer.vif.HREADY == 1); // Đợi slave hoàn thành transfer (HREADY=1) sau reset 
        do_read(32'h4002_0000, rdata);
        do_read(32'h4002_0004, rdata);
        do_read(32'h4002_0008, rdata);
        do_read(32'h4002_000C, rdata);
        do_read(32'h4000_0000, rdata);
        do_read(32'h4000_0004, rdata);  
        do_read(32'h4001_0008, rdata);
        do_read(32'h4001_0000, rdata);
        // Ghi lại một transfer sau reset để đảm bảo bridge vẫn hoạt động bình thường
        do_write(32'h4002_0004, 32'hCAFE_BABE);
        do_read(32'h4002_0004, rdata);

        `uvm_info("RESET_SEQ", "=== RESET MID-TRANSFER TEST DONE ===", UVM_LOW)
    endtask : body

endclass : reset_mid_transfer_seq