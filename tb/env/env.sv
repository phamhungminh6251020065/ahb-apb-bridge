//==============================================================================
// File    : env.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 15/04/2026
//==============================================================================

class env extends uvm_env;
    `uvm_component_utils(env)

    // ── Agents ─────────────────────────────────────────────
    ahb_agent ahb_ag;
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
        ahb_ag = ahb_agent::type_id::create("ahb_ag", this);
        apb_ag = apb_agent::type_id::create("apb_ag", this);

        // Create SB + Coverage
        sb  = scoreboard::type_id::create("sb", this);
        cov = coverage::type_id::create("cov", this);

        // Set master_id cho agent
        uvm_config_db#(int)::set(this, "ahb_ag", "master_id", 0);

        `uvm_info(get_full_name(), "Build phase complete", UVM_LOW)
    endfunction

    //========================================================
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // ── AHB → SB & Coverage
        ahb_ag.ap.connect(sb.ahb_export);
        ahb_ag.ap.connect(cov.ahb_export);

        // ── APB → SB & Coverage
        apb_ag.ap.connect(sb.apb_export);
        apb_ag.ap.connect(cov.apb_export);

        `uvm_info(get_full_name(), "Connect phase complete", UVM_LOW)
    endfunction

    //========================================================
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        
        // Print component hierarchy with agent active/passive status
        `uvm_info("ENV", $sformatf("AHB Agent is_active: %s", ahb_ag.is_active), UVM_NONE)
        `uvm_info("ENV", $sformatf("APB Agent is_active: %s", apb_ag.is_active), UVM_NONE)
    endfunction

endclass : env