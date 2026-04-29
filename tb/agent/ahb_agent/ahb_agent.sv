//==============================================================================
// File    : ahb_agent.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 14/04/2026
//------------------------------------------------------------------------------
// Thay đổi so với bản cũ:
//   - Thêm master_id (0=M1, 1=M2) để phân biệt 2 instance trong Env
//   - Truyền master_id xuống monitor để log đúng
//   - Lấy vif từ config_db theo key "ahb_vif_m1" hoặc "ahb_vif_m2"
//     thay vì key chung "vif"
//   - Env sẽ instantiate 2 ahb_agent: ahb_agent_m1, ahb_agent_m2
//==============================================================================

class ahb_agent extends uvm_agent;
    `uvm_component_utils(ahb_agent)

    ahb_sequencer sequencer;
    ahb_driver    driver;
    ahb_monitor   monitor;

    uvm_analysis_port #(ahb_trans) ap;

    virtual ahb_if vif;
    int master_id = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        uvm_active_passive_enum is_active;
        super.build_phase(phase);

        // get master_id
        void'(uvm_config_db#(int)::get(this, "", "master_id", master_id));

        // get active/passive config
        if (!uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active))
            is_active = UVM_ACTIVE;

        // get vif
        if (!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif_m1", vif))
            `uvm_fatal("AHB_AGENT", "Cannot get ahb_vif_m1")

        // create monitor
        monitor = ahb_monitor::type_id::create("monitor", this);

        // active agent
        if (get_is_active() == UVM_ACTIVE) begin
            sequencer = ahb_sequencer::type_id::create("sequencer", this);
            driver    = ahb_driver::type_id::create("driver", this);
        end

        // pass vif xuống sub-components (FIXED: move to build_phase)
        uvm_config_db#(virtual ahb_if)::set(this, "driver",  "vif", vif);
        uvm_config_db#(virtual ahb_if)::set(this, "monitor", "vif", vif);

        monitor.master_id = master_id;

        ap = new("ap", this);

        `uvm_info("AHB_AGENT",
            $sformatf("Build agent M%0d, active=%0d", master_id, get_is_active()),
            UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (get_is_active() == UVM_ACTIVE)
            driver.seq_item_port.connect(sequencer.seq_item_export);

        monitor.ap.connect(ap);
    endfunction

endclass