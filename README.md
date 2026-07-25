# Protocol Monitor IP

An FPGA-based hardware IP core for real-time monitoring, verification, and performance profiling of streaming Valid/Ready handshake protocols.

---

## 1. Project Overview

The **Protocol Monitor IP** is a parameterizable, passive hardware monitor designed for streaming data interfaces operating under Valid/Ready handshake semantics. It inspects control and data lines on every clock cycle, detects protocol violations on-the-fly, latches sticky error flags, tracks error statistics, and calculates cycle-accurate transaction latency (minimum, maximum, last) and real-time sliding-window throughput percentage.

---

## 2. Key Features

- **Passive Monitoring**: Inserts zero pipeline latency and zero logic into the monitored data path.
- **Rule Assertion Enforcement**: Real-time detection of Drop Valid, Data Change during wait, Timeout, and Reset Grace violations.
- **Performance Profiling**: Tracks cycle-accurate minimum, maximum, and last transaction latency.
- **Sliding-Window Throughput**: Calculates real-time throughput percentage over a configurable history window (`WINDOW_SIZE`).
- **On-Chip Debug Support**: Integrated Xilinx Logic Analyzer (`u_ila_0`) core and physical ZedBoard switch/LED hardware mapping.
- **Self-Checking Verification**: Includes an automated self-checking testbench (`tb/tb.v`) with automated PASS/FAIL summary reporting.

---

## 3. Repository Structure

```
Protocol-Monitor-IP/
├── rtl/
│   ├── master.v              # Switch-to-protocol producer mock
│   ├── protocol_monitor.v    # Core Protocol Checker & Telemetry IP
│   ├── slave.v               # Switch-to-protocol consumer mock
│   └── top.v                 # Top-level hardware wrapper & ILA debug binding
├── tb/
│   └── tb.v                  # Self-checking verification testbench
├── constraints/
│   └── constraints.xdc       # ZedBoard pin, clock & ILA constraints
├── docs/
│   ├── architecture.md       # Architectural specification & Mermaid diagrams
│   ├── protocol_rules.md     # Protocol rules & WaveDrom timing diagrams
│   ├── integration_guide.md  # Hardware integration & Vivado build guide
│   └── verification.md       # Verification methodology & test log matrix
├── images/
│   └── README.md             # Waveform & ILA screenshot placeholders
├── scripts/
│   └── create_project.tcl    # Automated Vivado project creation script
├── .gitignore                # Vivado build artifact gitignore
├── LICENSE                   # MIT License
└── README.md                 # Project Overview (This file)
```

---

## 4. RTL Architecture

```mermaid
graph TD
    subgraph Top_Level_Wrapper ["top.v"]
        SW["sw[7:0] Switches"] --> MSTR["master.v"]
        SW --> SLV["slave.v"]
        SW --> RST["sw[0] (rst_n)"]

        MSTR -->|vld| PM["protocol_monitor.v"]
        MSTR -->|data[31:0]| PM
        SLV -->|rdy| PM
        RST -->|rst_n| PM

        PM -->|violation_code[3:0]| LEDS["led[3:0] (LEDs)"]
        PM -->|protocol_violation_sticky| LEDS4["led[4] (Sticky LED)"]
        MSTR -->|vld| LEDS5["led[5] (Valid LED)"]
        SLV -->|rdy| LEDS6["led[6] (Ready LED)"]

        PM -->|Telemetry & Status| ILA["u_ila_0 (Xilinx ILA Core)"]
    end
```

