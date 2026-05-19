//==============================================================================
// File    : arb_round_robin_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 19/05/2026
//------------------------------------------------------------------------------
// Description:
// Single transfer sequence for Round-Robin arbitration test.
// Each master issues ONE transfer only.
//==============================================================================

class arb_round_robin_seq extends ahb_base_seq;

    `uvm_object_utils(arb_round_robin_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    rand logic [31:0] wr_addr;
    rand logic [31:0] wr_data;

    //--------------------------------------------
    // Address constraint
    //--------------------------------------------
    constraint addr_cnst {
        wr_addr inside {
            32'h4002_0000,
            32'h4002_0004,
            32'h4002_0008,
            32'h4002_000C
        };
    }

    //--------------------------------------------
    // Data constraint
    //--------------------------------------------
    constraint data_cnst {
        wr_data inside {[32'h0000_0001:32'hFFFF_FFFE]};
    }

    function new(string name = "arb_round_robin_seq");
        super.new(name);
    endfunction : new

    virtual task body();

        `uvm_info("ARB_RR_SEQ",
            $sformatf("=== ROUND ROBIN START : MASTER %0d ===",
            master_id),
            UVM_LOW)

        //--------------------------------------------
        // Randomize
        //--------------------------------------------
        if (!randomize()) begin
            `uvm_fatal("ARB_RR_SEQ",
                "Randomization failed")
        end

        //--------------------------------------------
        // Single transfer only
        //--------------------------------------------
        do_write(wr_addr, wr_data);

        `uvm_info("ARB_RR_SEQ",
            $sformatf("MASTER %0d WRITE DONE addr=0x%08h data=0x%08h",
            master_id, wr_addr, wr_data),
            UVM_LOW)

    endtask : body

endclass : arb_round_robin_seq