//==============================================================================
// File    : ahb_busreq_grant_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 16/05/2026
//------------------------------------------------------------------------------
// Description:
// Master assert HBUSREQ → Arbiter grant khi HREADY=1. HGRANT không thay đổi khi HREADY=0.
//==============================================================================

class ahb_busreq_grant_seq extends ahb_base_seq;

    `uvm_object_utils(ahb_busreq_grant_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    rand logic [31:0] wr_data;
    constraint data_cnst {
        // Dữ liệu random, tránh giá trị đặc biệt (0x0000_0000, 0xFFFF_FFFF)
        wr_data inside { [32'h0000_0001:32'hFFFF_FFFE] };
    }

    virtual apb_if apb_vif;

    function new(string name = "ahb_busreq_grant_seq");
        super.new(name);
    endfunction : new

    virtual task body();

        logic grant_before;

        `uvm_info("BUSREQ_GRANT_SEQ",
            "=== AHB BUSREQ-GRANT TEST START ===",
            UVM_LOW)

        //--------------------------------------------
        // Randomize write data
        //--------------------------------------------
        if (!randomize(wr_data)) begin
            `uvm_fatal("BUSREQ_GRANT_SEQ",
                "Randomization failed")
        end

        //--------------------------------------------
        // Get APB interface
        //--------------------------------------------
        if (!uvm_config_db#(virtual apb_if)::get(
                null, "", "apb_vif", apb_vif))
        begin
            `uvm_fatal("BUSREQ_GRANT_SEQ",
                "Cannot get apb_vif")
        end

        //--------------------------------------------
        // Create wait state
        //--------------------------------------------
        apb_vif.PREADY = 0;

        //--------------------------------------------
        // Start transfer -> HREADY should go LOW
        //--------------------------------------------
        fork
            do_write(32'h4000_0000, wr_data);
        join_none

        //--------------------------------------------
        // Wait until stall happens
        //--------------------------------------------
        wait (p_sequencer.vif.HREADY == 0);

        grant_before = p_sequencer.vif.HGRANT;

        `uvm_info("BUSREQ_GRANT_SEQ",
            $sformatf("HREADY LOW, HGRANT=%0b", grant_before),
            UVM_LOW)

        //--------------------------------------------
        // During stall, HGRANT must not change
        //--------------------------------------------
        repeat (5) begin
            @(posedge p_sequencer.vif.HCLK);

            if (p_sequencer.vif.HGRANT != grant_before) begin
                `uvm_error("BUSREQ_GRANT_SEQ",
                    "HGRANT changed while HREADY=0")
            end
        end

        //--------------------------------------------
        // Release wait state
        //--------------------------------------------
        apb_vif.PREADY = 1;

        wait (p_sequencer.vif.HREADY == 1);

        `uvm_info("BUSREQ_GRANT_SEQ",
            "HREADY returned HIGH",
            UVM_LOW)

        `uvm_info("BUSREQ_GRANT_SEQ",
            "=== AHB BUSREQ-GRANT TEST DONE ===",
            UVM_LOW)

    endtask
endclass : ahb_busreq_grant_seq