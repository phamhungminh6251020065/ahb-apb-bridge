//==============================================================================
// File    : func_data_isolation_seq.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 20/05/2026
//------------------------------------------------------------------------------
// Description:
// M1 ghi reg[0]=DEADBEEF, M2 ghi reg[4]=AAAAAAAA. M2 đọc reg[0]→DEADBEEF, M1 đọc reg[4]→AAAAAAAA.
// Verify dữ liệu giữa 2 master được cô lập đúng cách.
//==============================================================================

class func_data_isolation_seq extends ahb_base_seq;
    `uvm_object_utils(func_data_isolation_seq)
    `uvm_declare_p_sequencer(ahb_sequencer)

    function new(string name = "func_data_isolation_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] rd_data;

        `uvm_info("DATA_ISOLATION_SEQ", "=== DATA ISOLATION TEST START ===", UVM_LOW)

        // M1 ghi reg[0]=DEADBEEF
        if (master_id == 0) begin

            // M1 write reg0
            do_write(32'h4002_0000, 32'hDEAD_BEEF);

            // wait M2 write
            #50ns;

            // M1 read reg4
            do_read(32'h4002_000C, rd_data);
        end else begin
            // M2 ghi reg[4]=AAAAAAAA
            do_write(32'h4002_000C, 32'hAAAA_AAAA);

            // wait M1 write
            #50ns;

            // M2 read reg0
            do_read(32'h4002_0000, rd_data);
        end
        `uvm_info("DATA_ISOLATION_SEQ", "=== DATA ISOLATION TEST DONE ===", UVM_LOW)
    endtask : body
endclass : func_data_isolation_seq