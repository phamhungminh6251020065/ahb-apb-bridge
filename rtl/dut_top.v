//==============================================================================
// File    : dut_top.v
// Author  : Pham Hung Minh
// Project : AHB-to-APB Bridge
// Date    : 22/04/2026
//------------------------------------------------------------------------------
// Description:
//     DUT wrapper dùng cho UVM verification.
//     Khác với top.v (dùng cho temp TB), file này:
//       - KHÔNG instantiate ahb_master (vai trò này do UVM AHB Driver đảm nhiệm)
//       - Expose trực tiếp AHB Master interface ra port để TB/Driver drive
//       - Expose APB interface ra port để APB Monitor observe
//     Gồm:
//       - ahb_interconnect  (Arbiter + Mux)
//       - bridge_top        (AHB-to-APB Bridge)
//       - apb_slave_gpio
//       - apb_slave_timer
//       - apb_slave_regfile
//==============================================================================

module dut_top (
    // ── Global signals ──────────────────────────────────────────────────────
    input  wire        HCLK,
    input  wire        HRESETn,

    // ── AHB Master 1 interface (driven by UVM AHB Driver) ───────────────────
    input  wire        HBUSREQ1,
    input  wire [31:0] HADDR1,
    input  wire [31:0] HWDATA1,
    input  wire        HWRITE1,
    input  wire [1:0]  HTRANS1,
    input  wire [2:0]  HSIZE1,
    input  wire [2:0]  HBURST1,
    output wire        HGRANT1,
    output wire [31:0] HRDATA1,
    output wire        HREADY1,
    output wire [1:0]  HRESP1,

    // ── AHB Master 2 interface (driven by UVM AHB Driver) ───────────────────
    input  wire        HBUSREQ2,
    input  wire [31:0] HADDR2,
    input  wire [31:0] HWDATA2,
    input  wire        HWRITE2,
    input  wire [1:0]  HTRANS2,
    input  wire [2:0]  HSIZE2,
    input  wire [2:0]  HBURST2,
    output wire        HGRANT2,
    output wire [31:0] HRDATA2,
    output wire        HREADY2,
    output wire [1:0]  HRESP2,

    // ── GPIO pins (observed by TB) ───────────────────────────────────────────
    input  wire [7:0]  GPIO_IN,
    output wire [7:0]  GPIO_OUT,

    // ── Timer interrupt (observed by TB) ────────────────────────────────────
    output wire        TIMER_IRQ
);

    // ── Internal wires: Interconnect → Bridge ────────────────────────────────
    wire [31:0] HADDR;
    wire [31:0] HWDATA;
    wire        HWRITE;
    wire [1:0]  HTRANS;
    wire [2:0]  HSIZE;
    wire [2:0]  HBURST;
    wire        HSEL;
    wire        HREADYin;
    wire        HREADYout;
    wire [31:0] HRDATA;
    wire [1:0]  HRESP;

    // ── Internal wires: Bridge → APB Slaves ──────────────────────────────────
    wire [31:0] PADDR;
    wire [31:0] PWDATA;
    wire        PWRITE;
    wire        PENABLE;
    wire        PSEL1, PSEL2, PSEL3;

    wire [31:0] PRDATA1, PRDATA2, PRDATA3;
    wire        PREADY1, PREADY2, PREADY3;
    wire        PSLVERR1, PSLVERR2, PSLVERR3;

    // HREADYin = feedback từ HREADYout (AHB spec)
    assign HREADYin = HREADYout;

    // ── AHB Interconnect ─────────────────────────────────────────────────────
    ahb_interconnect interconnect_inst (
        .HCLK     (HCLK),
        .HRESETn  (HRESETn),
        // Response từ Bridge (broadcast về cả 2 Master)
        .HREADY   (HREADYout),
        .HRDATA   (HRDATA),
        .HRESP    (HRESP),
        // Master 1
        .HBUSREQ1 (HBUSREQ1),
        .HADDR1   (HADDR1),
        .HWDATA1  (HWDATA1),
        .HWRITE1  (HWRITE1),
        .HTRANS1  (HTRANS1),
        .HSIZE1   (HSIZE1),
        .HBURST1  (HBURST1),
        .HGRANT1  (HGRANT1),
        .HREADY1  (HREADY1),
        .HRDATA1  (HRDATA1),
        .HRESP1   (HRESP1),
        // Master 2
        .HBUSREQ2 (HBUSREQ2),
        .HADDR2   (HADDR2),
        .HWDATA2  (HWDATA2),
        .HWRITE2  (HWRITE2),
        .HTRANS2  (HTRANS2),
        .HSIZE2   (HSIZE2),
        .HBURST2  (HBURST2),
        .HGRANT2  (HGRANT2),
        .HREADY2  (HREADY2),
        .HRDATA2  (HRDATA2),
        .HRESP2   (HRESP2),
        // Output tới Bridge
        .HADDR    (HADDR),
        .HWDATA   (HWDATA),
        .HWRITE   (HWRITE),
        .HTRANS   (HTRANS),
        .HSIZE    (HSIZE),
        .HBURST   (HBURST),
        .HSEL     (HSEL)
    );

    // ── AHB-to-APB Bridge ────────────────────────────────────────────────────
    bridge_top bridge_inst (
        .HCLK      (HCLK),
        .HRESETn   (HRESETn),
        .HADDR     (HADDR),
        .HWRITE    (HWRITE),
        .HTRANS    (HTRANS),
        .HSIZE     (HSIZE),
        .HWDATA    (HWDATA),
        .HREADYin  (HREADYin),
        .HSEL      (HSEL),
        .HBURST    (HBURST),
        // APB Slave responses
        .PRDATA1   (PRDATA1),
        .PRDATA2   (PRDATA2),
        .PRDATA3   (PRDATA3),
        .PREADY1   (PREADY1),
        .PREADY2   (PREADY2),
        .PREADY3   (PREADY3),
        .PSLVERR1  (PSLVERR1),
        .PSLVERR2  (PSLVERR2),
        .PSLVERR3  (PSLVERR3),
        // AHB responses
        .HRDATA    (HRDATA),
        .HREADYout (HREADYout),
        .HRESP     (HRESP),
        // APB outputs
        .PSEL1     (PSEL1),
        .PSEL2     (PSEL2),
        .PSEL3     (PSEL3),
        .PENABLE   (PENABLE),
        .PWRITE    (PWRITE),
        .PADDR     (PADDR),
        .PWDATA    (PWDATA)
    );

    // ── APB Slave 1: GPIO ────────────────────────────────────────────────────
    apb_slave_gpio gpio_inst (
        .PCLK    (HCLK),
        .PRESETn (HRESETn),
        .PSEL    (PSEL1),
        .PENABLE (PENABLE),
        .PWRITE  (PWRITE),
        .PADDR   (PADDR),
        .PWDATA  (PWDATA),
        .PRDATA  (PRDATA1),
        .PREADY  (PREADY1),
        .PSLVERR (PSLVERR1),
        .GPIO_IN (GPIO_IN),
        .GPIO_OUT(GPIO_OUT)
    );

    // ── APB Slave 2: Timer ───────────────────────────────────────────────────
    apb_slave_timer timer_inst (
        .PCLK     (HCLK),
        .PRESETn  (HRESETn),
        .PSEL     (PSEL2),
        .PENABLE  (PENABLE),
        .PWRITE   (PWRITE),
        .PADDR    (PADDR),
        .PWDATA   (PWDATA),
        .PRDATA   (PRDATA2),
        .PREADY   (PREADY2),
        .PSLVERR  (PSLVERR2),
        .TIMER_IRQ(TIMER_IRQ)
    );

    // ── APB Slave 3: Register File ───────────────────────────────────────────
    apb_slave_regfile regfile_inst (
        .PCLK    (HCLK),
        .PRESETn (HRESETn),
        .PSEL    (PSEL3),
        .PENABLE (PENABLE),
        .PWRITE  (PWRITE),
        .PADDR   (PADDR),
        .PWDATA  (PWDATA),
        .PRDATA  (PRDATA3),
        .PREADY  (PREADY3),
        .PSLVERR (PSLVERR3)
    );

endmodule : dut_top