//==============================================================================
// File    : ahb_wait_state-seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 15/05/2026
//------------------------------------------------------------------------------
// Description:
// HREADYout=0 khi Bridge xử lý transfer AHB to APB, sau đó HREADYout=1 khi transfer hoàn thành.
//==============================================================================

class ahb_wait_state_seq extends ahb_base_seq;

    `uvm_object_utils(ahb_wait_state_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    // APB virtual interface
    virtual apb_if apb_vif;

    function new(string name = "ahb_wait_state_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        bit stall_detected = 0;

        `uvm_info("WAIT_STATE_SEQ", "=== AHB WAIT STATE TEST START ===", UVM_LOW)

        //--------------------------------------------
        // Start transfer
        //--------------------------------------------
        fork
            begin
                do_write(32'h4000_0000, 32'hDEAD_BEEF);
            end

            begin
                repeat (10) begin
                    @(posedge p_sequencer.vif.HCLK);

                    if (p_sequencer.vif.HREADYout == 1'b0) begin
                        stall_detected = 1;

                        `uvm_info("WAIT_STATE_SEQ",
                                "Detected HREADYout LOW wait-state",
                                UVM_LOW)

                        break;
                    end
                end
            end
        join

        if (!stall_detected) begin
            `uvm_error("WAIT_STATE_SEQ",
                    "No AHB wait-state detected")
        end

        `uvm_info("WAIT_STATE_SEQ", "=== AHB WAIT STATE TEST DONE ===", UVM_LOW)

    endtask

endclass : ahb_wait_state_seq