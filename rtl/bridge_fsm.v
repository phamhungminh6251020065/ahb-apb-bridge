//==============================================================================
// File    : bridge_fsm.v
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 27/03/2026
//------------------------------------------------------------------------------
// Description:
//   Khối FSM (Finite State Machine) điều khiển hoạt động của AHB-to-APB Bridge.
//
//   - Chức năng:
//     + Điều khiển quá trình chuyển đổi giữa các trạng thái của giao dịch
//       nhằm đồng bộ giao thức AHB (pipelined) và APB (non-pipelined).
//
//   - Cơ chế hoạt động:
//     + FSM sử dụng các tín hiệu điều khiển:
//         * Valid      : tín hiệu giao dịch hợp lệ (Valid = HTRANS[1])
//         * HWRITE     : chỉ thị đọc/ghi từ AHB
//         * HwriteReg  : lưu giá trị HWRITE của chu kỳ trước (phục vụ pipelined write)
//     + Từ đó xác định trạng thái hiện tại và trạng thái kế tiếp.
//
//   - Các trạng thái chính:
//     + ST_IDLE      : Trạng thái chờ, không có giao dịch hợp lệ.
//     + ST_READ      : APB SETUP phase cho giao dịch đọc (PSEL=1, PENABLE=0).
//     + ST_RENABLE   : APB ACCESS phase cho giao dịch đọc (PENABLE=1).
//     + ST_WWAIT     : Trạng thái trung gian để đồng bộ dữ liệu ghi do pipeline của AHB.
//     + ST_WRITE     : APB SETUP phase cho giao dịch ghi.
//     + ST_WENABLE   : APB ACCESS phase cho giao dịch ghi.
//     + ST_WRITEP    : APB SETUP phase cho pipelined write.
//     + ST_WENABLEP  : APB ACCESS phase cho pipelined write.
//==============================================================================

