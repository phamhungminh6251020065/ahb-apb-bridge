//==============================================================================
// File    : arb_fixed_m1_wins_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 19/05/2026
//------------------------------------------------------------------------------
// Description:
//  Arbiter MODE=0, cả 2 HBUSREQ=1 → HGRANT1=1, HGRANT2=0 ngay khi HREADY=1.
//==============================================================================

class arb_fixed_m1_wins_seq extends ahb_base_seq;
    `uvm_object_utils(arb_fixed_m1_wins_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)
    
    function new(string name = "arb_fixed_m1_wins_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rdata;

        `uvm_info("ARB_FIXED_M1_WINS_SEQ", "=== ARB FIXED M1 WINS TEST START ===", UVM_LOW)
        // testcase thực hiện fork để chạy master_id đồng thời trên cả hai master
        // seq này chỉ thực hiện trans để xem master_id nào được grant khi cả hai master đều request bus cùng lúc
        do_write(32'h4002_0000, 32'hDEAD_BEEF);
        do_read(32'h4002_0000, rdata);
        `uvm_info("ARB_FIXED_M1_WINS_SEQ", "=== ARB FIXED M1 WINS TEST DONE ===", UVM_LOW)
    endtask : body
endclass : arb_fixed_m1_wins_seq