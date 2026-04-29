//==============================================================================
// File    : ahb_if.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 14/04/2026
//------------------------------------------------------------------------------
// Description:
//   AHB Interface cho DUT mới (dut_top.v — không có ahb_master).
//   Driver drive trực tiếp AHB bus signals (HBUSREQ, HADDR, HWDATA, HTRANS...)
//   Monitor observe bus để tạo transaction gửi về Scoreboard/Coverage.
//   Interface này được instantiate 2 lần trong tb_top: ahb_if_m1, ahb_if_m2.
//==============================================================================

interface ahb_if (input logic HCLK, input logic HRESETn);

    // ── Master → Bus ─────────────────────────
    logic        HBUSREQ;
    logic [31:0] HADDR;
    logic [31:0] HWDATA;
    logic        HWRITE;
    logic [1:0]  HTRANS;
    logic [2:0]  HSIZE;
    logic [2:0]  HBURST;
    logic        HSEL;

    // ── Bus → Master ─────────────────────────
    logic        HGRANT;
    logic [31:0] HRDATA;
    logic        HREADY;
    logic [1:0]  HRESP;

    // Alias for compatibility
    logic        HREADYout;
    assign HREADYout = HREADY;

    // ── Driver ───────────────────────────────
    clocking driver_cb @(posedge HCLK);
        default input #1step output #1step;
        output HBUSREQ, HADDR, HWDATA, HWRITE, HTRANS, HSIZE, HBURST, HSEL;
        input  HGRANT, HRDATA, HREADY, HRESP, HREADYout;
    endclocking

    // ── Monitor ──────────────────────────────
    clocking monitor_cb @(posedge HCLK);
        default input #1step;
        input HBUSREQ, HADDR, HWDATA, HWRITE, HTRANS, HSIZE, HBURST, HSEL;
        input HGRANT, HRDATA, HREADY, HRESP, HREADYout;
    endclocking

    // ── Reset helper ─────────────────────────
    task reset_signals();
        HBUSREQ = 0;
        HADDR   = 0;
        HWDATA  = 0;
        HWRITE  = 0;
        HTRANS  = 2'b00;
        HSIZE   = 3'b010;
        HBURST  = 3'b000;
        HSEL    = 0;
    endtask

    // ── Wait until transfer completes ────────
    task wait_ready();
        @(driver_cb);
        while (!driver_cb.HREADY) @(driver_cb);
    endtask

    // ── Modports ─────────────────────────────
    modport driver_mp  (clocking driver_cb,  input HCLK, HRESETn);
    modport monitor_mp (clocking monitor_cb, input HCLK, HRESETn);

endinterface : ahb_if