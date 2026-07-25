# Protocol Rules & Timing Specification

## 1. Monitored Protocol Overview

The **Protocol Monitor IP** enforces rule assertions for streaming handshake interfaces operating under Valid/Ready semantics. In a valid protocol transfer:
1. `vld` indicates the producer has placed valid payload data on the `data` bus.
2. `rdy` indicates the consumer is ready to accept data.
3. A successful handshake occurs on any rising clock edge where both `vld` and `rdy` are high (`1`).

---

## 2. Implemented Protocol Rules & WaveDrom Timing Diagrams

### Rule 0: Normal / Clean Handshake Operation
A normal transaction where `vld` is asserted, `data` remains stable, `rdy` responds, and a handshake completes cleanly.

```json
{ "signal": [
  {"name": "clk",     "wave": "p........"},
  {"name": "rst_n",   "wave": "1........"},
  {"name": "vld",     "wave": "0.1...0.."},
  {"name": "rdy",     "wave": "0...1.0.."},
  {"name": "data",    "wave": "x.=========", "data": ["DATA_A"]},
  {"name": "code",    "wave": "0........", "data": ["VIOL_NONE"]},
  {"name": "sticky",  "wave": "0........"}
]}
```

---

### Rule 1: Drop Valid Violation (`VIOL_DROP_VALID` = `4'd1`)
Once `vld` is asserted high, it must **not** be deasserted (dropped) until a successful handshake (`vld && rdy`) has occurred.

```json
{ "signal": [
  {"name": "clk",     "wave": "p........"},
  {"name": "rst_n",   "wave": "1........"},
  {"name": "vld",     "wave": "0.1.0...."},
  {"name": "rdy",     "wave": "0........"},
  {"name": "data",    "wave": "x.=======", "data": ["DATA_A"]},
  {"name": "code",    "wave": "0...1.0..", "data": ["VIOL_DROP_VALID"]},
  {"name": "sticky",  "wave": "0...1...."}
]}
```

---

### Rule 2: Data Change Violation (`VIOL_DATA_CHG` = `4'd2`)
While `vld` is asserted and waiting for `rdy`, the `data` payload must remain completely stable and constant until handshaked.

```json
{ "signal": [
  {"name": "clk",     "wave": "p........"},
  {"name": "rst_n",   "wave": "1........"},
  {"name": "vld",     "wave": "0.1......"},
  {"name": "rdy",     "wave": "0........"},
  {"name": "data",    "wave": "x.=.=....", "data": ["DATA_A", "DATA_B"]},
  {"name": "code",    "wave": "0...2.0..", "data": ["VIOL_DATA_CHG"]},
  {"name": "sticky",  "wave": "0...1...."}
]}
```

---

### Rule 3: Timeout Violation (`VIOL_TIMEOUT` = `4'd3`)
If `vld` remains asserted waiting for `rdy` for a duration exceeding `TIMEOUT_LIMIT` clock cycles, a timeout violation is triggered.

```json
{ "signal": [
  {"name": "clk",     "wave": "p........"},
  {"name": "rst_n",   "wave": "1........"},
  {"name": "vld",     "wave": "0.1......"},
  {"name": "rdy",     "wave": "0........"},
  {"name": "cnt",     "wave": "x.===.===", "data": ["8", "9", "10", "0"]},
  {"name": "code",    "wave": "0...3.0..", "data": ["VIOL_TIMEOUT"]},
  {"name": "sticky",  "wave": "0...1...."}
]}
```

---

### Rule 4: Reset Grace Violation (`VIOL_RESET_VALID` = `4'd4`)
During active-low reset (`rst_n == 0`) and for `RESET_GRACE_CYCLES` (3 clock cycles) immediately following reset release, `vld` must remain low (`0`).

```json
{ "signal": [
  {"name": "clk",     "wave": "p........"},
  {"name": "rst_n",   "wave": "0..1....."},
  {"name": "vld",     "wave": "0...1...."},
  {"name": "grace",   "wave": "3..210..."},
  {"name": "code",    "wave": "0...4.0..", "data": ["VIOL_RESET_VALID"]},
  {"name": "sticky",  "wave": "0...1...."}
]}
```

---

## 3. Violation Encoding Summary Table

| Code (`violation_code`) | Name | Trigger Condition | Counter Incremented |
| :---: | :--- | :--- | :--- |
| `4'd0` | `VIOL_NONE` | Normal operation / No violation active on current cycle | N/A |
| `4'd1` | `VIOL_DROP_VALID` | `vld` deasserted while `transaction_active == 1` and `rdy == 0` | `drop_valid_count` |
| `4'd2` | `VIOL_DATA_CHG` | `data != data_hold` while `transaction_active == 1` and `rdy == 0` | `data_change_count` |
| `4'd3` | `VIOL_TIMEOUT` | `wait_counter >= TIMEOUT_LIMIT` while `rdy == 0` | `timeout_count` |
| `4'd4` | `VIOL_RESET_VALID` | `vld == 1` while `reset_grace_cnt != 0` | `reset_violation_count` |
