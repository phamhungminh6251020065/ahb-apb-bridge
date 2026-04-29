//==============================================================================
// File    : apb_agent.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 15/04/2026
//------------------------------------------------------------------------------
// Thay đổi so với bản cũ:
//   - Dùng uvm_config_db để pass vif xuống monitor (thay vì direct assignment)
//     → consistent với pattern của ahb_agent
//   - APB Agent luôn là PASSIVE (không có Driver/Sequencer)
//==============================================================================

class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)

    apb_monitor monitor;
    uvm_analysis_port #(apb_trans) ap;
    virtual apb_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Get vif
        if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif))
            `uvm_fatal("APB_AGENT", "Cannot get apb_vif")

        // Create monitor
        monitor = apb_monitor::type_id::create("monitor", this);

        // Pass vif xuống monitor (FIXED: moved to build_phase)
        uvm_config_db#(virtual apb_if)::set(this, "monitor", "vif", vif);

        ap = new("ap", this);

        `uvm_info("APB_AGENT", "Build passive APB agent", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        monitor.ap.connect(ap);
    endfunction

endclass