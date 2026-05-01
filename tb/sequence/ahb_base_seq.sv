//==============================================================================
// File    : ahb_base_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 14/04/2026
//------------------------------------------------------------------------------
// Thay đổi so với bản cũ: KHÔNG có gì thay đổi về logic —
// ahb_base_seq chỉ là base class, các seq con sẽ kế thừa và override body().
// Thêm helper task do_write/do_read để seq con dùng lại.
//==============================================================================

class ahb_base_seq extends uvm_sequence #(ahb_trans);
    `uvm_object_utils(ahb_base_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)
    virtual ahb_if vif;

    int unsigned master_id = 0;

    function new(string name = "ahb_base_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info("BASE_SEQ", "Base sequence body — override in subclass", UVM_LOW)
    endtask

    // ── WRITE ─────────────────────────────────────────────
    task do_write(input logic [31:0] addr, input logic [31:0] data);
        ahb_trans tr;

        `uvm_create(tr)

        tr.master_id = master_id;
        tr.hwrite    = 1'b1;
        tr.haddr     = addr;
        tr.hwdata    = data;
        tr.htrans    = 2'b10;
        tr.hsize     = 3'b010;
        tr.hburst    = 3'b000;

        `uvm_info("AHB_BASE_SEQ", $sformatf("do_write: addr=0x%h data=0x%h", addr, data), UVM_LOW)

        start_item(tr);
        finish_item(tr);
    endtask

    // ── READ ──────────────────────────────────────────────
    task do_read(input logic [31:0] addr, output logic [31:0] rdata);
        ahb_trans tr;

        `uvm_create(tr)

        tr.master_id = master_id;
        tr.hwrite    = 1'b0;
        tr.haddr     = addr;
        tr.hwdata    = 32'h0;
        tr.htrans    = 2'b10;
        tr.hsize     = 3'b010;
        tr.hburst    = 3'b000;

        start_item(tr);
        finish_item(tr);
        vif.wait_ready();

        if (tr.hresp != 2'b00)
            `uvm_error("AHB_SEQ", "Read error response")

        rdata = tr.hrdata;
    endtask

    task do_reset();
        `uvm_info("SEQ", "Applying RESET", UVM_LOW)
        vif.reset_dut();
    endtask

endclass