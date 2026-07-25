# Hardware Integration Guide

## 1. System Integration Overview
The **Protocol Monitor IP** is a passive monitoring core designed to be tapped into any 32-bit streaming data interface (Valid/Ready protocol). Because it only monitors control and data signals, it introduces **zero pipeline latency** and zero logic insertion onto the critical path of the monitored bus.

---

## 2. Instantiation Example (Verilog)

```verilog
// Instantiate Core Protocol Monitor IP
protocol_monitor #(
    .DATA_WIDTH         (32),
    .COUNTER_W          (32),
    .TIMEOUT_LIMIT      (100000000),
    .WINDOW_SIZE        (1000),
    .RESET_GRACE_CYCLES (3)
) u_protocol_checker (
    .clk                       (sys_clk),
    .rst_n                     (sys_rst_n),
    .vld                       (axi_tvalid),
    .rdy                       (axi_tready),
    .data                      (axi_tdata),

    .protocol_violation_sticky (mon_sticky_error),
    .violation_code            (mon_violation_code),

    .total_violations          (mon_total_violations),
    .total_handshakes          (mon_total_handshakes),

    .latency_last              (mon_latency_last),
    .latency_min               (mon_latency_min),
    .latency_max               (mon_latency_max),

    .window_handshakes         (mon_window_handshakes),
    .throughput_pct            (mon_throughput_pct),

    .drop_valid_count          (mon_drop_valid_count),
    .data_change_count         (mon_data_change_count),
    .timeout_count             (mon_timeout_count),
    .reset_violation_count     (mon_reset_violation_count)
);
```

---

## 3. Vivado Project Generation & Build Steps

### Option A: Automated TCL Project Build
To build the project using Xilinx Vivado in batch mode:

```bash
vivado -mode batch -source scripts/create_project.tcl
```

Target Specs:
- **Part**: `xc7z020clg484-1`
- **Board**: Avnet ZedBoard (`em.avnet.com:zed:part0:1.3`)

---

## 4. On-Chip Debugging via Xilinx ILA

The top-level design embeds an Integrated Logic Analyzer (`u_ila_0`) configured in [constraints/constraints.xdc](file:///a:/hackfest/sandisk/protocol_monitor7/protocol_monitor6/Protocol-Monitor-IP/constraints/constraints.xdc):

1. Open **Vivado Hardware Manager**.
2. Connect to the ZedBoard via JTAG.
3. Load the synthesized bitstream.
4. Set ILA trigger condition on `protocol_violation_sticky == 1` or `violation_code != 0`.
5. Capture real-time hardware signal waveforms directly inside Vivado.
