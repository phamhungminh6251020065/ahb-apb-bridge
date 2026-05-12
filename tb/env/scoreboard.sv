//==============================================================================
// File    : scoreboard.sv
//==============================================================================

class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    //====================================================
    // Analysis ports
    `uvm_analysis_imp_decl(_ahb)
    `uvm_analysis_imp_decl(_apb)

    uvm_analysis_imp_ahb #(ahb_trans, scoreboard) ahb_export;
    uvm_analysis_imp_apb #(apb_trans, scoreboard) apb_export;

    //====================================================
    // Queues
    ahb_trans ahb_q[$];
    apb_trans apb_q[$];

    //====================================================
    // Counters
    int matched;
    int failed;

    //====================================================
    // Summary
    string summary_q[$];

    //====================================================
    function new(string name, uvm_component parent);
        super.new(name, parent);

        ahb_export = new("ahb_export", this);
        apb_export = new("apb_export", this);
    endfunction

    //====================================================
    // AHB WRITE
    function void write_ahb(ahb_trans tr);

        ahb_trans tr_clone;

        $cast(tr_clone, tr.clone());

        ahb_q.push_back(tr_clone);

        `uvm_info("SB",
            $sformatf("AHB PUSH addr=%h write=%0d",
            tr.haddr, tr.hwrite),
            UVM_HIGH)

        compare_transactions();

    endfunction

    //====================================================
    // APB WRITE
    function void write_apb(apb_trans tr);

        apb_trans tr_clone;

        $cast(tr_clone, tr.clone());

        apb_q.push_back(tr_clone);

        `uvm_info("SB",
            $sformatf("APB PUSH addr=%h write=%0d",
            tr.paddr, tr.pwrite),
            UVM_HIGH)

        compare_transactions();

    endfunction

    //====================================================
    // COMPARE
    function void compare_transactions();

        ahb_trans ahb_tr;
        apb_trans apb_tr;

        int ahb_idx;
        int apb_idx;

        bit found;

        string type_str;
        string result_str;
        string line;
        string master_str;
        string slave_str;

        logic [31:0] ahb_data;
        logic [31:0] apb_data;

        bit pass;

        time t;

        forever begin

            found = 0;

            //--------------------------------------------
            // FIND MATCH
            foreach (ahb_q[i]) begin
                foreach (apb_q[j]) begin

                    if (ahb_q[i].haddr  == apb_q[j].paddr &&
                        ahb_q[i].hwrite == apb_q[j].pwrite) begin

                        ahb_idx = i;
                        apb_idx = j;
                        found   = 1;
                        break;
                    end
                end

                if (found)
                    break;
            end

            //--------------------------------------------
            // NO MATCH
            if (!found)
                break;

            //--------------------------------------------
            // GET MATCHED TRANS
            ahb_tr = ahb_q[ahb_idx];
            apb_tr = apb_q[apb_idx];

            ahb_q.delete(ahb_idx);
            apb_q.delete(apb_idx);

            //--------------------------------------------
            type_str = ahb_tr.hwrite ? "WRITE" : "READ";

            ahb_data = ahb_tr.hwrite ?
                       ahb_tr.hwdata :
                       ahb_tr.hrdata;

            apb_data = ahb_tr.hwrite ?
                       apb_tr.pwdata :
                       apb_tr.prdata;

            pass = 1;

            //--------------------------------------------
            // DATA CHECK
            if (ahb_data !== apb_data) begin

                pass = 0;

                `uvm_error("SB_DATA",
                    $sformatf(
                    "%s FAIL addr=%h AHB=%h APB=%h",
                    type_str,
                    ahb_tr.haddr,
                    ahb_data,
                    apb_data))
            end

            //--------------------------------------------
            // RESP CHECK
            //
            // FAIL only if:
            // - AHB/APB response mismatch
            //
            //
            //--------------------------------------------
            if (ahb_tr.hresp || apb_tr.pslverr) begin

                pass = 0;

                `uvm_error("SB_RESP",
                    $sformatf(
                    "RESP ERROR addr=%h hresp=%0d pslverr=%0d",
                    ahb_tr.haddr,
                    ahb_tr.hresp,
                    apb_tr.pslverr))
            end

            //--------------------------------------------
            // RESULT
            if (pass) begin
                matched++;
                result_str = "PASS";
            end
            else begin
                failed++;
                result_str = "FAIL";
            end

            //--------------------------------------------
            t = $time;

            master_str = $sformatf(
                "Master%0d",
                ahb_tr.master_id + 1);

            slave_str = apb_tr.get_slave_name();

            line = $sformatf(
                "| %8t | %-7s | %-8s | %-4s | %08h | %-5s | %5s | %7s | %08h | %08h | %-5s  |",
                t,
                master_str,
                slave_str,
                "AHB",
                ahb_tr.haddr,
                type_str,
                $sformatf("%0b", ahb_tr.hresp),
                apb_tr.pslverr ? "1" : "0",
                ahb_data,
                apb_data,
                result_str
            );

            summary_q.push_back(line);

        end

    endfunction

    //====================================================
    // UNMATCHED AHB ERRORS
    function void add_unmatched_ahb_summary(ahb_trans ahb_tr);
        string type_str;
        string result_str;
        string line;
        string master_str;
        string slave_str;
        logic [31:0] ahb_data;
        time t;

        type_str = ahb_tr.hwrite ? "WRITE" : "READ";
        ahb_data = ahb_tr.hwrite ? ahb_tr.hwdata : ahb_tr.hrdata;
        result_str = "FAIL";

        t = $time;
        master_str = $sformatf("Master%0d", ahb_tr.master_id + 1);
        slave_str  = "NONE";

        line = $sformatf(
            "| %8t | %-7s | %-8s | %-4s | %08h | %-5s | %5s | %7s | %08h | %08h | %-5s  |",
            t,
            master_str,
            slave_str,
            "AHB",
            ahb_tr.haddr,
            type_str,
            $sformatf("%0b", ahb_tr.hresp),
            "N/A",
            ahb_data,
            32'h0,
            result_str
        );

        summary_q.push_back(line);
    endfunction

    function void add_unmatched_apb_summary(apb_trans apb_tr);
        string type_str;
        string result_str;
        string line;
        string master_str;
        string slave_str;
        logic [31:0] apb_data;
        time t;

        type_str = apb_tr.pwrite ? "WRITE" : "READ";
        apb_data = apb_tr.pwrite ? apb_tr.pwdata : apb_tr.prdata;
        result_str = "FAIL";

        t = $time;
        master_str = "NONE";
        slave_str  = apb_tr.get_slave_name();

        line = $sformatf(
            "| %8t | %-7s | %-8s | %-4s | %08h | %-5s | %5s | %7s | %08h | %08h | %-5s  |",
            t,
            master_str,
            slave_str,
            "APB",
            apb_tr.paddr,
            type_str,
            "N/A",
            apb_tr.pslverr ? "1" : "0",
            32'h0,
            apb_data,
            result_str
        );

        summary_q.push_back(line);
    endfunction

    //====================================================
    // REPORT
    function void report_phase(uvm_phase phase);

        string report_str;
        int total;
        int i;

        //--------------------------------------------
        // Remaining unmatched transaction
        //
        // Ignore aborted transfer caused by reset:
        // - only count FAIL if both queues still contain
        //   unmatched transactions at end of test
        //
        //--------------------------------------------

        if (ahb_q.size() > 0 || apb_q.size() > 0) begin

            `uvm_warning("SB_PENDING",
                $sformatf(
                "Pending unmatched trans: AHB=%0d APB=%0d",
                ahb_q.size(),
                apb_q.size()))

            //----------------------------------------
            // Convert unmatched AHB transactions to summary entries
            //----------------------------------------
            foreach (ahb_q[i]) begin
                add_unmatched_ahb_summary(ahb_q[i]);
                failed++;
            end
            ahb_q.delete();

            //----------------------------------------
            // Convert unmatched APB transactions to summary entries
            //----------------------------------------
            foreach (apb_q[i]) begin
                add_unmatched_apb_summary(apb_q[i]);
                failed++;
            end
            apb_q.delete();
        end

        total = matched + failed;

        //--------------------------------------------
        report_str = "\n============================================================================================================\n";
        report_str = {report_str, "                             SCOREBOARD SUMMARY TABLE\n"};
        report_str = {report_str, "============================================================================================================\n"};
        report_str = {report_str, "|   TIME   | MASTER  |  SLAVE   | PROT |   ADDR   | TYPE  | HRESP | PSLVERR | AHB_DATA | APB_DATA | RESULT |\n"};
        report_str = {report_str, "+----------+---------+----------+------+----------+-------+-------+---------+----------+----------+--------+\n"};

        for (i = 0; i < summary_q.size(); i++) begin
            report_str = {report_str, summary_q[i], "\n"};
        end

        report_str = {report_str, "+----------+---------+----------+------+----------+-------+-------+---------+----------+----------+--------+\n"};

        report_str = {report_str,
            $sformatf(
            "TOTAL: %0d | PASS: %0d | FAIL: %0d\n",
            total,
            matched,
            failed)};

        report_str = {report_str,
            "============================================================================================================\n"};

        //--------------------------------------------
        // RESULT BANNER
        //--------------------------------------------
        if (failed > 0) begin

            report_str = {report_str,
            "\n",
            "TEST FAILED\n",
            "\n",
            " _____         _     _____     _ _          _ _ \n",
            "|_   _|__  ___| |_  |  ___|_ _(_) | ___  __| | |\n",
            "  | |/ _ \\/ __| __| | |_ / _` | | |/ _ \\/ _` | |\n",
            "  | |  __/\\__ \\ |_  |  _| (_| | | |  __/ (_| |_|\n",
            "  |_|\\___||___/\\__| |_|  \\__,_|_|_|\\___|\\__,_(_)\n",
            "\n"
            };

        end
        else begin

            report_str = {report_str,
            "\n",
            "TEST PASSED\n",
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

        if (failed)
            `uvm_error("SB", "Scoreboard detected errors")

    endfunction

endclass