For full architectural details, parameter descriptions, and port definitions, see [docs/architecture.md](file:///a:/hackfest/sandisk/protocol_monitor7/protocol_monitor6/Protocol-Monitor-IP/docs/architecture.md).

---

## 5. Protocol Rules & Timing

The IP core monitors four protocol rules:

1. **Drop Valid (`VIOL_DROP_VALID` = `4'd1`)**: `vld` must remain high once asserted until `rdy` is high.
2. **Data Change (`VIOL_DATA_CHG` = `4'd2`)**: `data` payload must remain stable while waiting for `rdy`.
3. **Timeout (`VIOL_TIMEOUT` = `4'd3`)**: `vld` waiting for `rdy` must not exceed `TIMEOUT_LIMIT` cycles.
4. **Reset Grace (`VIOL_RESET_VALID` = `4'd4`)**: `vld` must remain low during reset and for `RESET_GRACE_CYCLES` after reset release.

### WaveDrom Timing Diagrams

#### Rule 1: Drop Valid Violation (`VIOL_DROP_VALID` = `4'd1`)
```json
{ "signal": [
  {"name": "clk",     "wave": "p........"},
  {"name": "vld",     "wave": "0.1.0...."},
  {"name": "rdy",     "wave": "0........"},
  {"name": "code",    "wave": "0...1.0..", "data": ["VIOL_DROP_VALID"]},
  {"name": "sticky",  "wave": "0...1...."}
]}
```

#### Rule 2: Data Change Violation (`VIOL_DATA_CHG` = `4'd2`)
```json
{ "signal": [
  {"name": "clk",     "wave": "p........"},
  {"name": "vld",     "wave": "0.1......"},
  {"name": "rdy",     "wave": "0........"},
  {"name": "data",    "wave": "x.=.=....", "data": ["DATA_A", "DATA_B"]},
  {"name": "code",    "wave": "0...2.0..", "data": ["VIOL_DATA_CHG"]}
]}
```

*(For WaveDrom diagrams of Timeout and Reset Grace violations, see [docs/protocol_rules.md](file:///a:/hackfest/sandisk/protocol_monitor7/protocol_monitor6/Protocol-Monitor-IP/docs/protocol_rules.md)).*

---

## 6. Simulation Timeline

| Time (approx.) | Test Scenario | Expected Observation |
| :---: | :--- | :--- |
| **50–140 ns** | Clean Handshake | `total_handshakes` increments to 5; `total_violations = 0`; `violation_code = 0`. |
| **175–190 ns** | Drop VALID | `violation_code = 1` (`VIOL_DROP_VALID`); `drop_valid_count` increments; `protocol_violation_sticky` latches to `1`. |
| **220–240 ns** | Data Change | `violation_code = 2` (`VIOL_DATA_CHG`); `data_change_count` increments. |
| **350–370 ns** | Timeout | `violation_code = 3` (`VIOL_TIMEOUT`); `timeout_count` increments. |
| **445–460 ns** | Reset Grace Violation | Active-low reset (`sw[0]=0`) clears counters; `violation_code = 4` (`VIOL_RESET_VALID`); `reset_violation_count = 1`. |

---

## 7. Verification

The self-checking testbench ([tb/tb.v](file:///a:/hackfest/sandisk/protocol_monitor7/protocol_monitor6/Protocol-Monitor-IP/tb/tb.v)) automatically validates normal operation and all violation scenarios.

### Verification Signal & Behavior Notes
- **`protocol_violation_sticky`**: Latches to `1` on the first error and remains `1` until active-low reset (`sw[0] = 0`).
- **`violation_code`**: Operates in live mode (`0` default, pulsing to `1`–`4` during error cycles).
- **Throughput Calculation Note**: `throughput_pct` calculates integer throughput over a `WINDOW_SIZE` of 1000 cycles (10,000 ns). Simulation runs ~500 ns with 5 handshakes ($\frac{5 \times 100}{1000} = 0.5\%$), resulting in `0%` due to integer truncation. This is expected behavior and not a bug.
- **Error Tracking (`error_count`)**: Testbench variable tracking assertion failures. `0` indicates 100% test pass.

---

## 8. FPGA Usage & Hardware Integration

### Hardware Interface & LED Mapping ([top.v](file:///a:/hackfest/sandisk/protocol_monitor7/protocol_monitor6/Protocol-Monitor-IP/rtl/top.v#L85-L89))

| LED Pin | Signal Mapped | Description |
| :--- | :--- | :--- |
| `led[3:0]` | `violation_code[3:0]` | Live active violation code (`0`=None, `1`=Drop, `2`=Data, `3`=Timeout, `4`=Reset). |
| `led[4]` | `protocol_violation_sticky` | Latched error flag (`1` if any error occurred since reset). |
| `led[5]` | `v` | Live state of `vld` signal. |
| `led[6]` | `r` | Live state of `rdy` signal. |
| `led[7]` | `v & r` | Live Handshake indicator (`vld` and `rdy` active). |

### Quick Start (Build Project)

Run Vivado batch mode to generate the project targeting Avnet ZedBoard (`xc7z020clg484-1`):

```bash
vivado -mode batch -source scripts/create_project.tcl
```

*(For detailed integration instructions and ILA debug setups, see [docs/integration_guide.md](file:///a:/hackfest/sandisk/protocol_monitor7/protocol_monitor6/Protocol-Monitor-IP/docs/integration_guide.md)).*

---

## 9. Verification Results

### Automated Test Summary Output
```
==================================================
   *** ALL VERIFICATION TESTS PASSED (0 ERRORS) ***
   Total Handshakes : 0
   Total Violations : 1
   Drop Valid Count : 0
   Data Change Count: 0
   Timeout Count    : 0
   Reset Violations : 1
==================================================
```

### Waveform Screenshot Placeholders
- **Clean Handshake**: `![Clean Handshake](images/waveform_clean_handshake.png)`
- **Drop VALID**: `![Drop Valid](images/waveform_drop_valid.png)`
- **Data Change**: `![Data Change](images/waveform_data_change.png)`
- **Timeout**: `![Timeout Violation](images/waveform_timeout.png)`
- **Reset Violation**: `![Reset Violation](images/waveform_reset_violation.png)`
- **ILA Debug Capture**: `![ILA Debug](images/ila_hardware_debug.png)`

---

## 10. Future Work (Phase 2 & Beyond)

1. **RTL Timing Optimization**: Update `WINDOW_SIZE` to `1024` and replace `/ 1000` integer division with bit-shift operators (`>> 10`).
2. **Runtime Error Clear**: Add a `clear_error` input port to deassert sticky errors without chip reset.
3. **AXI4-Lite Register Interface**: Wrap telemetry registers into an AXI4-Lite slave interface for CPU memory-mapped monitoring.
4. **Open-Source CI/CD**: Add GitHub Actions workflow running Icarus Verilog and GTKWave.

---

## 11. License

This project is released under the [MIT License](file:///a:/hackfest/sandisk/protocol_monitor7/protocol_monitor6/Protocol-Monitor-IP/LICENSE).
