# RTL Architecture Specification

## 1. Overview
The **Protocol Monitor IP** is a parameterizable hardware IP core designed for passive, real-time monitoring of streaming Valid/Ready handshake protocols. It inspects control and data lines on every clock edge, detects protocol assertions, latches sticky error flags, and computes cycle-accurate performance telemetry (minimum, maximum, and last latency alongside sliding-window throughput).

---

## 2. Module Hierarchy & Block Diagram

```
+-----------------------------------------------------------------------------------+
|                                      top                                          |
|                                     (top.v)                                       |
|                                                                                   |
|  +--------------------+      vld, data    +------------------------------------+  |
|  |       master       |------------------>|                                    |  |
|  |     (master.v)     |                   |                                    |  |
|  +--------------------+                   |          protocol_monitor          |  |
|            ^                              |        (protocol_monitor.v)        |  |
|            |                              |                                    |  |
|  +--------------------+        rdy        |                                    |  |
|  |       slave        |------------------>|                                    |  |
|  |      (slave.v)     |                   +------------------------------------+  |
|  +--------------------+                                      |                    |
|            ^                                                 | Telemetry &        |
|            |                                                 | Violation Status   |
|   sw[7:0]  |                                                 v                    |
|  ==========+=============================================> [led[7:0]]             |
|                                                            [u_ila_0 Debug Core]   |
+-----------------------------------------------------------------------------------+
```

### System Architecture Diagram (Mermaid)

```mermaid
graph TD
    subgraph FPGA_Top ["top.v Wrapper"]
        SW["sw[7:0] (Switches)"] --> MSTR["master.v"]
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

---

## 3. Parameter Reference Table

| Parameter Name | Default Value | Data Type | Description |
| :--- | :---: | :---: | :--- |
| `DATA_WIDTH` | `32` | Integer | Bit-width of the streaming payload `data` bus. |
| `COUNTER_W` | `32` | Integer | Bit-width of internal telemetry counters and latency registers. |
| `TIMEOUT_LIMIT` | `100000000` | Integer | Maximum allowable clock cycles for an un-handshaked transaction before triggering a timeout violation. |
| `WINDOW_SIZE` | `1000` | Integer | Number of clock cycles in the sliding window history register used for throughput calculations. |
| `RESET_GRACE_CYCLES` | `3` | Integer | Number of clock cycles after active-low reset release during which `vld` must remain low. |

---

## 4. Port Reference Table

### `protocol_monitor` Core Module Ports

| Port Name | Direction | Width | Clock Domain | Description |
| :--- | :---: | :---: | :---: | :--- |
| `clk` | Input | `1` | System | Primary system clock input (100 MHz target). |
| `rst_n` | Input | `1` | Asynchronous | Active-low system reset signal. |
| `vld` | Input | `1` | `clk` | Streaming producer Valid signal under monitor. |
| `rdy` | Input | `1` | `clk` | Streaming consumer Ready signal under monitor. |
| `data` | Input | `DATA_WIDTH` | `clk` | Streaming payload data bus under monitor. |
| `protocol_violation_sticky` | Output | `1` | `clk` | Latched sticky error flag (holds `1` after any violation until reset). |
| `violation_code` | Output | `4` | `clk` | Live violation code active on current clock cycle (`0` = None, `1` = Drop Valid, `2` = Data Change, `3` = Timeout, `4` = Reset Grace). |
| `total_violations` | Output | `COUNTER_W` | `clk` | Cumulative counter of all detected protocol violations. |
| `total_handshakes` | Output | `COUNTER_W` | `clk` | Cumulative counter of successful handshakes (`vld && rdy`). |
| `latency_last` | Output | `COUNTER_W` | `clk` | Wait duration (in cycles) of the most recent completed transaction. |
| `latency_min` | Output | `COUNTER_W` | `clk` | Minimum latency observed across all completed transactions post-reset. |
| `latency_max` | Output | `COUNTER_W` | `clk` | Maximum latency observed across all completed transactions post-reset. |
| `window_handshakes` | Output | `COUNTER_W` | `clk` | Number of handshakes within the current `WINDOW_SIZE` cycle window. |
| `throughput_pct` | Output | `COUNTER_W` | `clk` | Real-time sliding window throughput percentage ($0\% - 100\%$). |
| `drop_valid_count` | Output | `COUNTER_W` | `clk` | Cumulative count of Drop Valid violations. |
| `data_change_count` | Output | `COUNTER_W` | `clk` | Cumulative count of Data Change violations. |
| `timeout_count` | Output | `COUNTER_W` | `clk` | Cumulative count of Timeout violations. |
| `reset_violation_count` | Output | `COUNTER_W` | `clk` | Cumulative count of Reset Grace violations. |

---

## 5. Performance Telemetry Architecture

### Latency Measurement
Latency is measured as the number of clock cycles a transaction spends waiting for `rdy` after `vld` has been asserted:
- **`wait_counter`**: Increments on each clock cycle where `transaction_active == 1` and `rdy == 0`.
- **`latency_last`**: Captures `wait_counter` value at the cycle of handshake completion (`vld && rdy`).
- **`latency_min` / `latency_max`**: Evaluated dynamically on every completed handshake using comparator logic.

### Throughput Calculation Logic
- **Shift Register History**: A `WINDOW_SIZE`-bit shift register (`handshake_hist`) tracks individual cycle handshake results.
- **Window Counter**: `window_handshakes` increments when a new handshake enters bit `0` and decrements when an old handshake exits bit `WINDOW_SIZE-1`.
- **Percentage Formula**: $\text{throughput\_pct} = \frac{\text{window\_handshakes} \times 100}{\text{WINDOW\_SIZE}}$.
