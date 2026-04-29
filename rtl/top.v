//==============================================================================
// File    : top.v
// Author  : Pham Hung Minh
// Project : AHB-to-APB Bridge
// Date    : 08/04/2026
//------------------------------------------------------------------------------
// Description:
//     Top module kết nối tất cả các thành phần lại với nhau:
//     - 2 AHB Master (ahb_master)
//     - AHB Interconnect (ahb_interconnect)
//     - AHB-to-APB Bridge (bridge_top)
//     - APB Slave GPIO (apb_slave_gpio)
//     - APB Slave Timer (apb_slave_timer)
//     - APB Slave Regfile (apb_slave_regfile)
//==============================================================================
`timescale 1ns/1ps
module top;
    // 1. Clock và Reset
    reg HCLK;
    reg HRESETn;

    initial begin
        HCLK = 0;
        forever #5 HCLK = ~HCLK; // clock 100MHz
    end
    initial begin
        HRESETn = 0;
        #20 HRESETn = 1; // deassert reset sau 20ns
    end

    // 2. Tín hiệu kết nối giữa các module
    // Tín hiệu từ Master 1
    wire HBUSREQ1;
    wire [31:0] HADDR1;
    wire [31:0] HWDATA1;
    wire HWRITE1;
    wire [1:0] HTRANS1;
    wire [2:0] HSIZE1;
    wire [2:0] HBURST1;

    wire HGRANT1;
    wire [31:0] HRDATA1;
    wire HREADY1;
    wire [1:0] HRESP1;

    wire start_req1;
    wire write_in1;
    wire [31:0] addr_in1;
    wire [31:0] wdata_in1;
    wire        more_seq1;
    wire         done1;
    wire [31:0]  rdata_out1;

    // Tín hiệu từ Master 2
    wire HBUSREQ2;
    wire [31:0] HADDR2;
    wire [31:0] HWDATA2;
    wire HWRITE2;
    wire [1:0] HTRANS2;
    wire [2:0] HSIZE2;
    wire [2:0] HBURST2;

    wire HGRANT2;
    wire [31:0] HRDATA2;
    wire HREADY2;
    wire [1:0] HRESP2;

    wire start_req2;
    wire write_in2;
    wire [31:0] addr_in2;
    wire [31:0] wdata_in2;
    wire        more_seq2;
    wire         done2;
    wire [31:0]  rdata_out2;

    // Tín hiệu từ Interconnect <-> Bridge
    wire [31:0] HADDR;
    wire [31:0] HWDATA;
    wire HWRITE;
    wire [1:0] HTRANS;
    wire [2:0] HSIZE;
    wire [2:0] HBURST;
    wire HSEL;
    wire HREADYin;

    wire HREADYout;
    wire [31:0] HRDATA;
    wire [1:0] HRESP;

    // Tín hiệu từ Bridge <-> APB
    wire [31:0] PADDR;
    wire [31:0] PWDATA;
    wire PWRITE;
    wire PENABLE;

    wire PSEL1;
    wire PSEL2;
    wire PSEL3;

    wire [31:0] PRDATA1;
    wire [31:0] PRDATA2;
    wire [31:0] PRDATA3;
    wire PREADY1;
    wire PREADY2;
    wire PREADY3;
    wire PSLVERR1;
    wire PSLVERR2;
    wire PSLVERR3;
    wire TIMER_IRQ; // Tín hiệu ngắt của APB Slave 2: Timer
    wire [7:0] GPIO_IN; // Tín hiệu i/o của APB Slave 1: GPIO
    wire [7:0] GPIO_OUT; // Tín hiệu i/o của APB Slave 1: GPIO
    
    // HREADYin = HREADYout (feedback, nhưng đi qua 1 wire riêng)
    assign HREADYin = HREADYout;
    assign GPIO_IN = 8'b0;
    // 3. Instantiate module
    // AHB Master 1
    ahb_master #(
        .MASTER_ID(0)
    ) master1_dut (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HREADY(HREADY1),
        .HGRANT(HGRANT1),
        .HBUSREQ(HBUSREQ1),
        .HADDR(HADDR1),
        .HWDATA(HWDATA1),
        .HWRITE(HWRITE1),
        .HTRANS(HTRANS1),
        .HSIZE(HSIZE1),
        .HBURST(HBURST1),
        .HRDATA(HRDATA1),
        .HRESP(HRESP1),
        .start_req(start_req1),
        .write_in(write_in1),
        .addr_in(addr_in1),
        .wdata_in(wdata_in1),
        .more_seq(more_seq1),
        .done(done1),
        .rdata_out(rdata_out1)
    );
    // AHB Master 2
    ahb_master #(
        .MASTER_ID(1)
    ) master2_dut (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HREADY(HREADY2),
        .HGRANT(HGRANT2),
        .HBUSREQ(HBUSREQ2),
        .HADDR(HADDR2),
        .HWDATA(HWDATA2),
        .HWRITE(HWRITE2),
        .HTRANS(HTRANS2),
        .HSIZE(HSIZE2),
        .HBURST(HBURST2),
        .HRDATA(HRDATA2),
        .HRESP(HRESP2),
        .start_req(start_req2),
        .write_in(write_in2),
        .addr_in(addr_in2),
        .wdata_in(wdata_in2),
        .more_seq(more_seq2),
        .done(done2),
        .rdata_out(rdata_out2)
    );
    // AHB Interconnect
    ahb_interconnect interconnect_dut(
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HREADY(HREADYout),
        .HRDATA(HRDATA),
        .HRESP(HRESP),
        // Master 1
        .HBUSREQ1(HBUSREQ1),
        .HADDR1(HADDR1),
        .HWDATA1(HWDATA1),
        .HWRITE1(HWRITE1),
        .HTRANS1(HTRANS1),
        .HSIZE1(HSIZE1),
        .HBURST1(HBURST1),
        .HGRANT1(HGRANT1),
        .HREADY1(HREADY1),
        .HRDATA1(HRDATA1),
        .HRESP1(HRESP1),
        // Master 2
        .HBUSREQ2(HBUSREQ2),
        .HADDR2(HADDR2),
        .HWDATA2(HWDATA2),
        .HWRITE2(HWRITE2),
        .HTRANS2(HTRANS2),
        .HSIZE2(HSIZE2),
        .HBURST2(HBURST2),
        .HGRANT2(HGRANT2),
        .HREADY2(HREADY2),
        .HRDATA2(HRDATA2),
        .HRESP2(HRESP2),
        // Kết nối tới Bridge
        .HWRITE(HWRITE),
        .HTRANS(HTRANS),
        .HSIZE(HSIZE),
        .HBURST(HBURST),
        .HADDR(HADDR),
        .HWDATA(HWDATA),
        .HSEL(HSEL)
    );
    // Bridge
    bridge_top bridge_dut(
        // Tín hiệu input AHB Master
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR),
        .HWRITE(HWRITE),
        .HTRANS(HTRANS),
        .HSIZE(HSIZE),
        .HWDATA(HWDATA),
        .HREADYin(HREADYin),
        .HSEL(HSEL),
        .HBURST(HBURST),
        // Tín hiệu input APB Slave
        .PRDATA1(PRDATA1),
        .PRDATA2(PRDATA2),
        .PRDATA3(PRDATA3),
        .PREADY1(PREADY1),
        .PREADY2(PREADY2),
        .PREADY3(PREADY3),
        .PSLVERR1(PSLVERR1),
        .PSLVERR2(PSLVERR2),
        .PSLVERR3(PSLVERR3),
        // Tín hiệu output AHB Master
        .HRDATA(HRDATA),
        .HREADYout(HREADYout),
        .HRESP(HRESP),
        // Tín hiệu output APB Slave
        .PSEL1(PSEL1),
        .PSEL2(PSEL2),
        .PSEL3(PSEL3),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA)
    );
    // APB Slave 1: GPIO
    apb_slave_gpio slave1_gpio_dut(
        .PCLK(HCLK),
        .PRESETn(HRESETn),
        .PSEL(PSEL1),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA1),
        .PREADY(PREADY1),
        .PSLVERR(PSLVERR1),
        .GPIO_IN(GPIO_IN),
        .GPIO_OUT(GPIO_OUT)
    );
    // APB Slave 2: Timer
    apb_slave_timer slave2_timer_dut(
        .PCLK(HCLK),
        .PRESETn(HRESETn),
        .PSEL(PSEL2),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA2),
        .PREADY(PREADY2),
        .PSLVERR(PSLVERR2),
        .TIMER_IRQ(TIMER_IRQ)
    );
    // APB Slave 3: Regfile
    apb_slave_regfile slave3_regfile_dut(
        .PCLK(HCLK),
        .PRESETn(HRESETn),
        .PSEL(PSEL3),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA3),
        .PREADY(PREADY3),
        .PSLVERR(PSLVERR3)
    );
endmodule : top