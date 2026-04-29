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

module tb_top;

    import uvm_pkg::*;
    import test_pkg::*;

    // ── Clock + Reset ────────────────────────────────────────────────────────
    logic HCLK;
    logic HRESETn;

    initial begin
        HCLK = 0;
        forever #5 HCLK = ~HCLK;
    end

    initial begin
        HRESETn = 0;
        #20 HRESETn = 1;
    end

    // ── Interface ────────────────────────────────────────────────────────────
    // AHB Master 1 interface (driven by UVM driver)
    ahb_if ahb_vif(.HCLK(HCLK), .HRESETn(HRESETn));
    
    // APB interface (observed by APB monitor)
    apb_if apb_vif(.PCLK(HCLK), .PRESETn(HRESETn));

    // ── GPIO + Timer signals (for observation) ───────────────────────────────
    logic [7:0]  GPIO_IN   = 8'b0;  // Test can drive GPIO inputs
    logic [7:0]  GPIO_OUT;
    logic        TIMER_IRQ;

    // ── DUT instantiation ────────────────────────────────────────────────────
    dut_top dut (
        // Global
        .HCLK       (HCLK),
        .HRESETn    (HRESETn),
        
        // AHB Master 1 (driven by UVM driver via ahb_vif)
        .HBUSREQ1   (ahb_vif.HBUSREQ),
        .HADDR1     (ahb_vif.HADDR),
        .HWDATA1    (ahb_vif.HWDATA),
        .HWRITE1    (ahb_vif.HWRITE),
        .HTRANS1    (ahb_vif.HTRANS),
        .HSIZE1     (ahb_vif.HSIZE),
        .HBURST1    (ahb_vif.HBURST),
        .HGRANT1    (ahb_vif.HGRANT),
        .HRDATA1    (ahb_vif.HRDATA),
        .HREADY1    (ahb_vif.HREADY),
        .HRESP1     (ahb_vif.HRESP),
        
        // AHB Master 2 (tied off for now — chỉ M1 active)
        .HBUSREQ2   (1'b0),
        .HADDR2     (32'b0),
        .HWDATA2    (32'b0),
        .HWRITE2    (1'b0),
        .HTRANS2    (2'b00),
        .HSIZE2     (3'b000),
        .HBURST2    (3'b000),
        .HGRANT2    (),
        .HRDATA2    (),
        .HREADY2    (),
        .HRESP2     (),
        
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
        uvm_config_db#(virtual ahb_if)::set(null, "*", "ahb_vif", ahb_vif);
        uvm_config_db#(virtual apb_if)::set(null, "*", "apb_vif", apb_vif);

        run_test();
    end

endmodule : tb_top