# AHB-to-APB Bridge Design and UVM Verification

> **Đồ án tốt nghiệp / Graduation Project**  
> **Sinh viên / Student:** Phạm Hùng Minh - MSSV: 6251020065  
> **GVHD / Supervisor:** Lê Mạnh Tuấn  
> **Khoa Điện - Điện tử, Trường Đại học Giao thông vận tải Phân hiệu tại TP.HCM**

---

## Tiếng Việt

### Tổng Quan

Project này thiết kế và kiểm chứng một hệ thống **AHB-to-APB Bridge** theo kiến trúc AMBA. DUT nhận giao dịch từ bus AHB, phân xử giữa hai AHB master, chuyển đổi sang APB, sau đó truy cập các ngoại vi APB gồm GPIO, Timer và Register File.

Môi trường kiểm chứng được xây dựng bằng **SystemVerilog/UVM**, chạy trên **QuestaSim**, có scoreboard, functional coverage, code coverage, regression script và Makefile tự động hóa.

![System Architecture](docs/images/system_architecture.jpg)

### Kiến Trúc DUT

DUT chính nằm ở `rtl/dut_top.v`, gồm các khối:

- `ahb_interconnect`: chọn master được grant và forward giao dịch AHB tới bridge.
- `ahb_arbiter`: hỗ trợ Fixed Priority và Round Robin qua tham số `ARBITER_MODE`.
- `bridge_top`: chuyển đổi AHB sang APB.
- `bridge_addr_decoder`: decode vùng địa chỉ APB slave.
- `bridge_fsm`: điều khiển các phase AHB/APB, gồm read, write và pipelined write path.
- `bridge_prdata_mux`: chọn `PRDATA/PSLVERR` từ APB slave và trả về `HRDATA/HRESP`.
- `apb_slave_gpio`: GPIO APB slave.
- `apb_slave_timer`: Timer APB slave, có `TIMER_IRQ`.
- `apb_slave_regfile`: 8 thanh ghi 32-bit.

![AHB Interconnect](docs/images/AHB_Interconnect.jpg)

![Bridge](docs/images/Bridge.jpg)

![Bridge FSM](docs/images/FSM%20bridge.jpg)

### Address Map

| Vùng địa chỉ | Slave | Mô tả |
| --- | --- | --- |
| `0x4000_0000` - `0x4000_FFFF` | GPIO | DATA, DIR, IE |
| `0x4001_0000` - `0x4001_FFFF` | TIMER | CTRL, CNT, PERIOD |
| `0x4002_0000` - `0x4002_FFFF` | REGFILE | 8 thanh ghi 32-bit |

GPIO local register map:

| Offset | Register | Chức năng |
| --- | --- | --- |
| `0x00` | `DATA_REG` | Dữ liệu GPIO `[7:0]` |
| `0x04` | `DIR_REG` | `1=output`, `0=input` |
| `0x08` | `IE_REG` | Interrupt enable |

Timer local register map:

| Offset | Register | Chức năng |
| --- | --- | --- |
| `0x00` | `CTRL_REG` | `CTRL[0] = enable` |
| `0x04` | `CNT_REG` | Counter, read-only |
| `0x08` | `PERIOD_REG` | Giá trị so sánh để sinh interrupt |

Regfile local register map:

| Offset | Register |
| --- | --- |
| `0x00` - `0x1C` | `REG0` - `REG7`, mỗi register rộng 32-bit |

### Kiến Trúc Testbench UVM

Testbench top nằm ở `tb/tb_top.sv`. Môi trường UVM gồm:

- AHB active agent: driver, sequencer, monitor.
- APB passive agent: monitor.
- Scoreboard: so sánh AHB transaction với APB transaction tương ứng.
- Coverage collector: nhận transaction từ AHB/APB monitor và sample covergroup.
- Sequence và test library: các testcase reset, APB, bridge, arbiter, functional và coverage-directed.

![UVM TB Architecture](docs/images/UVM%20TB%20architecture.jpg)

![UVM Topology](docs/images/UVM%20topology.jpg)

### Cấu Trúc Thư Mục

```text
.
├── rtl/                  # RTL design
├── tb/
│   ├── agent/            # AHB/APB UVM agents
│   ├── config/           # Testbench config
│   ├── env/              # env, scoreboard, coverage
│   ├── interface/        # AHB/APB interfaces
│   ├── pkg/              # UVM packages
│   ├── sequence/         # UVM sequences
│   ├── test/             # UVM tests
│   └── transaction/      # AHB/APB transaction classes
├── sim/
│   ├── Makefile          # Compile, sim, wave, regression, coverage
│   ├── run.f             # Questa compile filelist
│   └── regression/       # testlist and regression script
└── docs/images/          # Architecture, waveform, coverage and report images
```

