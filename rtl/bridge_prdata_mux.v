//==============================================================================
// File    : bridge_prdata_mux.v
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 25/03/2026
//------------------------------------------------------------------------------
// Description: Khối PRDATA Mux cho AHB-to-APB Bridge
// - Chức năng: Chọn dữ liệu trả về từ slave APB được chọn để đưa về AHB Master.
// - Cơ chế hoạt động:
//   + Sử dụng tín hiệu PSELx từ Address Decoder để xác định slave APB đang active
//   + Chọn dữ liệu PRDATA và tín hiệu lỗi PSLVERR tương ứng
//   + Đưa về HRDATA và HRESP cho AHB Master
//
//   + Lưu ý:
//     * Tín hiệu HREADYout được điều khiển bởi FSM, không nằm trong module này
//==============================================================================

module bridge_prdata_mux (
    input wire PSEL1, // Chọn slave APB 1 (GPIO Controller)
    input wire PSEL2, // Chọn slave APB 2 (Timer)
    input wire PSEL3, // Chọn slave APB 3 (Register File)
    input wire [31:0] PRDATA1, // Dữ liệu trả về từ slave APB 1
    input wire [31:0] PRDATA2, // Dữ liệu trả về từ slave APB 2
    input wire [31:0] PRDATA3, // Dữ liệu trả về từ slave APB 3
    // input wire PREADY1, // Tín hiệu sẵn sàng từ slave APB
    // input wire PREADY2, // Tín hiệu sẵn sàng từ slave APB
    // input wire PREADY3, // Tín hiệu sẵn sàng từ slave APB
    input wire PSLVERR1, // Tín hiệu lỗi từ slave APB
    input wire PSLVERR2, // Tín hiệu lỗi từ slave APB
    input wire PSLVERR3, // Tín hiệu lỗi từ slave APB
    output reg [31:0] HRDATA, // Dữ liệu trả về cho AHB Master
    // output reg HREADYout, // Tín hiệu sẵn sàng Bridge trả về cho AHB Master transfer hoàn thành
    output reg [1:0] HRESP // Tín hiệu lỗi cho AHB Master
    // HRESP: 00 - OKAY, 01 - ERROR, 10 - RETRY, 11 - SPLIT
);
    always @(*) begin
        // Mặc định không chọn dữ liệu nào
        HRDATA = 32'b0;
        // HREADYout = 1'b0;
        HRESP = 2'b00; // Không lỗi
        // Chọn dữ liệu từ slave APB được chọn
        if (PSEL1) begin
            HRDATA = PRDATA1; // Dữ liệu từ GPIO Controller
            // HREADYout = PREADY1; // Tín hiệu sẵn sàng từ GPIO Controller
            HRESP = PSLVERR1 ? 2'b01 : 2'b00; // Lỗi nếu PSLVERR1 = 1
        end else if (PSEL2) begin
            HRDATA = PRDATA2; // Dữ liệu từ Timer
            // HREADYout = PREADY2; // Tín hiệu sẵn sàng từ Timer
            HRESP = PSLVERR2 ? 2'b01 : 2'b00; // Lỗi nếu PSLVERR2 = 1
        end else if (PSEL3) begin
            HRDATA = PRDATA3; // Dữ liệu từ Register File
            // HREADYout = PREADY3; // Tín hiệu sẵn sàng từ Register File
            HRESP = PSLVERR3 ? 2'b01 : 2'b00; // Lỗi nếu PSLVERR3 = 1
        end else begin
            HRDATA = 32'b0;
            HRESP = 2'b00;
        end
    end
endmodule : bridge_prdata_mux