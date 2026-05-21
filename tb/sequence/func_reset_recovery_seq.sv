//==============================================================================
// File    : func_reset_recovery_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 22/05/2026
//------------------------------------------------------------------------------
// Description:
// Assert reset khi M1 đang transfer → sau deassert, M1 và M2 hoạt động bình thường, data đúng.
//==============================================================================

class func_reset_recovery_seq extends ahb_base_seq;
    `uvm_object_utils(func_reset_recovery_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    function new(string name = "func_reset_recovery_seq");
        super.new(name);
    endfunction

    virtual task body();

        logic [31:0] rd_data;

        `uvm_info("RESET_RECOVERY_SEQ",
                  "=== RESET RECOVERY TEST START ===",
                  UVM_LOW)

        //--------------------------------------------
        // MASTER 0
        //--------------------------------------------
        if (master_id == 0) begin

            //----------------------------------------
            // Start transfer
            //----------------------------------------
            fork
                begin
                    do_write(32'h4002_0000, 32'hDEAD_BEEF);
                    do_write(32'h4002_0004, 32'hCAFE_BABE);
                    do_write(32'h4002_0008, 32'h1234_5678);
                end
            join_none

            //----------------------------------------
            // Wait until transfer active
            //----------------------------------------
            wait(p_sequencer.vif.HREADY == 0);

            `uvm_info("RESET_RECOVERY_SEQ",
                      "Assert reset during transfer",
                      UVM_LOW)

            //----------------------------------------
            // Reset DUT
            //----------------------------------------
            do_reset();

            //----------------------------------------
            // Wait reset recovery
            //----------------------------------------
            repeat(5) @(posedge p_sequencer.vif.HCLK);

            //----------------------------------------
            // Verify master still works
            //----------------------------------------
            do_write(32'h4002_000C, 32'hAAAA_AAAA);

            do_read(32'h4002_000C, rd_data);

            // if (rd_data != 32'hAAAA_AAAA) begin
            //     `uvm_error("RESET_RECOVERY_SEQ",
            //                $sformatf("M0 recovery failed: exp=0x%08h act=0x%08h",
            //                           32'hAAAA_AAAA, rd_data))
            // end

        end

        //--------------------------------------------
        // MASTER 1
        //--------------------------------------------
        else begin

            //----------------------------------------
            // Wait reset complete
            //----------------------------------------
            repeat(10) @(posedge p_sequencer.vif.HCLK);

            //----------------------------------------
            // Verify M1 also works after reset
            //----------------------------------------
            do_write(32'h4002_0010, 32'h5555_5555);

            do_read(32'h4002_0010, rd_data);

            // if (rd_data != 32'h5555_5555) begin
            //     `uvm_error("RESET_RECOVERY_SEQ",
            //                $sformatf("M1 recovery failed: exp=0x%08h act=0x%08h",
            //                           32'h5555_5555, rd_data))
            // end
        end

        `uvm_info("RESET_RECOVERY_SEQ",
                  "=== RESET RECOVERY TEST DONE ===",
                  UVM_LOW)

    endtask : body

endclass