### Yêu Cầu Công Cụ

- QuestaSim/ModelSim hỗ trợ SystemVerilog và UVM.
- UVM 1.2.
- `make`.
- Python 3 cho regression script.
- Môi trường Windows/MSYS được hỗ trợ bởi Makefile hiện tại.

Biến môi trường quan trọng:

```bash
UVM_HOME=/path/to/QuestaSim/uvm-1.2
```

### Cách Chạy

Tất cả lệnh chính chạy trong thư mục `sim`:

```bash
cd sim
```

Compile:

```bash
make comp
```

Chạy một testcase:

```bash
make sim TEST=tc_bridge_single_write_read
```

Chạy waveform GUI:

```bash
make wave TEST=tc_bridge_single_write_read
```

Mở lại waveform đã lưu:

```bash
make rewave TEST=tc_bridge_single_write_read
```

Chạy regression:

```bash
make regression
```

File testlist:

```text
sim/regression/testlist.txt
```

Script regression hỗ trợ comment bằng `#`:

```text
# testcase này đang tạm tắt
#tc_cov_bridge_pipeline

tc_smoke_test
tc_apb_timer_irq   # inline comment cũng được
```

Regression report:

```text
sim/regression/report.txt
sim/regression/report.log
```

![Regression Report](docs/images/regression%20test.jpg)

### Coverage

Makefile hỗ trợ cả functional coverage và code coverage ở dạng text log và HTML.

Chạy functional coverage cho một test:

```bash
make run_func_cov TEST=tc_apb_regfile_all
```

Output:

```text
sim/cov/tc_apb_regfile_all.ucdb
sim/cov/tc_apb_regfile_all_func_cov.log
sim/cov/tc_apb_regfile_all_func_cov_html/index.html
```

Chạy code coverage cho một test:

```bash
make run_code_cov TEST=tc_bridge_single_write_read
```

Output:

```text
sim/cov/tc_bridge_single_write_read_code_cov.log
sim/cov/tc_bridge_single_write_read_code_cov_html/index.html
```

Chạy regression kèm merge coverage:

```bash
make regression_cov
```

Hoặc sau khi đã có nhiều file `.ucdb`:

```bash
make regression_func_cov
make regression_code_cov
```

Lưu ý: không nên chạy `regression_func_cov` và `regression_code_cov` song song vì cả hai đều gọi `merge_cov` và ghi vào cùng file `sim/cov/regression_all.ucdb`.

Functional coverage hiện có các covergroup:

- `ahb_trans_cg`
- `apb_trans_cg`
- `bridge_fsm_cg`
- `arb_cg`
- `gpio_cg`
- `timer_cg`
- `regfile_cg`

![Functional Coverage Summary](docs/images/Functional%20Coverage%20summary.jpg)

![Functional Coverage Covergroup](docs/images/Functional%20Coverage_covergroup.jpg)

Code coverage được report tập trung vào DUT instance `/tb_top/dut`.

![Code Coverage Summary](docs/images/Code%20Coverage_summary.jpg)

![Code Coverage Module](docs/images/Code%20Coverage_module.jpg)

![Code Coverage Bridge Module](docs/images/Code%20Coverage_bridge%20module.jpg)

### Một Số Testcase Tiêu Biểu

| Nhóm | Ví dụ testcase |
| --- | --- |
| Smoke | `tc_smoke_test`, `tc_smoke_test_both` |
| Reset | `tc_reset_all_regs`, `tc_reset_mid_transfer` |
| APB slave | `tc_apb_gpio_write_all`, `tc_apb_timer_irq`, `tc_apb_regfile_all` |
| Bridge | `tc_bridge_single_write_read`, `tc_bridge_b2b_write_read`, `tc_bridge_cross_slave` |
| Arbiter | `tc_arb_fixed_m1_wins`, `tc_arb_round_robin` |
| Functional | `tc_func_data_isolation`, `tc_func_timer_irq_e2e`, `tc_func_random_m1` |
| Coverage-directed | `tc_cov_gpio_zero_timer_large`, `tc_cov_timer_invalid_offset`, `tc_cov_bridge_pipeline` |

### Hình Ảnh Kết Quả

Scoreboard examples:

![SB reset all regs](docs/images/SB_testcase%20tc_reset_all_regs.jpg)

![SB bridge single write read](docs/images/SB_testcase%20tc_bridge_single_write_read.jpg)

![SB APB PSLVERR](docs/images/SB_testcase%20tc_apb_pslverr.jpg)

Waveform examples:

![Waveform reset all regs](docs/images/Waveform_testcase%20tc_reset_all_regs.jpg)

