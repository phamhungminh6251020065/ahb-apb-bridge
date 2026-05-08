//==============================================================================
// File    : scoreboard.sv
// Project : AHB-to-APB Bridge
// Author  : Pham Hung Minh
// Date    : 15/04/2026
//==============================================================================

class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    //========================
    // Analysis ports
    `uvm_analysis_imp_decl(_ahb)
    `uvm_analysis_imp_decl(_apb)

    uvm_analysis_imp_ahb #(ahb_trans, scoreboard) ahb_export;
    uvm_analysis_imp_apb #(apb_trans, scoreboard) apb_export;

    //========================
    // Queue
    ahb_trans ahb_q[$];

    //========================
    // Counters
    int matched;
    int failed;
    int dropped;

    //========================
    // Log storage (for summary table)
    string summary_q[$];

    //========================
    function new(string name, uvm_component parent);
        super.new(name, parent);
        ahb_export = new("ahb_export", this);
        apb_export = new("apb_export", this);
    endfunction

    //========================================================
    // AHB PUSH
    function void write_ahb(ahb_trans tr);
        ahb_trans tr_clone;

        $cast(tr_clone, tr.clone());
        ahb_q.push_back(tr_clone);

        `uvm_info("SB", $sformatf("AHB PUSH addr=%h write=%0d",
                    tr.haddr, tr.hwrite), UVM_HIGH)
    endfunction

    //========================================================
    // APB → MATCH + COMPARE
    function void write_apb(apb_trans tr);

        apb_trans apb_tr;
        ahb_trans ahb_tr;

        string type_str;
        string line;
        string result_str;
        string master_str;
        string slave_str;
        bit pass;

        logic [31:0] ahb_data;
        logic [31:0] apb_data;
        time t;

        $cast(apb_tr, tr.clone());

        if (ahb_q.size() == 0) begin
            `uvm_error("SB_EMPTY",
                $sformatf("APB without AHB! addr=%h", tr.paddr))
            dropped++;
            return;
        end

        ahb_tr = ahb_q.pop_front();

        type_str = ahb_tr.hwrite ? "WRITE" : "READ";

        ahb_data = ahb_tr.hwrite ? ahb_tr.hwdata : ahb_tr.hrdata;
        apb_data = ahb_tr.hwrite ? apb_tr.pwdata : apb_tr.prdata;

        t = $time;

        pass = 1;

        // DATA CHECK
        if (ahb_data !== apb_data) begin
            pass = 0;
            `uvm_error("SB_DATA",
                $sformatf("%s FAIL addr=%h AHB=%h APB=%h",
                type_str, ahb_tr.haddr, ahb_data, apb_data))
        end

        // RESP CHECK
        if (ahb_tr.hresp != 0 || apb_tr.pslverr != 0) begin
            pass = 0;
            `uvm_error("SB_RESP", "Error response detected")
        end

        // COUNT
        if (pass) begin
            matched++;
            result_str = "PASS";
        end
        else begin
            failed++;
            result_str = "FAIL";
        end

        // SAVE LOG LINE (TABLE ROW)
        master_str = $sformatf("Master%0d", ahb_tr.master_id + 1);
        slave_str  = apb_tr.get_slave_name();

        line = $sformatf("| %8t | %-4s | %-6s  | %-4s | %08h | %-5s | %08h | %08h | %-5s  |",
                t,
                master_str,
                slave_str,
                "AHB",
                ahb_tr.haddr,
                type_str,
                ahb_data,
                apb_data,
                result_str);

        summary_q.push_back(line);

    endfunction

    //========================================================
    function void report_phase(uvm_phase phase);

        string report_str;
        int total;
        int i;

        total = matched + failed + dropped;

        // HEADER
        report_str = "\n==========================================================================================\n";
        report_str = {report_str, "                             SCOREBOARD SUMMARY TABLE\n"};
        report_str = {report_str, "==========================================================================================\n"};
        report_str = {report_str, "|   TIME   | MASTER  |  SLAVE   | PROT |   ADDR   | TYPE  | AHB_DATA | APB_DATA | RESULT |\n"};
        report_str = {report_str, "+----------+---------+----------+------+----------+-------+----------+----------+--------+\n"};

        // TABLE CONTENT
        for (i = 0; i < summary_q.size(); i++) begin
            report_str = {report_str, summary_q[i], "\n"};
        end

        report_str = {report_str, "+----------+---------+----------+------+----------+-------+----------+----------+--------+\n"};

        // SUMMARY
        report_str = {report_str, $sformatf("TOTAL: %0d | PASS: %0d | FAIL: %0d | DROP: %0d\n",
                        total, matched, failed, dropped)};
        report_str = {report_str, "==========================================================================================\n\n"};

        // RESULT BANNER
        if (failed || dropped) begin
            report_str = {report_str,
            "\n",
            " _____         _     _____     _ _          _ _ \n",
            "|_   _|__  ___| |_  |  ___|_ _(_) | ___  __| | |\n",
            "  | |/ _ \\/ __| __| | |_ / _` | | |/ _ \\/ _` | |\n",
            "  | |  __/\\__ \\ |_  |  _| (_| | | |  __/ (_| |_|\n",
            "  |_|\\___||___/\\__| |_|  \\__,_|_|_|\\___|\\__,_(_)\n",
            "\n"
                };
        end else begin
            report_str = {report_str,
            "\n",
            " _____         _     ____                        _ \n",
            "|_   _|__  ___| |_  |  _ \\ __ _ ___ ___  ___  __| |\n",
            "  | |/ _ \\/ __| __| | |_) / _` / __/ __|/ _ \\/ _` |\n",
            "  | |  __/\\__ \\ |_  |  __/ (_| \\__ \\__ \\  __/ (_| |\n",
            "  |_|\\___||___/\\__| |_|   \\__,_|___/___/\\___|\\__,_|\n",
            "\n"
                };
        end

        `uvm_info("SB_REPORT", report_str, UVM_LOW)

        if (failed || dropped)
            `uvm_error("SB", "Scoreboard detected errors")

    endfunction

endclass : scoreboard