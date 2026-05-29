//==============================================================================
// File    : cov_bridge_pipeline_seq.sv
// Project : AHB-to-APB Bridge
//------------------------------------------------------------------------------
// Description:
//  Coverage-directed bridge sequence with a stronger stream of back-to-back
//  write/read transfers across APB slaves.
//==============================================================================

class cov_bridge_pipeline_seq extends ahb_base_seq;
    `uvm_object_utils(cov_bridge_pipeline_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    function new(string name = "cov_bridge_pipeline_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rdata;

        `uvm_info("COV_PIPE_SEQ", "=== COV BRIDGE PIPELINE START ===", UVM_LOW)

        do_write(32'h4002_0000, 32'h1111_0000);
        do_write(32'h4002_0004, 32'h2222_0001);
        do_write(32'h4002_0008, 32'h3333_0002);
        do_write(32'h4002_000C, 32'h4444_0003);
        do_write(32'h4000_0000, 32'h0000_005A);
        do_write(32'h4001_0008, 32'd24);
        do_write(32'h4001_0000, 32'h0000_0001);

        do_read(32'h4002_0000, rdata);
        do_read(32'h4002_0004, rdata);
        do_write(32'h4002_0010, 32'h5555_0004);
        do_read(32'h4000_0000, rdata);
        do_write(32'h4002_0014, 32'h6666_0005);
        do_read(32'h4001_0008, rdata);

        `uvm_info("COV_PIPE_SEQ", "=== COV BRIDGE PIPELINE DONE ===", UVM_LOW)
    endtask : body
endclass : cov_bridge_pipeline_seq
