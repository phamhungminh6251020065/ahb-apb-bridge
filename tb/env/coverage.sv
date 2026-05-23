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
    // Last transaction for sampling
    //========================================================
    ahb_trans ahb_tr;
    apb_trans apb_tr;

    //========================================================
    // C1 : AHB TRANS COVERGROUP
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
        // Cross Coverage
        //--------------------------------------------
        cross_rw_addr : cross cp_rw, cp_addr;

        cross_master_rw : cross cp_master, cp_rw;

    endgroup : ahb_trans_cg

    //========================================================
    // C2 : APB TRANS COVERGROUP
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
        // APB Error
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
    // C3 : BRIDGE FSM COVERGROUP
    //========================================================
    // Sample FSM state từ DUT
    // Ví dụ:
    // IDLE=0 SETUP=1 ACCESS=2 ...
    //========================================================
    logic [2:0] bridge_state;

    covergroup bridge_fsm_cg;

        option.per_instance = 1;

        cp_state : coverpoint bridge_state {

            bins ST_IDLE     = {0};
            bins ST_READ     = {1};
            bins ST_WWAIT    = {2};
            bins ST_WRITE    = {3};
            bins ST_WRITEP   = {4};
            bins ST_RENABLE  = {5};
            bins ST_WENABLE  = {6};
            bins ST_WENABLEP = {7};
        }

    endgroup : bridge_fsm_cg

    //========================================================
    // C4 : ARBITRATION COVERGROUP
    //========================================================
    covergroup arb_cg;

        option.per_instance = 1;

        cp_master_grant : coverpoint ahb_tr.master_id {

            bins M1_ONLY = {0};
            bins M2_ONLY = {1};
        }

    endgroup : arb_cg

    //========================================================
    // C5 : GPIO COVERGROUP
    //========================================================
    covergroup gpio_cg;

        option.per_instance = 1;

        //--------------------------------------------
        // GPIO DATA
        //--------------------------------------------
        cp_gpio_data : coverpoint apb_tr.pwdata[7:0] {

            bins ZERO = {8'h00};
            bins FULL = {8'hFF};

            bins OTHERS[] = {[8'h01 : 8'hFE]};
        }

    endgroup : gpio_cg

    //========================================================
    // C6 : TIMER COVERGROUP
    //========================================================
    covergroup timer_cg;

        option.per_instance = 1;

        //--------------------------------------------
        // TIMER ENABLE
        //--------------------------------------------
        cp_timer_en : coverpoint apb_tr.pwdata[0] {

            bins DISABLE = {0};
            bins ENABLE  = {1};
        }

        //--------------------------------------------
        // TIMER PERIOD
        //--------------------------------------------
        cp_timer_period : coverpoint apb_tr.pwdata {

            bins SMALL  = {[1:10]};
            bins MEDIUM = {[11:100]};
            bins LARGE  = {[101:255]};
        }

    endgroup : timer_cg

    //========================================================
    // Constructor
    //========================================================
    function new(string name, uvm_component parent);

        super.new(name, parent);

        ahb_trans_cg = new();
        apb_trans_cg = new();
        bridge_fsm_cg = new();
        arb_cg = new();
        gpio_cg = new();
        timer_cg = new();

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
    // Sample AHB
    //========================================================
    function void write_ahb(ahb_trans tr);

        ahb_tr = tr;

        if (ahb_tr != null) begin

            ahb_trans_cg.sample();
            arb_cg.sample();

        end

    endfunction

    //========================================================
    // Sample APB
    //========================================================
    function void write_apb(apb_trans tr);

        apb_tr = tr;

        if (apb_tr != null) begin

            apb_trans_cg.sample();

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

        `uvm_info("COV",
            $sformatf("AHB TRANS Coverage = %0.2f%%",
            ahb_trans_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("COV",
            $sformatf("APB TRANS Coverage = %0.2f%%",
            apb_trans_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("COV",
            $sformatf("BRIDGE FSM Coverage = %0.2f%%",
            bridge_fsm_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("COV",
            $sformatf("ARB Coverage = %0.2f%%",
            arb_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("COV",
            $sformatf("GPIO Coverage = %0.2f%%",
            gpio_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("COV",
            $sformatf("TIMER Coverage = %0.2f%%",
            timer_cg.get_coverage()),
            UVM_LOW)

    endfunction

endclass