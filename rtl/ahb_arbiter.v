//==============================================================================
// File    : ahb_arbiter.v
// Author  : Pham Hung Minh
// Project : AHB-to-APB Bridge
// Date    : 04/04/2026
//------------------------------------------------------------------------------
// Description:
//   - AHB arbiter có chức năng điều phối quyền sử dụng bus giữa 2 master
//   nhận tín hiệu HBUSREQ từ 2 master và trả về tín hiệu HGRANT tương ứng với master
//   - Hỗ trợ 2 mode ưu tiên: Round Robin (RR) và Fixed Priority (FP)
//     + Round Robin: luân phiên cấp quyền giữa 2 master
//       Dùng bit HGRANT để xác định master dùng bus, sau mỗi lần cấp quyền sẽ chuyển sang master khác
//       Nếu chỉ có 1 master yêu cầu bus, sẽ cấp quyền cho master đó liên tục
//     + Fixed Priority: ưu tiên master 1 hơn master 2 nếu cùng yêu cầu bus
//=============================================================================

module ahb_arbiter #(
    parameter MODE = 0 // 0: Fixed Priority, 1: Round Robin;
)(
    input wire HCLK,           // clock của AHB
    input wire HRESETn,        // reset (active low)
    input wire HREADY,         // tín hiệu sẵn sàng của AHB, chỉ cấp quyền khi HREADY=1
    input wire HBUSREQ1,       // yêu cầu bus từ master 1
    input wire HBUSREQ2,       // yêu cầu bus từ master 2
    output reg HGRANT1,        // cấp quyền bus cho master 1
    output reg HGRANT2         // cấp quyền bus cho master 2
);

    // thanh ghi last_grant để lưu master được cấp quyền lần cuối (dùng cho Round Robin)
    reg last_grant; // 0: master 1, 1: master 2

    // Logic cập nhật last_grant khi có sự thay đổi về yêu cầu bus
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HGRANT1   <= 0;
            HGRANT2   <= 0;
            last_grant <= 0;
        end else if (HREADY) begin
            // ===== NO REQUEST =====
            if (!HBUSREQ1 && !HBUSREQ2) begin
                HGRANT1 <= 0;
                HGRANT2 <= 0;
            end

            // ===== ONLY M1 =====
            else if (HBUSREQ1 && !HBUSREQ2) begin
                HGRANT1 <= 1;
                HGRANT2 <= 0;
                last_grant <= 0;
            end

            // ===== ONLY M2 =====
            else if (!HBUSREQ1 && HBUSREQ2) begin
                HGRANT1 <= 0;
                HGRANT2 <= 1;
                last_grant <= 1;
            end

            // ===== BOTH REQUEST =====
            else begin
                if (MODE == 0) begin
                    // FIXED PRIORITY → KHÔNG dùng last_grant
                    HGRANT1 <= 1;
                    HGRANT2 <= 0;
                    last_grant <= 0;
                end 
                else begin
                    // ROUND ROBIN
                    if (last_grant == 0) begin
                        HGRANT1 <= 0;
                        HGRANT2 <= 1;
                        last_grant <= 1;
                    end else begin
                        HGRANT1 <= 1;
                        HGRANT2 <= 0;
                        last_grant <= 0;
                    end
                end
            end
        end
    end
endmodule : ahb_arbiter