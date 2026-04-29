//==============================================================================
// File    : base_test.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 15/04/2026
//==============================================================================

class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    env m_env;

    // ── Virtual interfaces ────────────────────────────────
    virtual ahb_if ahb_vif;
    virtual apb_if apb_vif;

    function new(string name = "base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    //========================================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // ── Get VIF từ tb_top ───────────────────────────────
        if (!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif))
            `uvm_fatal("TEST", "Cannot get ahb_vif")

        if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif))
            `uvm_fatal("TEST", "Cannot get apb_vif")

        // ── Config AHB Master 1 ────────────────────────────
        uvm_config_db#(virtual ahb_if)::set(this, "m_env.ahb_ag", "ahb_vif_m1", ahb_vif);
        uvm_config_db#(int)::set(this, "m_env.ahb_ag", "master_id", 0);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.ahb_ag", "is_active", UVM_ACTIVE);

        // ── Config APB (passive) ───────────────────────────
        uvm_config_db#(virtual apb_if)::set(this, "m_env.apb_ag", "apb_vif", apb_vif);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.apb_ag", "is_active", UVM_PASSIVE);

        // ── Create env ─────────────────────────────────────
        m_env = env::type_id::create("m_env", this);

        `uvm_info("TEST", "Build phase complete", UVM_LOW)
    endfunction

    //========================================================
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("TEST", "Run phase started", UVM_LOW)

        // Chưa chạy sequence (smoke env)
        #1000;

        phase.drop_objection(this);
    endtask

    //========================================================
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        
        // Print full testbench topology with agent active/passive status
        uvm_top.print_topology();
    endfunction

endclass