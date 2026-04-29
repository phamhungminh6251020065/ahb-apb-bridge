//==============================================================================
// File    : ahb_monitor.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 14/04/2026
//------------------------------------------------------------------------------
// Thay đổi so với bản cũ (lớn nhất):
//   Cũ: detect done signal của ahb_master → capture addr_in/wdata_in/rdata_out
//   Mới: observe AHB bus trực tiếp
//        - Detect address phase: HTRANS=NONSEQ && HREADY=1
//        - Latch HADDR/HWRITE ở address phase
//        - Detect data phase: cycle sau address phase, HREADY=1
//        - Latch HWDATA (write) hoặc HRDATA (read) ở data phase
//        - Gửi transaction về Scoreboard/Coverage sau data phase
//
// AHB Monitor phải hiểu pipeline:
//   HADDR valid ở cycle T (address phase)
//   HWDATA/HRDATA valid ở cycle T+1 (data phase, khi HREADY=1)
//==============================================================================

class ahb_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_monitor)

    virtual ahb_if vif;
    uvm_analysis_port #(ahb_trans) ap;

    int master_id = 0;
    int num_trans;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ahb_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", {"Cannot get vif: ", get_full_name()})
    endfunction

    virtual task run_phase(uvm_phase phase);
        @(posedge vif.HRESETn);
        @(vif.monitor_cb);

        forever begin
            collect_transaction();
        end
    endtask

    // ─────────────────────────────────────────────
    task collect_transaction();
        ahb_trans tr;

        // ── WAIT ADDRESS PHASE ────────────────────
        do begin
            @(vif.monitor_cb);
        end while (!(vif.monitor_cb.HTRANS[1] &&
                     vif.monitor_cb.HREADYout &&
                     vif.monitor_cb.HGRANT));

        // ── CAPTURE ADDRESS PHASE ─────────────────
        tr = ahb_trans::type_id::create("tr", this);
        tr.master_id = master_id;

        tr.haddr  = vif.monitor_cb.HADDR;
        tr.hwrite = vif.monitor_cb.HWRITE;
        tr.hsize  = vif.monitor_cb.HSIZE;
        tr.hburst = vif.monitor_cb.HBURST;
        tr.htrans = vif.monitor_cb.HTRANS;

        // ── MOVE TO DATA PHASE ────────────────────
        @(vif.monitor_cb);

        // wait until transfer complete (HREADYout=1)
        while (!vif.monitor_cb.HREADYout)
            @(vif.monitor_cb);

        // ── CAPTURE DATA PHASE ────────────────────
        tr.hresp     = vif.monitor_cb.HRESP;
        tr.hreadyout = vif.monitor_cb.HREADYout;

        if (tr.hwrite)
            tr.hwdata = vif.monitor_cb.HWDATA;
        else
            tr.hrdata = vif.monitor_cb.HRDATA;

        // ── SEND OUT ─────────────────────────────
        ap.write(tr);
        num_trans++;

        `uvm_info("AHB_MON",
            $sformatf("[M%0d] %s", master_id, tr.convert2string()),
            UVM_LOW)
    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
            $sformatf("REPORT: AHB M%0d TRANS COLLECTED = %0d", master_id, num_trans),
            UVM_LOW)
    endfunction

endclass