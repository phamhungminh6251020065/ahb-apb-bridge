//==============================================================================
// File    : apb_slave_timer.v
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 31/03/2026
//------------------------------------------------------------------------------
// Description:
//
// ### 1. Tổng quan
// APB Timer là một peripheral dạng bộ đếm (counter) 32-bit, kết nối với hệ thống
// thông qua bus APB. Module này cho phép tạo delay và sinh tín hiệu ngắt khi đạt
// đến một giá trị định trước.
//
// Timer hoạt động theo cơ chế đếm tăng (up-counter), được điều khiển bởi thanh ghi CTRL.
//
// -----------------------------------------------------------------------------
// ### 2. Register Map
//
// | Offset | Tên         | Bit    | Access | Reset       | Mô tả                  |
// |--------|-------------|--------|--------|-------------|------------------------|
// | 0x00   | CTRL_REG    | [0]    | R/W    | 0           | EN: 1=start, 0=stop    |
// | 0x04   | CNT_REG     | [31:0] | R      | 0           | Giá trị đếm hiện tại   |
// | 0x08   | PERIOD_REG  | [31:0] | R/W    | 0xFFFFFFFF  | Ngưỡng so sánh         |
//
// -----------------------------------------------------------------------------
// ### 3. Address Decode
//
// Sử dụng PADDR[3:2] để chọn thanh ghi:
//   00 → CTRL_REG   (0x00)
//   01 → CNT_REG    (0x04)
//   10 → PERIOD_REG (0x08)
//   11 → INVALID
//
// Truy cập địa chỉ không hợp lệ → PSLVERR = 1
//
// -----------------------------------------------------------------------------
// ### 4. Hoạt động của Timer
//
// Khi CTRL_REG[0] (EN) = 1:
//   - Mỗi chu kỳ clock (posedge PCLK), CNT_REG tăng 1
//   - Khi CNT_REG == PERIOD_REG:
//        + CNT_REG reset về 0 ở chu kỳ kế tiếp
//        + TIMER_IRQ được kích hoạt (1) trong đúng 1 chu kỳ
//
// Khi CTRL_REG[0] (EN) = 0:
//   - CNT_REG giữ nguyên giá trị
//   - TIMER_IRQ = 0
//
// -----------------------------------------------------------------------------
// ### 5. Reset Behavior (PRESETn = 0)
//
//   - CTRL_REG   = 0
//   - CNT_REG    = 0
//   - PERIOD_REG = 0xFFFFFFFF
//   - TIMER_IRQ  = 0
//
// -----------------------------------------------------------------------------
// ### 6. Lưu ý thiết kế
//
// - CNT_REG là thanh ghi chỉ đọc (read-only), mọi thao tác ghi sẽ bị bỏ qua
// - TIMER_IRQ là tín hiệu xung (pulse) chỉ kéo lên 1 trong 1 chu kỳ
// - Module hoạt động ở chế độ No Wait State (PREADY = 1)
// - Tất cả các thanh ghi được truy cập đồng bộ theo PCLK
//
// -----------------------------------------------------------------------------
// ### 7. Timing minh họa
//
// PCLK:      __|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_
// EN:        __|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
// CNT:       0   1   2   3  ...  N   0
// PERIOD:    N   N   N   N  ...  N   N
// TIMER_IRQ: __|_________________|‾|___
//
//------------------------------------------------------------------------------

module apb_slave_timer (
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
    //Tín hiệu ngắt
    output wire TIMER_IRQ      // interrupt, high 1 cycle khi CNT == PERIOD
);
    // Tín hiệu nội bộ
    reg ctrl_reg;              // bit[0] = EN
    reg [31:0] cnt_reg;        // thanh ghi counter và là Read only
    reg [31:0] period_reg;     // thanh ghi so sánh 
    wire addr_valid;           // địa chỉ hợp lệ của 3 thanh ghi trong range của APB Slave
    wire hit_period;           // đánh dấu khi counter đủ period 

    // Cấu hình tín hiệu PREADY=1
    assign PREADY = 1'b1;
    // Cấu hình địa chỉ hợp lệ
    assign addr_valid = (PADDR[11:0] == 12'h000) ||
                        (PADDR[11:0] == 12'h004) ||
                        (PADDR[11:0] == 12'h008);
    // Cấu hình tín hiệu lỗi PSLVERR
    assign PSLVERR = (PSEL && PENABLE && !addr_valid); 

    // Write logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            ctrl_reg <= 1'b0;
            period_reg <= 32'hFFFFFFFF;
        end else if (PSEL && PENABLE && PWRITE && addr_valid) begin
            case (PADDR[3:2])
                2'b00: ctrl_reg <= PWDATA[0];
                // 2'b01: cnt_reg bỏ qua do là Read only
                2'b10: period_reg <= PWDATA;
                default: ;
            endcase
        end
    end

    // Counter logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            cnt_reg <= 32'h0;
        end else begin
            if (ctrl_reg) begin // EN=1
                if (cnt_reg == period_reg) begin
                    cnt_reg <= 32'h0;
                end else begin
                    cnt_reg <= cnt_reg + 1;
                end
            end
        end
    end

    // Compare and IRQ logic
    
    assign hit_period = (cnt_reg == period_reg);
    assign TIMER_IRQ = ctrl_reg && hit_period;

    // Read logic
    always @(*) begin
        PRDATA = 32'b0;
        // if (PSEL && PENABLE && !PWRITE && addr_valid) begin
        if (!PWRITE && addr_valid) begin
            case (PADDR[3:2])
                2'b00: PRDATA = {31'b0, ctrl_reg};
                2'b01: PRDATA = cnt_reg;
                2'b10: PRDATA = period_reg;
                default: PRDATA = 32'b0;
            endcase
        end
    end
endmodule : apb_slave_timer


// assign addr_valid = (PADDR[1:0] == 2'b00) && (PADDR[3:2] <= 2'b10);

// wire hit_period = (cnt_reg == period_reg);
    // always @(posedge PCLK or negedge PRESETn) begin
    //     if (!PRESETn) begin
    //         TIMER_IRQ <= 1'b0;
    //     end else begin
    //         if (ctrl_reg && hit_period) begin
    //             TIMER_IRQ <= 1'b1;
    //         end else begin
    //             TIMER_IRQ <= 1'b0;
    //         end
    //     end
    // end