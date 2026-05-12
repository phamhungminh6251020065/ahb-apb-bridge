//==============================================================================
// File    : apb_pslverr_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 09/05/2026
//------------------------------------------------------------------------------
// Description:
//   Ghi vào một địa chỉ APB không hợp lệ để kích hoạt lỗi PSLVERR, đảm bảo hệ thống xử lý lỗi đúng cách.
//   Truy cập địa chỉ invalid trong phạm vi Slave → PSLVERR=1 → Bridge convert HRESP=01(ERROR)
//==============================================================================
class apb_pslverr_seq extends ahb_base_seq;
    `uvm_object_utils(apb_pslverr_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)
    
    function new(string name = "apb_pslverr_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rdata;

        `uvm_info("PSLVER_SEQ", "=== APB PSLVERR TEST START ===", UVM_LOW)

        // Ghi vào một địa chỉ APB không hợp lệ để kích hoạt lỗi PSLVERR
        do_write(32'h4002_0020, 32'hDEAD_BEEF); // Địa chỉ invalid (không thuộc phạm vi slave nào)
        do_write(32'h4002_0024, 32'h1234_5678); // Địa chỉ invalid
        do_write(32'h4003_0008, 32'hCAFEBABE); // Địa chỉ invalid
        // Đợi một vài chu kỳ để đảm bảo lỗi được xử lý
        repeat(5) @(posedge p_sequencer.vif.HCLK);
        do_read(32'h4002_0020, rdata);
        do_read(32'h4002_0024, rdata);
        do_read(32'h4003_0008, rdata);
        // ghi vào địa chỉ valid để đảm bảo bridge vẫn hoạt động bình thường sau lỗi
        do_write(32'h4002_0000, 32'hABCD_EF01); // Địa chỉ valid (thuộc phạm vi slave)
        do_write(32'h4002_0004, 32'h5678_1234); // Địa chỉ valid
        // Đọc lại để verify dữ liệu vẫn được ghi đúng sau lỗi
        do_read(32'h4002_0000, rdata);
        do_read(32'h4002_0004, rdata);

        `uvm_info("PSLVER_SEQ", "=== APB PSLVERR TEST DONE ===", UVM_LOW)
    endtask : body

endclass : apb_pslverr_seq