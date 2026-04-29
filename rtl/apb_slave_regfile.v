//==============================================================================
// File    : apb_slave_regfile.v
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 18/03/2026
//------------------------------------------------------------------------------
// Description:
//   APB Slave - Register File
//   - Chứa 8 thanh ghi 32-bit, hỗ trợ truy cập đọc/ghi qua giao thức APB.
//   - Hoạt động ở chế độ "No Wait State" (PREADY luôn bằng 1).
//   - Cơ chế địa chỉ: Word-aligned (Căn chỉnh theo từ 32-bit).
//------------------------------------------------------------------------------
// Address Map (Ánh xạ địa chỉ):
//   Do mỗi thanh ghi rộng 32-bit (4 byte), ta sử dụng PADDR[4:2] để chọn:
//   PADDR[31:0] = 32'h0000_0000 (Bit [4:2]=000) -> mem[0] (Register 0)
//   PADDR[31:0] = 32'h0000_0004 (Bit [4:2]=001) -> mem[1] (Register 1)
//   PADDR[31:0] = 32'h0000_0008 (Bit [4:2]=010) -> mem[2] (Register 2)
//   PADDR[31:0] = 32'h0000_000C (Bit [4:2]=011) -> mem[3] (Register 3)
//   PADDR[31:0] = 32'h0000_0010 (Bit [4:2]=100) -> mem[4] (Register 4)
//   PADDR[31:0] = 32'h0000_0014 (Bit [4:2]=101) -> mem[5] (Register 5)
//   PADDR[31:0] = 32'h0000_0018 (Bit [4:2]=110) -> mem[6] (Register 6)
//   PADDR[31:0] = 32'h0000_001C (Bit [4:2]=111) -> mem[7] (Register 7)
//==============================================================================
module apb_slave_regfile (
    input wire PCLK,           // tín hiệu xung clock của APB
    input wire PRESETn,        // tín hiệu reset (active low)
    input wire PSEL,           // tín hiệu chọn slave
    input wire PENABLE,        // tín hiệu enable
    input wire PWRITE,         // tín hiệu chỉ thị đọc/ghi (1: ghi, 0: đọc)
    input wire [31:0] PADDR,   // địa chỉ register (chỉ sử dụng 3 bit [4:2] để chọn 1 trong 8 register)
    input wire [31:0] PWDATA,  // dữ liệu ghi vào register
    output reg [31:0] PRDATA,  // dữ liệu đọc từ register
    output wire PREADY,        // tín hiệu sẵn sàng (luôn trả về 1)
    output wire PSLVERR        // tín hiệu lỗi
);

    // Định nghĩa 8 register 32bit
    reg [31:0] mem [7:0];
    wire addr_valid;

    // Luôn trả về 1 cho PREADY và 0 cho PSLVERR
    assign PREADY = 1'b1;
    // assign PSLVERR = 1'b0;
    assign addr_valid = (PADDR[15:0] <= 16'h001C); // Địa chỉ hợp lệ khi PADDR[11:0] là 0x000, 0x004, ..., 0x01C
    // assign addr_valid = (PADDR[1:0] == 2'b00) && (PADDR[4:2] <= 3'b111);
    // ── Write logic (sequential) ─────────────────────────────────────────────
    // Ghi vào mem khi PSEL=1, PENABLE=1, PWRITE=1 (ACCESS phase của write)
    integer i;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            for (i = 0; i < 8; i = i + 1)
                mem[i] <= 32'b0;
        end else if (PSEL && PENABLE && PWRITE && addr_valid) begin
            mem[PADDR[4:2]] <= PWDATA; // Ghi dữ liệu vào register được chọn bởi PADDR[4:2]
        end
    end

    // ── Read logic (combinational) ───────────────────────────────────────────
    // Drive PRDATA ngay khi PSEL=1, PENABLE=1, PWRITE=0
    always @(*) begin
        PRDATA = 32'b0; // Default
        // if (PSEL && PENABLE && !PWRITE && addr_valid) begin
        if (!PWRITE && addr_valid) begin
            PRDATA = mem[PADDR[4:2]];
        end
    end
    assign PSLVERR = (PSEL && PENABLE && !addr_valid);
endmodule : apb_slave_regfile