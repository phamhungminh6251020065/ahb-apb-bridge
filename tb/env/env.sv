//==============================================================================
// File    : env.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 15/04/2026
//==============================================================================

class env extends uvm_env;
    `uvm_component_utils(env)

    // ── Agents ─────────────────────────────────────────────
    ahb_agent ahb_ag_m1;
    ahb_agent ahb_ag_m2;
    apb_agent apb_ag;

    // ── Scoreboard + Coverage ──────────────────────────────
    scoreboard sb;
    coverage   cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //========================================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create agents
        ahb_ag_m1 = ahb_agent::type_id::create("ahb_ag_m1", this);
        ahb_ag_m2 = ahb_agent::type_id::create("ahb_ag_m2", this);
        apb_ag = apb_agent::type_id::create("apb_ag", this);

        // Create SB + Coverage
        sb  = scoreboard::type_id::create("sb", this);
        cov = coverage::type_id::create("cov", this);

        // Set master_id cho agent M1
        uvm_config_db#(int)::set(this, "ahb_ag_m1", "master_id", 0);
        // Set master_id cho agent M2
        uvm_config_db#(int)::set(this, "ahb_ag_m2", "master_id", 1);

        `uvm_info(get_full_name(), "Build phase complete", UVM_LOW)
    endfunction

    //========================================================
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // ── AHB M1 → SB & Coverage
        ahb_ag_m1.ap.connect(sb.ahb_export);
        ahb_ag_m1.ap.connect(cov.ahb_export);

        // ── AHB M2 → SB & Coverage
        ahb_ag_m2.ap.connect(sb.ahb_export);
        ahb_ag_m2.ap.connect(cov.ahb_export);

        // ── APB → SB & Coverage
        apb_ag.ap.connect(sb.apb_export);
        apb_ag.ap.connect(cov.apb_export);

        `uvm_info(get_full_name(), "Connect phase complete", UVM_LOW)
    endfunction

    //========================================================
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        
        // Print component hierarchy with agent active/passive status
        `uvm_info("ENV", $sformatf("AHB M1 Agent is_active: %s", ahb_ag_m1.is_active), UVM_NONE)
        `uvm_info("ENV", $sformatf("AHB M2 Agent is_active: %s", ahb_ag_m2.is_active), UVM_NONE)
        `uvm_info("ENV", $sformatf("APB Agent is_active: %s", apb_ag.is_active), UVM_NONE)
    endfunction

endclass : env