![Waveform bridge single write read](docs/images/Waveform_testcase%20tc_bridge_single_write_read.jpg)

![Waveform APB PSLVERR](docs/images/Waveform_testcase%20tc_apb_pslverr.jpg)

### Dọn File Sinh Ra

```bash
make clean
```

Lệnh này xóa work library, log simulation, coverage output và các file tạm do Questa tạo ra.

---

## English

### Overview

This project implements and verifies an **AHB-to-APB Bridge** system based on the AMBA bus architecture. The DUT accepts AHB transactions, arbitrates between two AHB masters, converts the selected transfer to APB, and accesses APB peripherals including GPIO, Timer, and Register File.

The verification environment is built with **SystemVerilog/UVM** and runs on **QuestaSim**. It includes a scoreboard, functional coverage, code coverage, a Python regression runner, and a Makefile-based automation flow.

![System Architecture](docs/images/system_architecture.jpg)

### DUT Architecture

The main DUT wrapper is `rtl/dut_top.v`. It contains:

- `ahb_interconnect`: selects the granted master and forwards AHB transfers to the bridge.
- `ahb_arbiter`: supports Fixed Priority and Round Robin through `ARBITER_MODE`.
- `bridge_top`: converts AHB transfers to APB transfers.
- `bridge_addr_decoder`: decodes APB slave address regions.
- `bridge_fsm`: controls AHB/APB phases, including read, write, and pipelined write paths.
- `bridge_prdata_mux`: selects `PRDATA/PSLVERR` from APB slaves and returns `HRDATA/HRESP`.
- `apb_slave_gpio`: APB GPIO peripheral.
- `apb_slave_timer`: APB timer peripheral with `TIMER_IRQ`.
- `apb_slave_regfile`: 8 x 32-bit APB register file.

### Address Map

| Address range | Slave | Description |
| --- | --- | --- |
| `0x4000_0000` - `0x4000_FFFF` | GPIO | DATA, DIR, IE |
| `0x4001_0000` - `0x4001_FFFF` | TIMER | CTRL, CNT, PERIOD |
| `0x4002_0000` - `0x4002_FFFF` | REGFILE | 8 x 32-bit registers |

### UVM Testbench

The testbench top is `tb/tb_top.sv`. The UVM environment contains:

- Active AHB agent: driver, sequencer, monitor.
- Passive APB agent: monitor.
- Scoreboard: compares matched AHB and APB transactions.
- Coverage collector: samples AHB/APB transactions into functional covergroups.
- Sequence and test library: reset, APB, bridge, arbiter, functional, and coverage-directed tests.

### Directory Layout

```text
.
├── rtl/                  # RTL design
├── tb/                   # UVM verification environment
├── sim/                  # Makefile, filelist, regression flow
└── docs/images/          # Documentation images
```

### Tool Requirements

- QuestaSim/ModelSim with SystemVerilog and UVM support.
- UVM 1.2.
- `make`.
- Python 3.
- Windows/MSYS is supported by the current Makefile.

Important environment variable:

```bash
UVM_HOME=/path/to/QuestaSim/uvm-1.2
```

### How To Run

Run all main commands from `sim`:

```bash
cd sim
```

Compile:

```bash
make comp
```

Run one test:

```bash
make sim TEST=tc_bridge_single_write_read
```

Open waveform GUI:

```bash
make wave TEST=tc_bridge_single_write_read
```

Run regression:

```bash
make regression
```

Regression testlist:

```text
sim/regression/testlist.txt
```

The regression parser supports `#` comments:

```text
# disabled temporarily
#tc_cov_bridge_pipeline

tc_smoke_test
tc_apb_timer_irq   # inline comments are supported
```

Regression reports:

```text
sim/regression/report.txt
sim/regression/report.log
```

### Coverage Flow

Run functional coverage for one test:

```bash
make run_func_cov TEST=tc_apb_regfile_all
```

Run code coverage for one test:

```bash
make run_code_cov TEST=tc_bridge_single_write_read
```

Run regression and generate merged coverage reports:

```bash
make regression_cov
```

Or generate merged reports after UCDB files already exist:

```bash
make regression_func_cov
make regression_code_cov
```

Generated reports are stored under:

```text
sim/cov/
```

Functional coverage reports are generated as `.log` and HTML. Code coverage reports are also generated as `.log` and HTML, focused on the DUT instance `/tb_top/dut`.

Do not run `regression_func_cov` and `regression_code_cov` in parallel because both targets merge into the same `sim/cov/regression_all.ucdb` database.

### Cleanup

```bash
make clean
```

This removes generated work libraries, simulation logs, coverage outputs, and temporary Questa files.
