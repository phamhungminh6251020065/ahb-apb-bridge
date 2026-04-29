//==============================================================================
// File    : ahb_master.v
// Author  : Pham Hung Minh
// Project : AHB-to-APB Bridge
// Date    : 05/04/2026
//------------------------------------------------------------------------------
// Description: 
//    - AHB Master thực hiện xin bus, chờ grant và phát transaction trên bus AHB
//    - Giao tiếp với AHB arbiter để xin quyền sử dụng bus
//    - Khi được grant, master sẽ phát transaction (đọc hoặc ghi) trên bus AHB
//    - Sau khi hoàn thành transaction, master sẽ release bus (ngừng xin quyền)
//        IDLE    → chưa có request, HBUSREQ=0
//        REQUEST → có request, HBUSREQ=1, chờ HGRANT
//        ADDR    → được grant, drive HADDR/HTRANS/HWRITE (address phase)
//        DATA    → chờ HREADY, drive HWDATA nếu write (data phase)
//==============================================================================

module ahb_master #(
    parameter MASTER_ID = 0 // 0: Master 1, 1: Master 2
) (
    input wire HCLK,           // clock của AHB
    input wire HRESETn,        // reset (active low)
    input wire HREADY,         // tín hiệu sẵn sàng của AHB
    input wire HGRANT,         // tín hiệu grant từ arbiter
    input wire [31:0] HRDATA,  // dữ liệu đọc từ bus AHB
    input wire [1:0] HRESP,    // tín hiệu phản hồi từ bus AHB (00: OKAY, 01: ERROR, 10: RETRY, 11: SPLIT)
    output reg HBUSREQ,        // tín hiệu xin bus
    output reg [31:0] HADDR,   // địa chỉ trên bus AHB
    output reg HWRITE,         // tín hiệu chỉ thị đọc/ghi (1: ghi, 0: đọc)
    output reg [31:0] HWDATA,  // dữ liệu ghi trên bus AHB
    output reg [1:0] HTRANS,   // tín hiệu loại giao dịch (IDLE=00, BUSY=01, NONSEQ=10, SEQ=11)
    output reg [2:0] HSIZE,    // tín hiệu kích thước giao dịch (000=8-bit, 001=16-bit, 010=32-bit)
    output reg [2:0] HBURST,   // tín hiệu burst type (000=single, 001=INCR, 010=WRAP4, 011=INCR4, 100=WRAP8, 101=INCR8, 110=WRAP16, 111=INCR16)

    // Control từ testbench
    input  wire        start_req,  // bắt đầu một request mới
    input  wire        write_in,   // 1: write, 0: read
    input  wire [31:0] addr_in,    // địa chỉ cho transaction
    input  wire [31:0] wdata_in,   // dữ liệu ghi cho transaction
    input  wire        more_seq,   // 1: còn transaction tiếp theo (dùng cho burst), 0: transaction cuối cùng 

    // Output báo done
    output reg         done,       // transaction hoàn thành
    output reg [31:0]  rdata_out   // dữ liệu đọc từ transaction HRDATA
);
    // Định nghĩa các trạng thái của AHB master
    parameter IDLE = 2'b00;
    parameter REQUEST = 2'b01;
    parameter ADDR = 2'b10;
    parameter DATA = 2'b11;
    reg [1:0] state, next_state;

    // Các tín hiệu nội trong AHB master để giữ transaction
    reg [31:0] addr_reg;
    reg [31:0] wdata_reg;
    reg write_reg;

    // Logic để chuyển trạng thái
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    // Logic để xác định trạng thái kế tiếp
    always @(*) begin
        next_state = state; // Mặc định giữ nguyên trạng thái
        case (state)
            IDLE: begin
                if (start_req)
                    next_state = REQUEST;
            end
            REQUEST: begin
                if (HGRANT && HREADY)
                    next_state = ADDR;
            end
            ADDR: begin
                next_state = DATA;
            end
            DATA: begin
                if (!HREADY)
                    next_state = DATA; // Nếu chưa xử lý xong thì thêm wait state
                else if (HREADY && more_seq)
                    next_state =  ADDR; // Nếu xử lý xong và còn req thì về ADDR phase
                else if (HREADY && !more_seq)
                    next_state = IDLE; // Nếu xử lý xong và kh còn req thì sang IDLE, kết thúc transfer
            end
            default: next_state = IDLE;
        endcase
    end
    // Logic latch transaction
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            addr_reg <= 32'b0;
            wdata_reg <= 32'b0;
            write_reg <= 1'b0;
        end else if (state == IDLE && start_req) begin
            addr_reg <= addr_in;
            wdata_reg <= wdata_in;
            write_reg <= write_in;
        end
    end

    // Logic output tín hiệu AHB dựa trên trạng thái
    always @(*) begin
        // Default values
        HBUSREQ = 0;
        HADDR   = 32'b0;
        HWRITE  = 0;
        HWDATA  = 32'b0;
        HTRANS  = 2'b00; // IDLE
        HSIZE   = 3'b010; // 32-bit
        HBURST  = 3'b000; // SINGLE
        case (state)
            IDLE: begin
                HBUSREQ = start_req;
                HTRANS  = 2'b00; // IDLE
            end
            REQUEST: begin
                HBUSREQ = 1;
                HTRANS  = 2'b00; // IDLE
            end
            ADDR: begin
                HBUSREQ = 1;
                HADDR   = addr_reg;
                HWRITE  = write_reg;
                HTRANS  = 2'b10; // NONSEQ (đầu của một transaction)
            end
            DATA: begin
                HBUSREQ = 1;
                HADDR   = addr_reg; // Địa chỉ vẫn giữ nguyên trong DATA phase
                HWRITE  = write_reg;
                if (more_seq)
                    HTRANS = 2'b11;
                else
                    HTRANS =2'b00; // Nếu đây là transaction cuối thì về IDLE
                if (write_reg)
                    HWDATA = wdata_reg;
            end
        endcase
    end
    // Logic để latch dữ liệu đọc khi transaction hoàn thành
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            rdata_out <= 32'b0;
        end else if (state == DATA && !write_reg && HREADY) begin
            rdata_out <= HRDATA; // Latch dữ liệu đọc khi transaction read hoàn thành
        end
    end
    //  Logic kết thúc transaction
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            done <= 0;
        else if (state == DATA && HREADY)
            done <= 1;
        else
            done <= 0;
    end
endmodule : ahb_master