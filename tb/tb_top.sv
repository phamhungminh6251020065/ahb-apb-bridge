//==============================================================================
// File    : tb_top.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 22/04/2026
//------------------------------------------------------------------------------
// Description:
//   Testbench top level cho UVM verification với dut_top.v
//   (DUT không có ahb_master — driver drive trực tiếp AHB bus)
//==============================================================================

`timescale 1ns/1ps

module tb_top #(
    parameter ARBITER_MODE = 0  // 0: Fixed Priority, 1: Round Robin (can be overridden via plusargs in simulation command)
);

    import uvm_pkg::*;
    import test_pkg::*;

    // ── Clock ────────────────────────────────
    logic HCLK;

    initial begin
        HCLK = 0;
        forever #5 HCLK = ~HCLK;
    end

    // ── Interface ────────────────────────────
    ahb_if ahb_vif_m1(.HCLK(HCLK));
    ahb_if ahb_vif_m2(.HCLK(HCLK));
    apb_if apb_vif(.PCLK(HCLK), .PRESETn(ahb_vif_m1.HRESETn));

    // ── Reset drive (IMPORTANT) ──────────────
    initial begin
        ahb_vif_m1.reset_signals();
        ahb_vif_m2.reset_signals();

        ahb_vif_m1.HRESETn = 0;
        ahb_vif_m2.HRESETn = 0;
        #20;
        ahb_vif_m1.HRESETn = 1;
        ahb_vif_m2.HRESETn = 1;
    end

    // ── GPIO + Timer signals (for observation) ───────────────────────────────
    logic [7:0] GPIO_IN  = 8'b0;
    wire  [7:0] GPIO_OUT;
    wire        TIMER_IRQ;

    // ── DUT instantiation ────────────────────────────────────────────────────
    dut_top #(.ARBITER_MODE(ARBITER_MODE)) dut (
        // Global
        .HCLK       (HCLK),
        .HRESETn    (ahb_vif_m1.HRESETn),
        
        // AHB Master 1 (driven by UVM driver via ahb_vif_m1)
        .HBUSREQ1   (ahb_vif_m1.HBUSREQ),
        .HADDR1     (ahb_vif_m1.HADDR),
        .HWDATA1    (ahb_vif_m1.HWDATA),
        .HWRITE1    (ahb_vif_m1.HWRITE),
        .HTRANS1    (ahb_vif_m1.HTRANS),
        .HSIZE1     (ahb_vif_m1.HSIZE),
        .HBURST1    (ahb_vif_m1.HBURST),
        .HGRANT1    (ahb_vif_m1.HGRANT),
        .HRDATA1    (ahb_vif_m1.HRDATA),
        .HREADY1    (ahb_vif_m1.HREADY),
        .HRESP1     (ahb_vif_m1.HRESP),
        
        // AHB Master 2 (driven by UVM driver via ahb_vif_m2)
        .HBUSREQ2   (ahb_vif_m2.HBUSREQ),
        .HADDR2     (ahb_vif_m2.HADDR),
        .HWDATA2    (ahb_vif_m2.HWDATA),
        .HWRITE2    (ahb_vif_m2.HWRITE),
        .HTRANS2    (ahb_vif_m2.HTRANS),
        .HSIZE2     (ahb_vif_m2.HSIZE),
        .HBURST2    (ahb_vif_m2.HBURST),
        .HGRANT2    (ahb_vif_m2.HGRANT),
        .HRDATA2    (ahb_vif_m2.HRDATA),
        .HREADY2    (ahb_vif_m2.HREADY),
        .HRESP2     (ahb_vif_m2.HRESP),
        
        // GPIO
        .GPIO_IN    (GPIO_IN),
        .GPIO_OUT   (GPIO_OUT),
        
        // Timer
        .TIMER_IRQ  (TIMER_IRQ)
    );

    // ── Connect APB interface ────────────────────────────────────────────────
    // APB bus signals (output từ bridge) — accessed via hierarchical reference
    assign apb_vif.PADDR   = dut.PADDR;
    assign apb_vif.PWDATA  = dut.PWDATA;
    assign apb_vif.PWRITE  = dut.PWRITE;
    assign apb_vif.PENABLE = dut.PENABLE;
    
    // Slave select signals
    assign apb_vif.PSEL1   = dut.PSEL1;
    assign apb_vif.PSEL2   = dut.PSEL2;
    assign apb_vif.PSEL3   = dut.PSEL3;
    
    // Response signals (separated per slave)
    assign apb_vif.PRDATA1  = dut.PRDATA1;
    assign apb_vif.PRDATA2  = dut.PRDATA2;
    assign apb_vif.PRDATA3  = dut.PRDATA3;
    assign apb_vif.PREADY1  = dut.PREADY1;
    assign apb_vif.PREADY2  = dut.PREADY2;
    assign apb_vif.PREADY3  = dut.PREADY3;
    assign apb_vif.PSLVERR1 = dut.PSLVERR1;
    assign apb_vif.PSLVERR2 = dut.PSLVERR2;
    assign apb_vif.PSLVERR3 = dut.PSLVERR3;
    
    // Peripheral signals
    assign apb_vif.GPIO_OUT = GPIO_OUT;
    assign apb_vif.TIMER_IRQ = TIMER_IRQ;

    // ── Config DB setup ─────────────────────────────────────────────────────
    initial begin
        uvm_config_db#(virtual ahb_if)::set(null, "*", "ahb_vif", ahb_vif_m1);
        uvm_config_db#(virtual ahb_if)::set(null, "*", "ahb_vif_m1", ahb_vif_m1);
        uvm_config_db#(virtual ahb_if)::set(null, "*", "ahb_vif_m2", ahb_vif_m2);
        uvm_config_db#(virtual apb_if)::set(null, "*", "apb_vif", apb_vif);

        run_test();
    end

endmodule : tb_top