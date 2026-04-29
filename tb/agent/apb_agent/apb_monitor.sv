//==============================================================================
// File    : apb_monitor.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 15/04/2026
//------------------------------------------------------------------------------
// Thay đổi so với bản cũ:
//   - Tách psel → psel1/psel2/psel3 (khớp với apb_if mới)
//   - Tách PRDATA → PRDATA1/2/3, chọn đúng PRDATAx theo slave active
//   - Tách PREADY → PREADY1/2/3, PSLVERR → PSLVERR1/2/3
//   - Gọi tr.decode_slave() thay vì set tr.psel trực tiếp
//   - Capture điều kiện: PENABLE=1 AND PREADYx=1 (ACCESS phase hoàn thành)
//==============================================================================

class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)

    virtual apb_if             vif;
    uvm_analysis_port #(apb_trans) ap;
    int num_trans;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
            `uvm_fatal("APB_MON", {"Cannot get vif: ", get_full_name()})
    endfunction

    virtual task run_phase(uvm_phase phase);
        @(posedge vif.PRESETn);
        @(vif.monitor_cb);

        forever begin
            collect_transaction();
        end
    endtask

    task collect_transaction();
        apb_trans tr;
        logic pready_active;

        // Wait ACCESS phase
        do begin
            @(vif.monitor_cb);
        end while (!(vif.monitor_cb.PENABLE &&
                    (vif.monitor_cb.PSEL1 ||
                     vif.monitor_cb.PSEL2 ||
                     vif.monitor_cb.PSEL3)));

        // Wait until PREADY=1 (sample đúng cycle)
        do begin
            @(vif.monitor_cb);
            pready_active = vif.monitor_cb.PSEL1 ? vif.monitor_cb.PREADY1 :
                            vif.monitor_cb.PSEL2 ? vif.monitor_cb.PREADY2 :
                                                   vif.monitor_cb.PREADY3;
        end while (!pready_active);

        // Create transaction
        tr = apb_trans::type_id::create("tr", this);

        tr.paddr   = vif.monitor_cb.PADDR;
        tr.pwrite  = vif.monitor_cb.PWRITE;
        tr.pwdata  = vif.monitor_cb.PWDATA;
        tr.penable = vif.monitor_cb.PENABLE;
        tr.psel1   = vif.monitor_cb.PSEL1;
        tr.psel2   = vif.monitor_cb.PSEL2;
        tr.psel3   = vif.monitor_cb.PSEL3;

        // Select correct slave response
        if (vif.monitor_cb.PSEL1) begin
            tr.prdata   = vif.monitor_cb.PRDATA1;
            tr.pready   = vif.monitor_cb.PREADY1;
            tr.pslverr  = vif.monitor_cb.PSLVERR1;
        end else if (vif.monitor_cb.PSEL2) begin
            tr.prdata   = vif.monitor_cb.PRDATA2;
            tr.pready   = vif.monitor_cb.PREADY2;
            tr.pslverr  = vif.monitor_cb.PSLVERR2;
        end else if (vif.monitor_cb.PSEL3) begin
            tr.prdata   = vif.monitor_cb.PRDATA3;
            tr.pready   = vif.monitor_cb.PREADY3;
            tr.pslverr  = vif.monitor_cb.PSLVERR3;
        end else begin
            `uvm_warning("APB_MON", "No slave selected!")
        end

        tr.decode_slave();

        ap.write(tr);
        num_trans++;

        `uvm_info("APB_MON", tr.convert2string(), UVM_LOW)
    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
            $sformatf("REPORT: APB TRANS COLLECTED = %0d", num_trans),
            UVM_LOW)
    endfunction

endclass