//==============================================================================
// File    : coverage.sv
// Project : AHB-to-APB Bridge
//==============================================================================

class coverage extends uvm_component;
    `uvm_component_utils(coverage)

    //========================================================
    // Analysis ports
    //========================================================
    `uvm_analysis_imp_decl(_ahb)
    `uvm_analysis_imp_decl(_apb)

    uvm_analysis_imp_ahb #(ahb_trans, coverage) ahb_export;
    uvm_analysis_imp_apb #(apb_trans, coverage) apb_export;

    //========================================================
    // Transaction handles
    //========================================================
    ahb_trans ahb_tr;
    apb_trans apb_tr;

    //========================================================
    // C1 : AHB TRANSACTION COVERAGE
    //========================================================
    covergroup ahb_trans_cg;

        option.per_instance = 1;

        //--------------------------------------------
        // Read / Write
        //--------------------------------------------
        cp_rw : coverpoint ahb_tr.hwrite {
            bins READ  = {0};
            bins WRITE = {1};
        }

        //--------------------------------------------
        // Address region
        //--------------------------------------------
        cp_addr : coverpoint ahb_tr.haddr {

            bins GPIO = {
                [32'h4000_0000 : 32'h4000_FFFF]
            };

            bins TIMER = {
                [32'h4001_0000 : 32'h4001_FFFF]
            };

            bins REGFILE = {
                [32'h4002_0000 : 32'h4002_FFFF]
            };
        }

        //--------------------------------------------
        // Master
        //--------------------------------------------
        cp_master : coverpoint ahb_tr.master_id {
            bins M1 = {0};
            bins M2 = {1};
        }

        //--------------------------------------------
        // Cross coverage
        //--------------------------------------------
        cross_rw_addr : cross cp_rw, cp_addr;

        cross_master_rw : cross cp_master, cp_rw;

    endgroup : ahb_trans_cg

    //========================================================
    // C2 : APB TRANSACTION COVERAGE
    //========================================================
    covergroup apb_trans_cg;

        option.per_instance = 1;

        //--------------------------------------------
        // Slave select
        //--------------------------------------------
        cp_slave : coverpoint apb_tr.slave_id {

            bins GPIO    = {1};
            bins TIMER   = {2};
            bins REGFILE = {3};
        }

        //--------------------------------------------
        // Read / Write
        //--------------------------------------------
        cp_rw : coverpoint apb_tr.pwrite {
            bins READ  = {0};
            bins WRITE = {1};
        }

        //--------------------------------------------
        // PSLVERR
        //--------------------------------------------
        cp_error : coverpoint apb_tr.pslverr {
            bins OK  = {0};
            bins ERR = {1};
        }

        //--------------------------------------------
        // Cross
        //--------------------------------------------
        cross_slave_rw : cross cp_slave, cp_rw;

    endgroup : apb_trans_cg

    //========================================================
    // C3 : BRIDGE PATH COVERAGE
    //========================================================
    covergroup bridge_fsm_cg;

        option.per_instance = 1;

        //--------------------------------------------
        // Read path / Write path
        //--------------------------------------------
        cp_path : coverpoint apb_tr.pwrite {
            bins READ_PATH  = {0};
            bins WRITE_PATH = {1};
        }

        //--------------------------------------------
        // Slave path
        //--------------------------------------------
        cp_slave : coverpoint apb_tr.slave_id {

            bins GPIO    = {1};
            bins TIMER   = {2};
            bins REGFILE = {3};
        }

        //--------------------------------------------
        // Cross
        //--------------------------------------------
        cross_slave_path : cross cp_slave, cp_path;

    endgroup : bridge_fsm_cg

    //========================================================
    // C4 : ARBITRATION COVERAGE
    //========================================================
    covergroup arb_cg;

        option.per_instance = 1;

        //--------------------------------------------
        // Granted master
        //--------------------------------------------
        cp_master : coverpoint ahb_tr.master_id {

            bins M1 = {0};
            bins M2 = {1};
        }

        //--------------------------------------------
        // Address region
        //--------------------------------------------
        cp_addr : coverpoint ahb_tr.haddr {

            bins GPIO = {
                [32'h4000_0000 : 32'h4000_FFFF]
            };

            bins TIMER = {
                [32'h4001_0000 : 32'h4001_FFFF]
            };

            bins REGFILE = {
                [32'h4002_0000 : 32'h4002_FFFF]
            };
        }

        //--------------------------------------------
        // Cross
        //--------------------------------------------
        cross_master_addr : cross cp_master, cp_addr;

    endgroup : arb_cg

    //========================================================
    // C5 : GPIO COVERAGE
    //========================================================
    covergroup gpio_cg;

        option.per_instance = 1;

        //--------------------------------------------
        // GPIO data patterns
        //--------------------------------------------
        cp_gpio_data : coverpoint apb_tr.pwdata[7:0] {

            bins ZERO  = {8'h00};

            bins FULL  = {8'hFF};

            bins MIXED = {[8'h01 : 8'hFE]};
        }

    endgroup : gpio_cg

    //========================================================
    // C6 : TIMER COVERAGE
    //========================================================
    covergroup timer_cg;

        option.per_instance = 1;

        //--------------------------------------------
        // Timer enable
        //--------------------------------------------
        cp_timer_en : coverpoint apb_tr.pwdata[0] {

            bins DISABLE = {0};

            bins ENABLE  = {1};
        }

        //--------------------------------------------
        // Timer period
        //--------------------------------------------
        cp_timer_period : coverpoint apb_tr.pwdata {

            bins SMALL = {[1:15]};

            bins LARGE = {[16:255]};
        }

    endgroup : timer_cg

    //========================================================
    // Constructor
    //========================================================
    function new(string name, uvm_component parent);

        super.new(name, parent);

        ahb_trans_cg  = new();
        apb_trans_cg  = new();
        bridge_fsm_cg = new();
        arb_cg        = new();
        gpio_cg       = new();
        timer_cg      = new();

    endfunction

    //========================================================
    // Build phase
    //========================================================
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        ahb_export = new("ahb_export", this);

        apb_export = new("apb_export", this);

    endfunction

    //========================================================
    // Sample AHB transaction
    //========================================================
    function void write_ahb(ahb_trans tr);

        ahb_tr = tr;

        if (ahb_tr != null) begin

            ahb_trans_cg.sample();

            arb_cg.sample();

        end

    endfunction

    //========================================================
    // Sample APB transaction
    //========================================================
    function void write_apb(apb_trans tr);

        apb_tr = tr;

        if (apb_tr != null) begin

            apb_trans_cg.sample();

            bridge_fsm_cg.sample();

            //----------------------------------------
            // GPIO coverage
            //----------------------------------------
            if (apb_tr.slave_id == 1)
                gpio_cg.sample();

            //----------------------------------------
            // TIMER coverage
            //----------------------------------------
            if (apb_tr.slave_id == 2)
                timer_cg.sample();

        end

    endfunction

    //========================================================
    // Report phase
    //========================================================
    function void report_phase(uvm_phase phase);

        real total_cov;

        total_cov =
            (
                ahb_trans_cg.get_coverage()  +
                apb_trans_cg.get_coverage()  +
                bridge_fsm_cg.get_coverage() +
                arb_cg.get_coverage()        +
                gpio_cg.get_coverage()       +
                timer_cg.get_coverage()
            ) / 6.0;

        `uvm_info("COV",
            "============================================",
            UVM_LOW)

        `uvm_info("COV",
            "        FUNCTIONAL COVERAGE REPORT",
            UVM_LOW)

        `uvm_info("COV",
            "============================================",
            UVM_LOW)

        `uvm_info("COV",
            $sformatf("AHB TRANS Coverage   = %0.2f%%",
            ahb_trans_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("COV",
            $sformatf("APB TRANS Coverage   = %0.2f%%",
            apb_trans_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("COV",
            $sformatf("BRIDGE PATH Coverage = %0.2f%%",
            bridge_fsm_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("COV",
            $sformatf("ARB Coverage         = %0.2f%%",
            arb_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("COV",
            $sformatf("GPIO Coverage        = %0.2f%%",
            gpio_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("COV",
            $sformatf("TIMER Coverage       = %0.2f%%",
            timer_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("COV",
            "--------------------------------------------",
            UVM_LOW)

        `uvm_info("COV",
            $sformatf("TOTAL Coverage       = %0.2f%%",
            total_cov),
            UVM_LOW)

        `uvm_info("COV",
            "============================================",
            UVM_LOW)

    endfunction

endclass : coverage