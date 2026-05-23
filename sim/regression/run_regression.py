import subprocess
import os
import re
from datetime import datetime

TESTLIST = "regression/testlist.txt"

PASS = 0
FAIL = 0
UNKNOWN = 0

results = []

#====================================
# ANSI COLOR
#====================================

GREEN  = "\033[92m"
RED    = "\033[91m"
YELLOW = "\033[93m"
CYAN   = "\033[96m"
WHITE  = "\033[97m"
RESET  = "\033[0m"

#====================================
# READ TESTLIST
#====================================

with open(TESTLIST, "r") as f:
    tests = [line.strip() for line in f if line.strip()]

reg_start = datetime.now()

#====================================
# RUN TESTS
#====================================

for test in tests:

    test_start = datetime.now()

    print(f"\n{CYAN}=== RUNNING {test} ==={RESET}")

    cmd = f"make sim TEST={test}"

    subprocess.run(
        cmd,
        shell=True,
        capture_output=True,
        text=True
    )

    log_file = f"log/sim/{test}_simulate.log"

    status = "UNKNOWN"

    if os.path.exists(log_file):

        with open(log_file, "r", errors="ignore") as lf:
            log = lf.read()

            has_uvm_error = (
                re.search(r"#\s*UVM_(ERROR|FATAL)\s+(?!:)", log) or
                re.search(r"UVM_(ERROR|FATAL)[ \t]*:[ \t]*[1-9][0-9]*", log)
            )

            if "TEST FAILED" in log or has_uvm_error:
                status = "FAIL"

            elif "TEST PASSED" in log:
                status = "PASS"

    # COUNT
    if status == "PASS":
        PASS += 1
    elif status == "FAIL":
        FAIL += 1
    else:
        UNKNOWN += 1

    # SAVE RESULT
    results.append({
        "test"      : test,
        "status"    : status,
        "run_date"  : test_start.strftime("%d-%m-%Y %H:%M:%S"),
        "log_file"  : log_file
    })

reg_end = datetime.now()

used_time = reg_end - reg_start
minutes = used_time.seconds // 60
seconds = used_time.seconds % 60

#====================================
# BUILD REPORT STRING (NO COLOR)
#====================================

report = ""

report += "============================================================\n"
report += "             AHB to APB REGRESSION SUMMARY REPORT           \n"
report += "============================================================\n\n"

report += f"Total testcase run : {len(results)}\n"
report += f"Passed             : {PASS}\n"
report += f"Failed             : {FAIL}\n"
report += f"Unknown            : {UNKNOWN}\n"
report += f"Used time          : {minutes}m {seconds}s\n"

report += "------------------------------------------------------------\n"

report += "\nRun summary:\n\n"

report += "+-------------------------------------+----------+---------------------+\n"
report += "| TESTCASE                            | RESULT   | RUN DATE            |\n"
report += "+-------------------------------------+----------+---------------------+\n"

for r in results:

    report += (
        f"| {r['test']:<35} "
        f"| {r['status']:<8} "
        f"| {r['run_date']:<19} |\n"
    )

report += "+-------------------------------------+----------+---------------------+\n"

report += "\nRun log detail:\n"

for r in results:

    if r["status"] == "PASS":
        result_str = "=> Passed"

    elif r["status"] == "FAIL":
        result_str = "=> Failed"

    else:
        result_str = "=> Unknown"

    report += f"{r['log_file']:<50} {result_str}\n"

report += "\n"

if FAIL > 0 or UNKNOWN > 0:
    report += "########## REGRESSION FAILED ##########\n"
else:
    report += "########## REGRESSION PASSED ##########\n"

report += "============================================================\n"

#====================================
# SAVE REPORT
#====================================

os.makedirs("regression", exist_ok=True)

# Save TXT report
txt_report = "regression/report.txt"

with open(txt_report, "w") as rpt:
    rpt.write(report)

# Save LOG report
log_report = "regression/report.log"

with open(log_report, "w") as rpt:
    rpt.write(report)

#====================================
# PRINT TO TERMINAL (WITH COLOR)
#====================================

print("\n")

print(f"{CYAN}============================================================{RESET}")
print(f"{CYAN}             AHB to APB REGRESSION SUMMARY REPORT           {RESET}")
print(f"{CYAN}============================================================{RESET}\n")

print(f"{WHITE}Total testcase run : {len(results)}{RESET}")
print(f"{GREEN}Passed             : {PASS}{RESET}")
print(f"{RED}Failed             : {FAIL}{RESET}")
print(f"{YELLOW}Unknown            : {UNKNOWN}{RESET}")
print(f"{WHITE}Used time          : {minutes}m {seconds}s{RESET}")

print(f"{CYAN}------------------------------------------------------------{RESET}")

print(f"\n{CYAN}Run summary:{RESET}\n")

print("+-------------------------------------+----------+---------------------+")
print("| TESTCASE                            | RESULT   | RUN DATE            |")
print("+-------------------------------------+----------+---------------------+")

for r in results:

    if r["status"] == "PASS":
        status_color = GREEN

    elif r["status"] == "FAIL":
        status_color = RED

    else:
        status_color = YELLOW

    print(
        f"| {r['test']:<35} "
        f"| {status_color}{r['status']:<8}{RESET} "
        f"| {r['run_date']:<19} |"
    )

print("+-------------------------------------+----------+---------------------+")

print(f"\n{CYAN}Run log detail:{RESET}\n")

for r in results:

    if r["status"] == "PASS":
        result_str = f"{GREEN}=> Passed{RESET}"

    elif r["status"] == "FAIL":
        result_str = f"{RED}=> Failed{RESET}"

    else:
        result_str = f"{YELLOW}=> Unknown{RESET}"

    print(f"{r['log_file']:<50} {result_str}")

print()

if FAIL > 0 or UNKNOWN > 0:
    print(f"{RED}########## REGRESSION FAILED ##########{RESET}")
else:
    print(f"{GREEN}########## REGRESSION PASSED ##########{RESET}")

print(f"{CYAN}============================================================{RESET}")

print(f"\n{GREEN}TXT report saved : {txt_report}{RESET}")
print(f"{GREEN}LOG report saved : {log_report}{RESET}")