module bridge_fsm (
    input wire HCLK,          // Clock từ AHB
    input wire HRESETn,       // Reset (active low) từ AHB
    input wire HWRITE,        // Tín hiệu chỉ thị đọc/ghi từ AHB (1: ghi, 0: đọc)

    // Tín hiệu nội bôn để hỗ trợ FSM (HwriteReg và Valid) sẽ được tạo ra từ module chính của Bridge dựa trên HTRANS và HWRITE
    input wire HwriteReg,     // Thanh ghi lưu HWRITE của chu kỳ trước, dùng để hỗ trợ pipelined write
    input wire Valid,         // Tín hiệu chỉ thị giao dịch hợp lệ từ AHB 
                              // Valid = HTRANS[1]
                              // (IDLE=00, BUSY=01 → Valid=0; NONSEQ=10, SEQ=11 → Valid=1)
    input wire PREADY,        // Tín hiệu sẵn sàng từ slave APB (được kết nối từ module chính của Bridge)
    
    output reg PENABLE,       // Tín hiệu enable cho APB
    output reg HREADYout,     // Tín hiệu sẵn sàng trả về cho AHB Master
    output reg [2:0] current_state
);
    
    // Định nghĩa các trạng thái của FSM (3 bits-8 trạng thái)
    parameter ST_IDLE     = 3'b000; // Không có giao dịch
    parameter ST_READ     = 3'b001; // SETUP phase cho read
    parameter ST_WWAIT    = 3'b010; // Chờ dữ liệu ghi ổn định (AHB pipeline)
    parameter ST_WRITE    = 3'b011; // SETUP phase cho write
    parameter ST_WRITEP   = 3'b100; // SETUP phase cho pipelined write
    parameter ST_RENABLE  = 3'b101; // ACCESS phase cho read
    parameter ST_WENABLE  = 3'b110; // ACCESS phase cho write
    parameter ST_WENABLEP = 3'b111; // ACCESS phase cho pipelined write
    reg [2:0] state, next_state;
    
    // FSM State Transition Logic
    // State register: Cập nhật trạng thái hiện tại vào mỗi cạnh lên của HCLK hoặc khi reset
    always @(posedge HCLK or negedge HRESETn) begin
        if(!HRESETn) begin
            state <= ST_IDLE; // Reset về trạng thái IDLE
        end else begin
            state <= next_state; // Chuyển sang trạng thái kế tiếp
        end
    end
    // Next state logic: Xác định trạng thái kế tiếp dựa trên trạng thái hiện tại và các tín hiệu điều khiển
    always @(*) begin
        next_state = state; // Mặc định giữ nguyên trạng thái hiện tại
        case (state)
            ST_IDLE: begin
                if(!Valid) begin
                    next_state = ST_IDLE;
                end else if (Valid &&!HWRITE) begin
                    next_state = ST_READ;
                end else if (Valid && HWRITE) begin
                    next_state = ST_WWAIT;
                end
            end
            ST_READ: begin
                next_state = ST_RENABLE; // Sau SETUP phase, chuyển sang ACCESS phase cho read
            end
            ST_WWAIT: begin
                if(!Valid) begin
                    next_state = ST_WRITE;
                end else begin
                    next_state = ST_WRITEP;
                end
            end
            ST_WRITE: begin
                if(!Valid) begin
                    next_state = ST_WENABLE;
                end else begin
                    next_state = ST_WENABLEP;
                end
            end
            ST_WRITEP: begin
                next_state = ST_WENABLEP; // Sau SETUP phase cho pipelined write, chuyển sang ACCESS phase
            end
            ST_RENABLE: begin
                if (!PREADY) begin
                    next_state = ST_RENABLE; // Nếu slave APB chưa sẵn sàng, giữ nguyên trạng thái ACCESS phase cho read
                end else if(!Valid) begin
                    next_state = ST_IDLE;
         	    end else if(Valid && !HWRITE) begin
                    next_state = ST_READ;
	            end else if(Valid && HWRITE) begin
 		            next_state = ST_WWAIT;
		        end
            end
            ST_WENABLE: begin
		        if(!PREADY) begin
                    next_state = ST_WENABLE; // Nếu slave APB chưa sẵn sàng, giữ nguyên trạng thái ACCESS phase cho write
                end else if(!Valid) begin
		            next_state = ST_IDLE;
	    	    end else if(Valid && !HWRITE) begin
                    next_state = ST_READ;
		        end else if (Valid && HWRITE) begin
                    next_state = ST_WWAIT;
                end
	        end
            ST_WENABLEP: begin
                if(!PREADY) begin
                    next_state = ST_WENABLEP;
                end else if(!HwriteReg) begin
                    next_state = ST_READ;
                end else if (HwriteReg && !Valid) begin
                    next_state = ST_WRITE;
                end else if (HwriteReg && Valid) begin
                    next_state = ST_WRITEP;
                end
            end
            default: begin
                next_state = ST_IDLE; // Trạng thái mặc định là IDLE
            end
        endcase 
    end
    
    // FSM Output Logic: Xác định các tín hiệu điều khiển dựa trên trạng thái hiện tại
    always @(*) begin
        PENABLE = 1'b0; // Mặc định không enable APB
        HREADYout = 1'b0; // Mặc định không sẵn sàng trả về cho AHB Master
        current_state = state; // For debugging
        if(state == ST_RENABLE || state == ST_WENABLE || state == ST_WENABLEP) begin
            PENABLE = 1'b1; // Enable APB trong ACCESS phase
            HREADYout = PREADY; // Trả về tín hiệu sẵn sàng từ slave APB cho AHB Master trong ACCESS phase
        end 
        else if(state == ST_IDLE) begin
            HREADYout = 1'b1; // Sẵn sàng trả về cho AHB Master trong các trạng thái không giao dịch hoặc đã hoàn thành giao dịch
        end
    end
endmodule : bridge_fsm