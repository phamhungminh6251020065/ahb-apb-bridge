//==============================================================================
// File    : ahb_driver.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 14/04/2026
//------------------------------------------------------------------------------
// Thay đổi so với bản cũ (lớn nhất):
//   Cũ: drive start_req/addr_in/wdata_in → ahb_master RTL → bus
//   Mới: drive trực tiếp HBUSREQ/HADDR/HWDATA/HTRANS lên AHB bus
//
// Timing chuẩn AHB:
//   Cycle 1 (REQUEST): HBUSREQ=1, HTRANS=IDLE, chờ HGRANT=1 && HREADY=1
//   Cycle 2 (ADDR)   : HTRANS=NONSEQ, drive HADDR/HWRITE/HSIZE/HBURST
//   Cycle 3+ (DATA)  : HTRANS=IDLE, drive HWDATA (nếu write)
//                      chờ HREADY=1 → transfer hoàn thành
//   Sau done         : HBUSREQ=0, HTRANS=IDLE, deassert tất cả
//==============================================================================

class ahb_driver extends uvm_driver #(ahb_trans);
    `uvm_component_utils(ahb_driver)

    virtual ahb_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ahb_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", {"Cannot get vif: ", get_full_name()})
    endfunction

    virtual task run_phase(uvm_phase phase);
        drive_idle();

        @(posedge vif.HRESETn);
        repeat(2) @(posedge vif.HCLK);

        forever begin
            ahb_trans tr;
            seq_item_port.get_next_item(tr);
            drive_transfer(tr);
            seq_item_port.item_done();
        end
    endtask

    // ─────────────────────────────────────────────
    virtual task drive_transfer(ahb_trans tr);

        // ── REQUEST BUS ───────────────────────────
        @(vif.driver_cb);
        vif.driver_cb.HBUSREQ <= 1;
        vif.driver_cb.HTRANS  <= 2'b00;

        // wait grant
        do @(vif.driver_cb);
        while (!vif.driver_cb.HGRANT);

        // ── ADDRESS PHASE ─────────────────────────
        @(vif.driver_cb);
        vif.driver_cb.HADDR  <= tr.haddr;
        vif.driver_cb.HWRITE <= tr.hwrite;
        vif.driver_cb.HTRANS <= tr.htrans;
        vif.driver_cb.HSIZE  <= tr.hsize;
        vif.driver_cb.HBURST <= tr.hburst;

        // ── DATA PHASE ────────────────────────────
        @(vif.driver_cb);

        if (tr.hwrite) begin
            vif.driver_cb.HWDATA <= tr.hwdata;

            `uvm_info("AHB_DRV",
                $sformatf("Driving HWDATA = 0x%h for addr=0x%h",
                tr.hwdata, tr.haddr), UVM_LOW)
        end

        // ── HOLD DATA UNTIL HREADY ────────────────
        while (!vif.driver_cb.HREADYout) begin
            @(vif.driver_cb);

            // giữ lại toàn bộ tín hiệu
            vif.driver_cb.HADDR  <= tr.haddr;
            vif.driver_cb.HWRITE <= tr.hwrite;
            vif.driver_cb.HTRANS <= tr.htrans;

            if (tr.hwrite)
                vif.driver_cb.HWDATA <= tr.hwdata;
        end

        // ── CAPTURE RESPONSE ──────────────────────
        tr.hresp     = vif.driver_cb.HRESP;
        tr.hreadyout = vif.driver_cb.HREADYout;

        if (!tr.hwrite)
            tr.hrdata = vif.driver_cb.HRDATA;

        // ── RELEASE BUS (NHẸ NHÀNG) ───────────────
        @(vif.driver_cb);
        vif.driver_cb.HBUSREQ <= 0;
        vif.driver_cb.HTRANS  <= 2'b00;

        // ❌ KHÔNG gọi drive_idle() ở đây

    endtask

    // ─────────────────────────────────────────────
    task drive_idle();
        vif.driver_cb.HBUSREQ <= 0;
        vif.driver_cb.HTRANS  <= 2'b00;

        // ❗ KHÔNG reset HWDATA nữa
        // vif.driver_cb.HWDATA <= 0; ❌ bỏ

        // optional: giữ nguyên HADDR/HWRITE
    endtask

endclass