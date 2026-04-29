//==============================================================================
// File    : bridge_top.v
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 27/03/2026
//------------------------------------------------------------------------------
// Description:
//   Top-level module của AHB-to-APB Bridge, tích hợp tất cả các khối chức năng chính:
//   - bridge_addr_decoder.v - Address Decoder: Giải mã địa chỉ AHB để chọn slave APB.
//   - bridge_fsm.v - FSM (Finite State Machine): Điều khiển quá trình chuyển đổi giữa các trạng thái giao dịch.
//   - bridge_prdata_mux.v - PRDATA Mux: Chọn dữ liệu trả về từ slave APB được chọn để đưa về AHB Master.
//   - Kết nối tín hiệu giữa AHB Master và các slave APB thông qua các khối chức năng trên.
//==============================================================================

module bridge_top (
    // Tín hiệu input từ AHB Master
    input wire HCLK,          // Clock từ AHB
    input wire HRESETn,       // Reset (active low) từ AHB
    input wire [31:0] HADDR,  // Địa chỉ từ AHB Master
    input wire HWRITE,        // Tín hiệu chỉ thị đọc/ghi từ AHB (1: ghi, 0: đọc)
    input wire [1:0] HTRANS,  // Tín hiệu loại giao dịch từ AHB Master (IDLE=00, BUSY=01, NONSEQ=10, SEQ=11)
    input wire [2:0] HSIZE,   // Tín hiệu kích thước giao dịch từ AHB Master (000=8-bit, 001=16-bit, 010=32-bit)
    input wire [31:0] HWDATA, // Dữ liệu ghi từ AHB Master
    input wire HREADYin,      // Tín hiệu sẵn sàng từ AHB Master (cho phép bắt đầu giao dịch mới)
    input wire HSEL,          // Tín hiệu chọn Bridge từ AHB Master
    input wire [2:0] HBURST,
    
    // Tín hiệu input từ các slave APB
    input wire [31:0] PRDATA1, // Dữ liệu trả về từ slave APB 1 (GPIO Controller)
    input wire [31:0] PRDATA2, // Dữ liệu trả về từ slave APB 2 (Timer)
    input wire [31:0] PRDATA3, // Dữ liệu trả về từ slave APB 3 (Register File)
    input wire PREADY1, // Tín hiệu sẵn sàng từ slave APB 1
    input wire PREADY2, // Tín hiệu sẵn sàng từ slave APB 2
    input wire PREADY3, // Tín hiệu sẵn sàng từ slave APB 3
    input wire PSLVERR1, // Tín hiệu lỗi từ slave APB 1
    input wire PSLVERR2, // Tín hiệu lỗi từ slave APB 2
    input wire PSLVERR3, // Tín hiệu lỗi từ slave APB 3

    // Tín hiệu output trả về cho AHB Master
    output wire [31:0] HRDATA, // Dữ liệu đọc trả về cho AHB Master
    output wire HREADYout,     // Tín hiệu sẵn sàng trả về cho AHB Master
    output wire [1:0] HRESP,     // Tín hiệu lỗi trả về cho AHB Master (00 - OKAY, 01 - ERROR, 10 - RETRY, 11 - SPLIT)

    // Tín hiệu output cho các slave APB
    output wire PSEL1, // Chọn slave APB 1 (GPIO Controller)
    output wire PSEL2, // Chọn slave APB 2 (Timer)
    output wire PSEL3, // Chọn slave APB 3 (Register File)
    output wire PENABLE, // Tín hiệu enable cho APB
    output wire PWRITE, // Tín hiệu chỉ thị đọc/ghi cho APB
    output wire [31:0] PADDR, // Địa chỉ cho APB (được giải mã từ HADDR)
    output wire [31:0] PWDATA // Dữ liệu ghi cho APB (được lấy từ HWDATA)
);
    // Tín hiệu nội bộ để kết nối giữa các khối chức năng
    reg HwriteReg; // Thanh ghi lưu HWRITE của chu kỳ trước, dùng để hỗ trợ pipelined write
    wire Valid;     // Tín hiệu chỉ thị giao dịch hợp lệ từ AHB (Valid = HTRANS[1])
    wire PREADY_sel; // Tín hiệu sẵn sàng được chọn từ các slave APB (được điều khiển bởi FSM)
    wire addr_valid; // Tín hiệu chỉ thị địa chỉ hợp lệ (được tạo ra từ Address Decoder hoặc FSM)
    wire [2:0] current_state; // Current state from FSM

    // FSM state parameters
    parameter ST_IDLE     = 3'b000;
    parameter ST_READ     = 3'b001;
    parameter ST_WWAIT    = 3'b010;
    parameter ST_WRITE    = 3'b011;
    parameter ST_WRITEP   = 3'b100;
    parameter ST_RENABLE  = 3'b101;
    parameter ST_WENABLE  = 3'b110;
    parameter ST_WENABLEP = 3'b111;

    assign addr_valid =  (HADDR[31:16] == 16'h4000) || (HADDR[31:16] == 16'h4001) || (HADDR[31:16] == 16'h4002); // Địa chỉ hợp lệ khi thuộc phạm vi của 3 slave APB
    assign PREADY_sel = (PSEL1 && PREADY1) || (PSEL2 && PREADY2) || (PSEL3 && PREADY3); // Tín hiệu sẵn sàng được chọn từ các slave APB
    // Tạo tín hiệu Valid từ HTRANS
    assign Valid =  HSEL && HREADYin && HTRANS[1] && addr_valid; // Giao dịch hợp lệ khi HSEL=1, HREADYin=1 và HTRANS là NONSEQ hoặc SEQ
    // Tạo tín hiệu HwriteReg để lưu giá trị HWRITE của chu kỳ trước
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HwriteReg <= 1'b0; // Reset giá trị HwriteReg về 0 khi reset
        end else if (HREADYin) begin
            HwriteReg <= HWRITE; // Latch HWRITE mỗi cycle khi bus sẵn sàng (HREADYin=1)
        end
    end

    // Address phase register
    reg [31:0] HADDR_reg; // Thanh ghi lưu địa chỉ HADDR của chu kỳ trước để sử dụng trong APB SETUP phase

    always @(posedge HCLK or negedge HRESETn) begin
        if(!HRESETn) begin
            HADDR_reg <= 32'b0; // Reset địa chỉ về 0 khi reset
            // HWDATA_reg <= 32'b0; // Reset dữ liệu ghi về 0 khi reset
        end else if (Valid) begin
            HADDR_reg <= HADDR; // Cập nhật HADDR_reg với giá trị HADDR của chu kỳ hiện tại khi giao dịch hợp lệ
            // HWDATA_reg <= HWDATA; // Cập nhật HWDATA_reg với giá trị HWDATA của chu kỳ hiện tại khi giao dịch hợp lệ
        end
    end
    // APB Control
    assign PWRITE = HwriteReg; // Sử dụng HwriteReg làm tín hiệu chỉ thị đọc/ghi cho APB
    assign PADDR = HADDR_reg; // Sử dụng HADDR_reg làm địa chỉ
    assign PWDATA = HWDATA; // Use HWDATA directly
    // Instance các khối chức năng
    // Address Decoder
    bridge_addr_decoder addr_decoder (
        .HADDR(HADDR_reg), // Sử dụng địa chỉ đã được lưu trong thanh ghi để giải mã
        .PSEL1(PSEL1),
        .PSEL2(PSEL2),
        .PSEL3(PSEL3)
    );
    // FSM
    bridge_fsm fsm (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HWRITE(HWRITE),
        .HwriteReg(HwriteReg),
        .Valid(Valid),
        .PREADY(PREADY_sel), // Kết nối tín hiệu sẵn sàng được chọn từ các slave APB
        .PENABLE(PENABLE),
        .HREADYout(HREADYout),
        .current_state(current_state)
    );
    // PRDATA Mux
    bridge_prdata_mux prdata_mux (
        .PSEL1(PSEL1),
        .PSEL2(PSEL2),
        .PSEL3(PSEL3),
        .PRDATA1(PRDATA1),
        .PRDATA2(PRDATA2),
        .PRDATA3(PRDATA3),
        .PSLVERR1(PSLVERR1),
        .PSLVERR2(PSLVERR2),
        .PSLVERR3(PSLVERR3),
        .HRDATA(HRDATA),
        .HRESP(HRESP)
    );
endmodule : bridge_top