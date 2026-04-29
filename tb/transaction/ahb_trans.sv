//==============================================================================
// File    : ahb_trans.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 14/04/2026
//------------------------------------------------------------------------------
// Description:
//   AHB Transaction (sequence item) cho DUT mới.
//   Sửa so với bản cũ:
//     - Bỏ hoàn toàn: start_req, write_in, addr_in, wdata_in, more_seq,
//       done, rdata_out (những field này là control interface của ahb_master,
//       không còn tồn tại trong dut_top)
//     - Thêm: hbusreq, hgrant, hready (AHB bus signals thực sự)
//     - Thêm: master_id để phân biệt M1/M2
//     - Giữ: haddr, hwdata, hwrite, htrans, hsize, hburst, hrdata, hresp
//==============================================================================

class ahb_trans extends uvm_sequence_item;
    

    // ── Random fields ─────────────────────────────────────────────
    rand logic [31:0] haddr;
    rand logic [31:0] hwdata;
    rand logic        hwrite;
    logic [1:0]       htrans;   // fixed = NONSEQ
    rand logic [2:0]  hsize;
    rand logic [2:0]  hburst;

    // ── Monitor fields ────────────────────────────────────────────
    logic [31:0] hrdata;
    logic [1:0]  hresp;
    logic        hreadyout;
    int          master_id;

    `uvm_object_utils_begin(ahb_trans)

        `uvm_field_int(haddr,     UVM_ALL_ON)
        `uvm_field_int(hwdata,    UVM_ALL_ON)
        `uvm_field_int(hwrite,    UVM_ALL_ON)
        `uvm_field_int(htrans,    UVM_ALL_ON)
        `uvm_field_int(hsize,     UVM_ALL_ON)
        `uvm_field_int(hburst,    UVM_ALL_ON)

        `uvm_field_int(hrdata,    UVM_ALL_ON)
        `uvm_field_int(hresp,     UVM_ALL_ON)
        `uvm_field_int(hreadyout, UVM_ALL_ON)
        `uvm_field_int(master_id, UVM_ALL_ON)

    `uvm_object_utils_end

    // ── Constraints ───────────────────────────────────────────────

    constraint valid_addr_c {
        haddr inside {
            [32'h4000_0000:32'h4000_FFFF],
            [32'h4001_0000:32'h4001_FFFF],
            [32'h4002_0000:32'h4002_FFFF]
        };
    }

    constraint slave_dist_c {
        haddr[31:16] dist {
            16'h4000 := 33,
            16'h4001 := 33,
            16'h4002 := 34
        };
    }

    constraint word_aligned_c {
        haddr[1:0] == 2'b00;
    }

    constraint regfile_range_c {
        if (haddr[31:16] == 16'h4002)
            haddr[4:0] inside {5'h00,5'h04,5'h08,5'h0C,5'h10,5'h14,5'h18,5'h1C};
    }

    constraint gpio_range_c {
        if (haddr[31:16] == 16'h4000)
            haddr[3:0] inside {4'h0,4'h4,4'h8};
    }

    constraint timer_range_c {
        if (haddr[31:16] == 16'h4001)
            haddr[3:0] inside {4'h0,4'h4,4'h8};
    }

    constraint default_ctrl_c {
        htrans == 2'b10;
        hsize  == 3'b010;
        hburst == 3'b000;
    }

    constraint write_data_c {
        if (!hwrite) hwdata == 32'h0;
    }

    constraint rw_dist_c {
        hwrite dist {1 := 50, 0 := 50};
    }

    function new(string name = "ahb_trans");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "[M%0d] %s addr=0x%08h data=0x%08h rdata=0x%08h hresp=%0b",
            master_id,
            hwrite ? "WRITE" : "READ ",
            haddr, hwdata, hrdata, hresp
        );
    endfunction

endclass