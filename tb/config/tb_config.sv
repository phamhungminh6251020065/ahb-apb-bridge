//==============================================================================
// File    : tb_config.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 14/04/2026
//------------------------------------------------------------------------------
// Description:
//   TB Configuration object — truyền virtual interface và các tham số
//   từ tb_top xuống các component qua uvm_config_db.
//   Sửa so với bản cũ:
//     - Đổi vif AHB từ 1 interface → 2 (ahb_vif_m1, ahb_vif_m2)
//       vì dut_top expose 2 Master interface riêng biệt
//     - Cập nhật địa chỉ constants khớp với address map
//     - Thêm master_id fields
//==============================================================================

class tb_config extends uvm_object;
    `uvm_object_utils(tb_config)

    // ── Virtual Interfaces ────────────────────────────────────────────────────
    virtual ahb_if ahb_vif_m1;  // AHB interface cho Master 1
    virtual ahb_if ahb_vif_m2;  // AHB interface cho Master 2
    virtual apb_if apb_vif;     // APB interface (passive monitor)

    // ── Simulation parameters ─────────────────────────────────────────────────
    int unsigned num_transactions = 20;     // Số transaction mỗi test
    int unsigned timeout_cycles   = 10000;  // Timeout guard

    // ── Agent enable ─────────────────────────────────────────────────────────
    bit ahb_agent_m1_active = 1; // 1=active (có driver), 0=passive
    bit ahb_agent_m2_active = 1; // Có thể disable M2 cho single-master test

    // ── Address map constants ─────────────────────────────────────────────────
    // GPIO (Slave 1)
    localparam logic [31:0] GPIO_BASE     = 32'h4000_0000;
    localparam logic [31:0] GPIO_DATA_REG = 32'h4000_0000; // offset 0x00
    localparam logic [31:0] GPIO_DIR_REG  = 32'h4000_0004; // offset 0x04
    localparam logic [31:0] GPIO_IE_REG   = 32'h4000_0008; // offset 0x08

    // Timer (Slave 2)
    localparam logic [31:0] TIMER_BASE       = 32'h4001_0000;
    localparam logic [31:0] TIMER_CTRL_REG   = 32'h4001_0000; // offset 0x00
    localparam logic [31:0] TIMER_CNT_REG    = 32'h4001_0004; // offset 0x04 (RO)
    localparam logic [31:0] TIMER_PERIOD_REG = 32'h4001_0008; // offset 0x08

    // RegFile (Slave 3) — mem[0..7]
    localparam logic [31:0] REGFILE_BASE = 32'h4002_0000;
    localparam logic [31:0] REGFILE_REG0 = 32'h4002_0000;
    localparam logic [31:0] REGFILE_REG1 = 32'h4002_0004;
    localparam logic [31:0] REGFILE_REG2 = 32'h4002_0008;
    localparam logic [31:0] REGFILE_REG3 = 32'h4002_000C;
    localparam logic [31:0] REGFILE_REG4 = 32'h4002_0010;
    localparam logic [31:0] REGFILE_REG5 = 32'h4002_0014;
    localparam logic [31:0] REGFILE_REG6 = 32'h4002_0018;
    localparam logic [31:0] REGFILE_REG7 = 32'h4002_001C;

    function new(string name = "tb_config");
        super.new(name);
    endfunction

endclass : tb_config