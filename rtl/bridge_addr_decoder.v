//==============================================================================
// File    : bridge_addr_decoder.v
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 25/03/2026
//------------------------------------------------------------------------------
// Description: Khối Address Decoder cho AHB-to-APB Bridge
// - Chức năng: Giải mã địa chỉ AHB để xác định slave APB nào được chọn.
// - Cơ chế giải mã: Sử dụng 16 bit cao nhất của địa chỉ AHB (HADDR[31:16]) để chọn 1 trong 3 slave APB.
// - Địa chỉ được chia thành 3 vùng, mỗi vùng tương ứng với một slave APB:
//   + 0x4000_0000 đến 0x4000_FFFF -> PSEL1 (GPIO Controller)
//   + 0x4001_0000 đến 0x4001_FFFF -> PSEL2 (Timer)
//   + 0x4002_0000 đến 0x4002_FFFF -> PSEL3 (Register File)
//==============================================================================

module bridge_addr_decoder (
    input wire [31:0] HADDR,   // Địa chỉ từ AHB Master
    output reg PSEL1,                 // Chọn slave APB 1 (GPIO Controller)
    output reg PSEL2,                 // Chọn slave APB 2 (Timer)
    output reg PSEL3                  // Chọn slave APB 3 (Register File)
);
    // Giải mã địa chỉ AHB để xác định slave APB nào được chọn
    always @(*) begin
        // Mặc định không chọn slave nào
        PSEL1 = 1'b0;
        PSEL2 = 1'b0;
        PSEL3 = 1'b0;

        // Sử dụng 16 bit cao nhất của HADDR để giải mã
        case (HADDR[31:16])
            16'h4000: PSEL1 = 1'b1; // Chọn GPIO Controller
            16'h4001: PSEL2 = 1'b1; // Chọn Timer
            16'h4002: PSEL3 = 1'b1; // Chọn Register File
            default: begin
                PSEL1 = 1'b0;
                PSEL2 = 1'b0;
                PSEL3 = 1'b0; // Không chọn slave nào nếu địa chỉ không hợp lệ
            end
        endcase
    end
endmodule : bridge_addr_decoder