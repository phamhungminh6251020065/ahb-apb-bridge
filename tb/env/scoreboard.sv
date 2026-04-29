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
        line = $sformatf("| %8t | %-4s | %08h | %-5s | %08h | %08h | %-5s  |",
                t,
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
        report_str = "\n=====================================================================\n";
        report_str = {report_str, "                    SCOREBOARD SUMMARY TABLE\n"};
        report_str = {report_str, "=====================================================================\n"};
        report_str = {report_str, "|   TIME   | PROT |   ADDR   | TYPE  | AHB_DATA | APB_DATA | RESULT |\n"};
        report_str = {report_str, "+----------+------+----------+-------+----------+----------+--------+\n"};

        // TABLE CONTENT
        for (i = 0; i < summary_q.size(); i++) begin
            report_str = {report_str, summary_q[i], "\n"};
        end

        report_str = {report_str, "+----------+------+----------+-------+----------+----------+--------+\n"};

        // SUMMARY
        report_str = {report_str, $sformatf("TOTAL: %0d | PASS: %0d | FAIL: %0d | DROP: %0d\n",
                        total, matched, failed, dropped)};
        report_str = {report_str, "=====================================================================\n\n"};

        // RESULT BANNER
        if (failed || dropped) begin
            report_str = {report_str,
            "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n",
            "!!!            SIMULATION FAILED           !!!\n",
            "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"};
        end else begin
            report_str = {report_str,
            "**********************************************\n",
            "***         SIMULATION PASSED              ***\n",
            "**********************************************\n"};
        end

        `uvm_info("SB_REPORT", report_str, UVM_LOW)

        if (failed || dropped)
            `uvm_error("SB", "Scoreboard detected errors")

    endfunction

endclass


// class scoreboard extends uvm_scoreboard;
//     `uvm_component_utils(scoreboard)

//     `uvm_analysis_imp_decl(_ahb)
//     `uvm_analysis_imp_decl(_apb)

//     uvm_analysis_imp_ahb #(ahb_trans, scoreboard) ahb_export;
//     uvm_analysis_imp_apb #(apb_trans, scoreboard) apb_export;

//     // Queues
//     ahb_trans ahb_q[$];
//     apb_trans apb_q[$];

//     int pass_cnt = 0;
//     int fail_cnt = 0;

//     function new(string name, uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         ahb_export = new("ahb_export", this);
//         apb_export = new("apb_export", this);
//     endfunction

//     //========================
//     function void write_ahb(ahb_trans tr);
//         ahb_q.push_back(tr);
//         compare();
//     endfunction

//     function void write_apb(apb_trans tr);
//         apb_q.push_back(tr);
//         compare();
//     endfunction

//     //========================
//     function void compare();

//         // Try match until hết khả năng match
//         foreach (ahb_q[i]) begin
//             foreach (apb_q[j]) begin

//                 if (match(ahb_q[i], apb_q[j])) begin
//                     ahb_trans ahb_tr = ahb_q[i];
//                     apb_trans apb_tr = apb_q[j];

//                     ahb_q.delete(i);
//                     apb_q.delete(j);

//                     compare_trans(ahb_tr, apb_tr);
//                     return;
//                 end
//             end
//         end

//     endfunction

//     //========================
//     function bit match(ahb_trans a, apb_trans b);
//         return (a.haddr == b.paddr) &&
//                (a.hwrite == b.pwrite);
//     endfunction

//     //========================
//     function void compare_trans(ahb_trans ahb_tr, apb_trans apb_tr);

//         `uvm_info("SB", "Start compare...", UVM_MEDIUM)

//         // WRITE
//         if (ahb_tr.hwrite) begin
//             if (ahb_tr.hwdata !== apb_tr.pwdata) begin
//                 `uvm_error("SB", $sformatf("WDATA mismatch: AHB=%h APB=%h",
//                             ahb_tr.hwdata, apb_tr.pwdata))
//                 fail_cnt++;
//                 return;
//             end
//         end
//         // READ
//         else begin
//             if (ahb_tr.hrdata !== apb_tr.prdata) begin
//                 `uvm_error("SB", $sformatf("RDATA mismatch: AHB=%h APB=%h",
//                             ahb_tr.hrdata, apb_tr.prdata))
//                 fail_cnt++;
//                 return;
//             end
//         end

//         // Optional: error check
//         if (ahb_tr.hresp != 0 || apb_tr.pslverr != 0) begin
//             `uvm_error("SB", "ERROR response detected")
//             fail_cnt++;
//             return;
//         end

//         pass_cnt++;
//         `uvm_info("SB", "COMPARE PASS", UVM_LOW)

//     endfunction

//     //========================
//     function void report_phase(uvm_phase phase);
//         `uvm_info("SB_REPORT",
//             $sformatf("RESULT: PASS=%0d FAIL=%0d", pass_cnt, fail_cnt),
//             UVM_LOW)
//     endfunction

// endclass