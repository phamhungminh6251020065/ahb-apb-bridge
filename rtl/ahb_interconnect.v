//==============================================================================
// File    : ahb_interconnect.v
// Author  : Pham Hung Minh
// Project : AHB-to-APB Bridge
// Date    : 08/04/2026
//------------------------------------------------------------------------------
// Description:
//     AHB Interconnect kết nối nhiều AHB Master tới một AHB Slave (Bridge).
//
//     Module bao gồm các thành phần chính:
//     1. Arbiter:
//        - Nhận tín hiệu yêu cầu bus (HBUSREQ) từ các Master
//        - Sử dụng module ahb_arbiter để cấp quyền truy cập bus (HGRANT1/HGRANT2)
//        - Việc chuyển quyền chỉ xảy ra khi HREADY = 1 (đúng theo AHB spec)
//
//     2. Address & Control Mux:
//        - Chọn các tín hiệu điều khiển (HADDR, HWRITE, HTRANS, ...)
//          từ Master được cấp quyền (dựa trên HGRANT)
//
//     3. Write Data Mux:
//        - Chọn HWDATA từ Master được cấp quyền để truyền tới Slave
//
//     4. Response Path (Broadcast):
//        - Các tín hiệu phản hồi từ Slave (HRDATA, HREADY, HRESP)
//          được broadcast tới tất cả Master
//        - Master được cấp quyền sẽ sử dụng dữ liệu, các Master khác sẽ bỏ qua
//
//     5. HSEL Generation:
//        - HSEL được tạo dựa trên HTRANS (HTRANS != IDLE)
//        - Không thực hiện decode địa chỉ tại Interconnect
//        - Việc decode địa chỉ được thực hiện trong Bridge
//==============================================================================

module ahb_interconnect (
    // Global AHB signals
    input wire HCLK,           // clock của AHB
    input wire HRESETn,        // reset (active low)

    // Input từ Slave (Bridge)
    input wire HREADY,         // tín hiệu sẵn sàng của AHB
    input wire [31:0] HRDATA,  // dữ liệu đọc từ bus AHB
    input wire [1:0] HRESP,    // tín hiệu phản hồi từ bus AHB (00: OKAY, 01: ERROR, 10: RETRY, 11: SPLIT)

    // Master 1 I/O
    input wire HBUSREQ1,         // yêu cầu bus từ master 1
    input wire [31:0] HADDR1,   // địa chỉ từ master 1
    input wire [31:0] HWDATA1,  // dữ liệu ghi từ master 1
    input wire        HWRITE1,  // tín hiệu chỉ thị đọc/ghi từ master 1 (1: ghi, 0: đọc)
    input wire [1:0]  HTRANS1,  // tín hiệu loại giao dịch từ master 1 (IDLE=00, BUSY=01, NONSEQ=10, SEQ=11)
    input wire [2:0]  HSIZE1,   // tín hiệu kích thước giao dịch từ master 1 (000=8-bit, 001=16-bit, 010=32-bit)
    input wire [2:0]  HBURST1,  // tín hiệu burst type từ master 1  (000=single, 001=INCR, 010=WRAP4, 011=INCR4, 100=WRAP8, 101=INCR8, 110=WRAP16, 111=INCR16)
    output wire HGRANT1,        // cấp quyền bus cho master 1

    // Master 2 I/O
    input wire HBUSREQ2,         // yêu cầu bus từ master 2
    input wire [31:0] HADDR2,   // địa chỉ từ master 2
    input wire [31:0] HWDATA2,  // dữ liệu ghi từ master 2
    input wire        HWRITE2,  // tín hiệu chỉ thị đọc/ghi từ master 2 (1: ghi, 0: đọc)
    input wire [1:0]  HTRANS2,  // tín hiệu loại giao dịch từ master 2 (IDLE=00, BUSY=01, NONSEQ=10, SEQ=11)
    input wire [2:0]  HSIZE2,   // tín hiệu kích thước giao dịch từ master 2 (000=8-bit, 001=16-bit, 010=32-bit)
    input wire [2:0]  HBURST2,  // tín hiệu burst type từ master 2  (000=single, 001=INCR, 010=WRAP4, 011=INCR4, 100=WRAP8, 101=INCR8, 110=WRAP16, 111=INCR16)
    output wire HGRANT2,        // cấp quyền bus cho master 2

    // Output về Master 1 và 2
    output wire        HREADY1,  // broadcast HREADYout về Master 1
    output wire [31:0] HRDATA1,  // broadcast HRDATA về Master 1
    output wire [1:0]  HRESP1,   // broadcast HRESP về Master 1

    output wire        HREADY2,  // broadcast HREADYout về Master 2
    output wire [31:0] HRDATA2,  // broadcast HRDATA về Master 2
    output wire [1:0]  HRESP2,   // broadcast HRESP về Master 2
    
    // Output tới AHB bus (kết nối tới Bridge)
    output wire HWRITE,         // tín hiệu chỉ thị đọc/ghi từ master (1: ghi, 0: đọc)
    output wire [1:0] HTRANS,   // tín hiệu loại giao dịch từ master (IDLE=00, BUSY=01, NONSEQ=10, SEQ=11)
    output wire [2:0] HSIZE,    // tín hiệu kích thước giao dịch từ master (000=8-bit, 001=16-bit, 010=32-bit)
    output wire [2:0] HBURST,   // tín hiệu burst type từ master  (000=single, 001=INCR, 010=WRAP4, 011=INCR4, 100=WRAP8, 101=INCR8, 110=WRAP16, 111=INCR16)
    output wire [31:0] HADDR,   // địa chỉ từ master được grant sau khi mux
    output wire [31:0] HWDATA,  // dữ liệu ghi từ master được grant sau khi mux
    output wire        HSEL    // tín hiệu chọn slave (dựa trên HTRANS != IDLE)
);
    // Instance của AHB arbiter
    ahb_arbiter #(
        .MODE(1) // 0: Fixed Priority, 1: Round Robin
    ) arbiter_inst (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HREADY(HREADY),
        .HBUSREQ1(HBUSREQ1),
        .HBUSREQ2(HBUSREQ2),
        .HGRANT1(HGRANT1),
        .HGRANT2(HGRANT2)
    );
    // Các mux để chọn tín hiệu từ master được grant
    // Address & Control Mux
    assign HADDR = HGRANT1 ? HADDR1 : HADDR2;
    assign HWRITE = HGRANT1 ? HWRITE1 : HWRITE2;
    assign HTRANS = HGRANT1 ? HTRANS1 : HTRANS2;
    assign HSIZE = HGRANT1 ? HSIZE1 : HSIZE2;
    assign HBURST = HGRANT1 ? HBURST1 : HBURST2;
    // Write Data Mux
    assign HWDATA = HGRANT1 ? HWDATA1 : HWDATA2;
    // Nhìn vào bit 1 của HTRANS để tạo tín hiệu HSEL (chọn slave)
    assign HSEL = HTRANS[1];
    // assign HSEL = 1'b1;
    // Broadcast tín hiệu phản hồi từ Slave về Master
    assign HREADY1 = HREADY;
    assign HRDATA1 = HRDATA;
    assign HRESP1 = HRESP;
    assign HREADY2 = HREADY;
    assign HRDATA2 = HRDATA;
    assign HRESP2 = HRESP;
endmodule : ahb_interconnect