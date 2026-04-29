//==============================================================================
// File    : apb_if.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 14/04/2026
//------------------------------------------------------------------------------
// Description:
//   APB Interface — passive, chỉ observe (không drive).
//   APB bus được drive bởi Bridge (DUT), TB chỉ monitor.
//   Sửa so với bản cũ:
//     - Tách PRDATA thành PRDATA1/2/3 khớp với dut_top port
//     - Tách PREADY thành PREADY1/2/3
//     - Tách PSLVERR thành PSLVERR1/2/3
//     - Thêm TIMER_IRQ và GPIO_OUT để monitor observe
//==============================================================================

interface apb_if (input logic PCLK, input logic PRESETn);

    // ── APB bus ─────────────────────────────
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;

    logic [2:0]  PSEL;

    logic        PSEL1, PSEL2, PSEL3;  // Individual PSEL signals

    logic [31:0] PRDATA1, PRDATA2, PRDATA3;
    logic        PREADY1, PREADY2, PREADY3;
    logic        PSLVERR1, PSLVERR2, PSLVERR3;

    // Peripheral outputs
    logic [31:0] GPIO_OUT;
    logic        TIMER_IRQ;

    // ── Combined view (for monitor) ─────────
    logic [31:0] PRDATA;
    logic        PREADY;
    logic        PSLVERR;

    always_comb begin
        PRDATA  = 32'h0;
        PREADY  = 1'b0;
        PSLVERR = 1'b0;

        if (PSEL[0]) begin
            PRDATA  = PRDATA1;
            PREADY  = PREADY1;
            PSLVERR = PSLVERR1;
        end
        else if (PSEL[1]) begin
            PRDATA  = PRDATA2;
            PREADY  = PREADY2;
            PSLVERR = PSLVERR2;
        end
        else if (PSEL[2]) begin
            PRDATA  = PRDATA3;
            PREADY  = PREADY3;
            PSLVERR = PSLVERR3;
        end
    end

    // ── Monitor ─────────────────────────────
    clocking monitor_cb @(posedge PCLK);
        default input #1step;

        input PADDR, PWDATA, PWRITE, PENABLE;
        input PSEL, PSEL1, PSEL2, PSEL3;
        input PRDATA, PRDATA1, PRDATA2, PRDATA3;
        input PREADY, PREADY1, PREADY2, PREADY3;
        input PSLVERR, PSLVERR1, PSLVERR2, PSLVERR3;
    endclocking

    modport monitor_mp (clocking monitor_cb, input PCLK, PRESETn);

endinterface : apb_if