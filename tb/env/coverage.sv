class coverage extends uvm_component;
    `uvm_component_utils(coverage)

    // Analysis ports
    `uvm_analysis_imp_decl(_ahb)
    `uvm_analysis_imp_decl(_apb)

    uvm_analysis_imp_ahb #(ahb_trans, coverage) ahb_export;
    uvm_analysis_imp_apb #(apb_trans, coverage) apb_export;

    // Last transactions (sample dùng)
    ahb_trans ahb_tr;
    apb_trans apb_tr;

    //========================================================
    // AHB COVERGROUP
    //========================================================
    covergroup ahb_cg;

        option.per_instance = 1;

        // Read / Write
        cp_rw: coverpoint ahb_tr.hwrite {
            bins READ  = {0};
            bins WRITE = {1};
        }

        // Address range (3 slaves)
        cp_addr: coverpoint ahb_tr.haddr {
            bins GPIO    = {[32'h4000_0000:32'h4000_FFFF]};
            bins TIMER   = {[32'h4001_0000:32'h4001_FFFF]};
            bins REGFILE = {[32'h4002_0000:32'h4002_FFFF]};
        }

        // Master ID
        cp_master: coverpoint ahb_tr.master_id {
            bins M1 = {0};
            bins M2 = {1};
        }

        // Cross: master x read/write
        cross_rw_master: cross cp_rw, cp_master;

        // Cross: slave x read/write
        cross_addr_rw: cross cp_addr, cp_rw;

    endgroup

    //========================================================
    // APB COVERGROUP
    //========================================================
    covergroup apb_cg;

        option.per_instance = 1;

        // Slave selection
        cp_slave: coverpoint apb_tr.slave_id {
            bins GPIO    = {1};
            bins TIMER   = {2};
            bins REGFILE = {3};
        }

        // Read / Write
        cp_rw: coverpoint apb_tr.pwrite {
            bins READ  = {0};
            bins WRITE = {1};
        }

        // Error
        cp_error: coverpoint apb_tr.pslverr {
            bins OK  = {0};
            bins ERR = {1};
        }

        // Cross: slave x rw
        cross_slave_rw: cross cp_slave, cp_rw;

    endgroup

    //========================================================
    function new(string name, uvm_component parent);
        super.new(name, parent);

        ahb_cg = new();
        apb_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ahb_export = new("ahb_export", this);
        apb_export = new("apb_export", this);
    endfunction

    //========================================================
    // SAMPLE FROM AHB
    //========================================================
    function void write_ahb(ahb_trans tr);
        ahb_tr = tr;
        if (ahb_tr != null)
            ahb_cg.sample();
    endfunction

    //========================================================
    // SAMPLE FROM APB
    //========================================================
    function void write_apb(apb_trans tr);
        apb_tr = tr;
        if (apb_tr != null)
            apb_cg.sample();
    endfunction

    //========================================================
    function void report_phase(uvm_phase phase);
        `uvm_info("COV",
            $sformatf("AHB Coverage = %0.2f%%", ahb_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("COV",
            $sformatf("APB Coverage = %0.2f%%", apb_cg.get_coverage()),
            UVM_LOW)
    endfunction

endclass