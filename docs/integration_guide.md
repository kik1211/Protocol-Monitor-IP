# Hardware Integration Guide

## 1. Overview

The **Protocol Monitor IP** is a passive monitoring core designed to tap into any streaming data interface using Valid/Ready handshake semantics. It observes `vld`, `rdy`, and `data` signals without inserting any logic into the monitored data path — zero pipeline latency, zero timing impact.

---

## 2. Instantiation Example (Verilog)

```verilog
protocol_monitor #(
    .DATA_WIDTH         (32),
    .COUNTER_W          (32),
    .TIMEOUT_LIMIT      (100000000),
    .WINDOW_SIZE        (1000),
    .RESET_GRACE_CYCLES (3)
) u_protocol_checker (
    .clk                       (sys_clk),
    .rst_n                     (sys_rst_n),
    .vld                       (stream_valid),
    .rdy                       (stream_ready),
    .data                      (stream_data),

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

## 3. Vivado Project Generation

### Automated TCL Build

Generate a Vivado project targeting the Avnet ZedBoard in batch mode:

```bash
vivado -mode batch -source scripts/create_project.tcl
```

The script (`scripts/create_project.tcl`) performs the following:

1. Creates a project in `./build/` targeting `xc7z020clg484-1`.
2. Sets the board part to `em.avnet.com:zed:part0:1.3`.
3. Adds all RTL sources from `rtl/`.
4. Adds testbench files from `tb/` to the `sim_1` fileset.
5. Adds constraints from `constraints/`.
6. Sets `top` as the synthesis top module and `tb` as the simulation top module.

### Manual Build

1. Open Vivado and create a new project targeting `xc7z020clg484-1`.
2. Add `rtl/*.v` as design sources.
3. Add `tb/tb.v` as a simulation source.
4. Add `constraints/constraints.xdc` as a constraints file.
5. Set `top` as the top-level module.
6. Run Synthesis → Implementation → Generate Bitstream.

---

## 4. On-Chip Debugging via Xilinx ILA

The top-level design includes `mark_debug` attributes on key internal signals. The ILA core (`u_ila_0`) is configured in [constraints/constraints.xdc](../constraints/constraints.xdc) with the following probes:

| Probe | Signal | Width |
| :--- | :--- | :---: |
| `probe0` | `dbg_d` (data bus) | 32 |
| `probe1` | `violation_code` | 4 |
| `probe2` | `dbg_r` (ready) | 1 |
| `probe3` | `dbg_v` (valid) | 1 |
| `probe4` | `protocol_violation_sticky` | 1 |

### ILA Capture Procedure

1. Open **Vivado Hardware Manager**.
2. Connect to the ZedBoard via JTAG.
3. Program the device with the generated bitstream.
4. Set the ILA trigger condition (e.g. `protocol_violation_sticky == 1` or `violation_code != 0`).
5. Arm the trigger and toggle the board switches to exercise the protocol.
6. Capture and inspect the resulting waveform.
