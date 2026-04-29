//==============================================================================
// File    : apb_trans.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 15/04/2026
//------------------------------------------------------------------------------
// Description:
//   APB Transaction — chỉ observe (không rand vì APB Monitor passive).
//   Sửa so với bản cũ:
//     - Tách psel thành psel1/psel2/psel3 (khớp với dut_top và apb_if)
//     - Thêm pready (riêng theo slave_id)
//     - Thêm slave_id tự động decode từ psel1/2/3
//     - Thêm hàm get_slave_name() tiện cho debug
//==============================================================================

class apb_trans extends uvm_sequence_item;
    

    // ── Observed fields ─────────────────────────────────────────
    logic [31:0] paddr;
    logic [31:0] pwdata;
    logic [31:0] prdata;   // valid when (!pwrite && is_access && pready)

    logic        pwrite;
    logic        penable;
    logic        pready;
    logic        pslverr;

    logic        psel1, psel2, psel3;

    int          slave_id; // 1=GPIO,2=Timer,3=RegFile
    logic        is_access; // PENABLE phase
    time         txn_time;

    `uvm_object_utils_begin(apb_trans)
        `uvm_field_int(paddr,     UVM_ALL_ON)
        `uvm_field_int(pwdata,    UVM_ALL_ON)
        `uvm_field_int(prdata,    UVM_ALL_ON)
        `uvm_field_int(pwrite,    UVM_ALL_ON)
        `uvm_field_int(penable,   UVM_ALL_ON)
        `uvm_field_int(pready,    UVM_ALL_ON)
        `uvm_field_int(pslverr,   UVM_ALL_ON)

        `uvm_field_int(psel1,     UVM_ALL_ON)
        `uvm_field_int(psel2,     UVM_ALL_ON)
        `uvm_field_int(psel3,     UVM_ALL_ON)

        `uvm_field_int(slave_id,  UVM_ALL_ON)

    `uvm_object_utils_end

    function new(string name = "apb_trans");
        super.new(name);
    endfunction

    function void decode_slave();
        int cnt = psel1 + psel2 + psel3;

        if (cnt > 1) begin
            `uvm_error("APB_TRANS", "Multiple PSEL asserted!")
            slave_id = -1;
        end
        else if (psel1) slave_id = 1;
        else if (psel2) slave_id = 2;
        else if (psel3) slave_id = 3;
        else            slave_id = 0;
    endfunction

    function string get_slave_name();
        case (slave_id)
            1: return "GPIO";
            2: return "Timer";
            3: return "RegFile";
            default: return "NONE";
        endcase
    endfunction

    function string convert2string();
        return $sformatf(
            "[APB][%s] %s addr=0x%08h pwdata=0x%08h prdata=0x%08h ready=%0b err=%0b",
            get_slave_name(),
            pwrite ? "WRITE" : "READ ",
            paddr, pwdata, prdata, pready, pslverr
        );
    endfunction

endclass