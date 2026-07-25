# Protocol Rules & Timing Specification

## 1. Monitored Protocol

The **Protocol Monitor IP** enforces assertion rules for streaming handshake interfaces using Valid/Ready semantics:

1. The producer asserts `vld` to indicate valid payload on the `data` bus.
2. The consumer asserts `rdy` to indicate readiness to accept data.
3. A successful **handshake** occurs on any rising clock edge where both `vld` and `rdy` are high.

---

## 2. Protocol Rules & WaveDrom Timing Diagrams

### Rule 0: Clean Handshake (No Violation)

A normal transaction where `vld` is asserted, `data` remains stable, `rdy` responds, and the handshake completes without error.

```json
{ "signal": [
  {"name": "clk",    "wave": "p........"},
  {"name": "rst_n",  "wave": "1........"},
  {"name": "vld",    "wave": "0.1...0.."},
  {"name": "rdy",    "wave": "0...1.0.."},
  {"name": "data",   "wave": "x.=...x..", "data": ["DATA_A"]},
  {"name": "code",   "wave": "0........"},
  {"name": "sticky", "wave": "0........"}
]}
```

---

### Rule 1: Drop Valid (`VIOL_DROP_VALID` = `4'd1`)

Once `vld` is asserted, it must **not** be deasserted until a successful handshake (`vld && rdy`) occurs.

```json
{ "signal": [
  {"name": "clk",    "wave": "p........"},
  {"name": "rst_n",  "wave": "1........"},
  {"name": "vld",    "wave": "0.1.0...."},
  {"name": "rdy",    "wave": "0........"},
  {"name": "data",   "wave": "x.=..x...", "data": ["DATA_A"]},
  {"name": "code",   "wave": "0...1.0..", "data": ["1"]},
  {"name": "sticky", "wave": "0...1...."}
]}
```

---

### Rule 2: Data Change (`VIOL_DATA_CHG` = `4'd2`)

While `vld` is asserted and waiting for `rdy`, the `data` payload must remain stable until the handshake completes.

```json
{ "signal": [
  {"name": "clk",    "wave": "p........"},
  {"name": "rst_n",  "wave": "1........"},
  {"name": "vld",    "wave": "0.1......"},
  {"name": "rdy",    "wave": "0........"},
  {"name": "data",   "wave": "x.=.=....", "data": ["DATA_A", "DATA_B"]},
  {"name": "code",   "wave": "0...2.0..", "data": ["2"]},
  {"name": "sticky", "wave": "0...1...."}
]}
```

---

### Rule 3: Timeout (`VIOL_TIMEOUT` = `4'd3`)

If `vld` remains asserted waiting for `rdy` for more than `TIMEOUT_LIMIT` clock cycles, a timeout violation is triggered. The testbench overrides `TIMEOUT_LIMIT` to `10` for simulation.

```json
{ "signal": [
  {"name": "clk",    "wave": "p........"},
  {"name": "rst_n",  "wave": "1........"},
  {"name": "vld",    "wave": "0.1......"},
  {"name": "rdy",    "wave": "0........"},
  {"name": "cnt",    "wave": "x.===.==.", "data": ["8", "9", "10", "0"]},
  {"name": "code",   "wave": "0....3.0.", "data": ["3"]},
  {"name": "sticky", "wave": "0....1..."}
]}
```

---

### Rule 4: Reset Grace (`VIOL_RESET_VALID` = `4'd4`)

During active-low reset and for `RESET_GRACE_CYCLES` (default: 3) clock cycles after reset release, `vld` must remain low.

```json
{ "signal": [
  {"name": "clk",    "wave": "p........"},
  {"name": "rst_n",  "wave": "0..1....."},
  {"name": "vld",    "wave": "0...1...."},
  {"name": "grace",  "wave": "3..210..."},
  {"name": "code",   "wave": "0...4.0..", "data": ["4"]},
  {"name": "sticky", "wave": "0...1...."}
]}
```

---

## 3. Violation Encoding Summary

| Code | Name | Trigger Condition | Counter |
| :---: | :--- | :--- | :--- |
| `4'd0` | `VIOL_NONE` | No violation on current cycle | — |
| `4'd1` | `VIOL_DROP_VALID` | `vld` deasserted while `transaction_active == 1` and `rdy == 0` | `drop_valid_count` |
| `4'd2` | `VIOL_DATA_CHG` | `data != data_hold` while `transaction_active == 1` and `rdy == 0` | `data_change_count` |
| `4'd3` | `VIOL_TIMEOUT` | `wait_counter >= TIMEOUT_LIMIT` while `rdy == 0` | `timeout_count` |
| `4'd4` | `VIOL_RESET_VALID` | `vld == 1` while `reset_grace_cnt != 0` | `reset_violation_count` |
