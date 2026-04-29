//==============================================================================
// File    : apb_slave_gpio.v
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 30/03/2026
//------------------------------------------------------------------------------
// Description:
//   APB Slave - GPIO
//
//   - Có 3 thanh ghi điều khiển:
//        Offset 0b0000 = 0h00 → DATA_REG [7:0] : dữ liệu GPIO
//        Offset 0b0100 = 0h04 → DIR_REG  [7:0] : 1=output, 0=input
//        Offset 0b1000 = 0h08 → IE_REG   [7:0] : interrupt enable (chưa dùng)
//
//   - Hoạt động No Wait State (PREADY = 1)
//
//   - Address decode dùng PADDR[3:2]:
//        00 → DATA
//        01 → DIR
//        10 → IE
//        11 → INVALID
//==============================================================================

module apb_slave_gpio (
    input wire PCLK,           // tín hiệu xung clock của APB
    input wire PRESETn,        // tín hiệu reset (active low)
    input wire PSEL,           // tín hiệu chọn slave
    input wire PENABLE,        // tín hiệu enable
    input wire PWRITE,         // tín hiệu chỉ thị đọc/ghi (1: ghi, 0: đọc)
    input wire [31:0] PADDR,   // địa chỉ register (dùng bit [3:2] để chọn 1 trong 3 register)
    input wire [31:0] PWDATA,  // dữ liệu ghi vào register
    output reg [31:0] PRDATA,  // dữ liệu đọc từ register
    output wire PREADY,        // tín hiệu sẵn sàng (luôn trả về 1)
    output wire PSLVERR,       // tín hiệu lỗi
    // GPIO pins
    input wire [7:0] GPIO_IN,
    output wire [7:0] GPIO_OUT
);
    // 3 thanh ghi nội bộ của APB Slave
    reg [7:0] data_reg; // thanh ghi đọc/ghi giá trị các chân GPIO
    reg [7:0] dir_reg;  // thanh ghi định hướng in/out của chần GPIO (1=output, 0=input)
    reg [7:0] ie_reg;   // thanh ghi bật/tắt chế độ ngắt
    wire addr_valid;    // địa chỉ hợp lệ của 3 thanh ghi trong range của APB Slave
    wire [7:0] gpio_read;

    // Cấu hình tín hiệu PREADY=1
    assign PREADY = 1'b1;
    // Cấu hình địa chỉ hợp lệ
    assign addr_valid = (PADDR[11:0] == 12'h000) ||
                        (PADDR[11:0] == 12'h004) ||
                        (PADDR[11:0] == 12'h008);
    // Cấu hình tín hiệu lỗi PSLVERR
    assign PSLVERR = (PSEL && PENABLE && !addr_valid);
    // GPIO output logic
    // Nếu dir = 1 → output data_reg
    // Nếu dir = 0 → output = 0
    assign GPIO_OUT = dir_reg & data_reg;

    // GPIO read logic
    // Nếu bit nào DIR=1, là output → đọc lại data_reg
    // Nếu bit nào DIR=0, là input  → đọc từ GPIO_IN
    assign gpio_read = (dir_reg & data_reg) | (~dir_reg & GPIO_IN);

    // Write logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            data_reg <= 8'b0;
            dir_reg  <= 8'b0;
            ie_reg   <= 8'b0;
        end else if (PSEL && PENABLE && PWRITE && addr_valid) begin
            case(PADDR[3:2])
                2'b00: data_reg <= PWDATA[7:0];
                2'b01: dir_reg <= PWDATA[7:0];
                2'b10: ie_reg <= PWDATA[7:0];
                default: ;
            endcase
        end
    end

    // Read logic
    always @(*) begin
        PRDATA = 32'b0; // Default
        // if (PSEL && PENABLE && !PWRITE && addr_valid) begin
        if (!PWRITE && addr_valid) begin
            case(PADDR[3:2])
                2'b00: PRDATA = {24'b0, gpio_read};
                2'b01: PRDATA = {24'b0, dir_reg};
                2'b10: PRDATA = {24'b0, ie_reg};
                default: PRDATA = 32'b0;
            endcase
        end
    end

endmodule : apb_slave_gpio

// !Bug: Vẫn Ghi/Đọc vào được địa chỉ khác 3 reg trong slave
// # ==================Scenario 5: Check write to invalid address==================
// # Time: 835 - Attempt to write data to invalid address 0x4000_0006: 000000ef
// # Time: 875 - Read data from invalid address 0x4000_0006 after write attempt: 000000ef
// # =======================All test done!=========================
// # ==================Scenario 5: Check write to invalid address==================
// # Time: 835 - Attempt to write data to invalid address 0x4000_0060: 000000ef
// # Time: 875 - Read data from invalid address 0x4000_0060 after write attempt: 000000ef
// # =======================All test done!=========================
