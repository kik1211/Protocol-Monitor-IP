# Verification & Simulation Methodology

## 1. Testbench Overview

The testbench ([tb/tb.v](../tb/tb.v)) provides a self-checking verification environment for the `top` module and its internal `protocol_monitor` instance. It drives clock, reset, and switch control signals to exercise normal handshake operations and all four violation scenarios.

### Key Testbench Features

- **Self-Checking Assertions**: `check_condition(expression, test_name)` task prints `[PASS]` or `[FAIL]` and tracks failures.
- **Error Counter**: Integer `error_count` accumulates failed checks. Zero at `$finish` means all tests passed.
- **Timeout Override**: `defparam uut.u_checker.TIMEOUT_LIMIT = 10` reduces the timeout limit from 100 million to 10 cycles for fast simulation.
- **Hierarchical Signal Access**: Internal signals are accessed via `uut.protocol_violation_sticky`, `uut.violation_code`, etc.

---

## 2. Simulation Timeline

| Time (approx.) | Scenario | Stimulus | Expected Observation |
| :---: | :--- | :--- | :--- |
| 50–140 ns | Scenario 0: Clean Handshake | `sw[1]=1`, `sw[2]=1` for 5 cycles | `total_handshakes` = 5; `total_violations` = 0; `violation_code` = 0. |
| 175–190 ns | Scenario 1: Drop Valid | `sw[1]=1`, `sw[2]=0`, wait 2 cycles, then `sw[1]=0` | `violation_code` = 1 (`VIOL_DROP_VALID`); `drop_valid_count` increments; `protocol_violation_sticky` latches to 1. |
| 220–240 ns | Scenario 2: Data Change | `sw[1]=1`, `sw[2]=0`, `sw[7:3]=2`, wait 2 cycles, then `sw[7:3]=5` | `violation_code` = 2 (`VIOL_DATA_CHG`); `data_change_count` increments. |
| 350–370 ns | Scenario 3: Timeout | `sw[1]=1`, `sw[2]=0`, wait 11 cycles (exceeds `TIMEOUT_LIMIT=10`) | `violation_code` = 3 (`VIOL_TIMEOUT`); `timeout_count` increments. |
| 445–460 ns | Scenario 4: Reset Grace | Assert reset (`sw[0]=0`), release while `sw[1]=1` | Reset clears all counters; `violation_code` = 4 (`VIOL_RESET_VALID`); `reset_violation_count` = 1. |

---

## 3. Signal Behavior Notes

### `protocol_violation_sticky`

- Initializes to `0` upon reset release.
- Latches to `1` on the first protocol violation (Scenario 1 at ~175 ns).
- Remains `1` across all subsequent cycles regardless of `violation_code` returning to `0`.
- Can only be cleared by asserting active-low reset (`sw[0] = 0`).

### `violation_code`

- Operates in **live mode**: defaults to `4'd0` (`VIOL_NONE`) every cycle.
- Pulses to the corresponding code (`1`, `2`, `3`, or `4`) only during the exact clock edge when a violation is detected.
- Returns to `0` on the next cycle after the violation event.

### Counter Accumulation and Reset Behavior

- All counters (`total_handshakes`, `total_violations`, `drop_valid_count`, `data_change_count`, `timeout_count`, `reset_violation_count`) accumulate across Scenarios 0 through 3.
- In Scenario 4, active-low reset (`sw[0] = 0`) clears every register to zero, as defined in the reset branch of [protocol_monitor.v](../rtl/protocol_monitor.v) (lines 67–96).
- After reset release, the Reset Grace violation is detected because `vld` (`sw[1]`) is still high. This records `reset_violation_count = 1` and `total_violations = 1`.
- The final simulation log therefore shows post-reset values only: `total_handshakes = 0`, `drop_valid_count = 0`, etc. This is correct behavior.

---

## 4. Throughput Calculation Note

`throughput_pct` remains `0` throughout the entire simulation. This is expected and is **not** a bug.

**Explanation:** The throughput formula is:

```
throughput_pct = (window_handshakes × 100) / WINDOW_SIZE
```

With `WINDOW_SIZE = 1000` and only 5 handshakes completing in ~50 cycles:

```
(5 × 100) / 1000 = 500 / 1000 = 0  (integer truncation from 0.5)
```

Verilog integer division truncates toward zero. The throughput percentage would become nonzero only if more than 10 handshakes completed within a 1000-cycle window.

---

## 5. Error Tracking (`error_count`)

- `error_count` is an integer variable in `tb.v` initialized to `0`.
- Every call to `check_condition(expression, test_name)` evaluates the boolean `expression`. If false, it prints `[FAIL]` and increments `error_count`.
- The final summary block at `$finish` reports `0 ERRORS` when all 10 checks pass.

---

## 6. Waveform Reading Guide

When inspecting waveforms in GTKWave or Vivado:

### Identifying a Successful Handshake

1. Locate a rising `clk` edge.
2. Verify both `vld` (driven by `sw[1]`) and `rdy` (driven by `sw[2]`) are high.
3. `led[7]` (`vld & rdy`) pulses high.
4. `total_handshakes` increments by 1.

### Identifying Protocol Violations

| Violation | What to Look For | `violation_code` |
| :--- | :--- | :---: |
| Drop Valid | `vld` drops from 1 to 0 while `rdy` is 0 and `transaction_active` is 1. | `1` |
| Data Change | `data` bus value changes while `vld` is 1 and `rdy` is 0. | `2` |
| Timeout | `vld` stays 1 and `rdy` stays 0 for more than 10 cycles (simulation override). | `3` |
| Reset Grace | `vld` is 1 immediately after `rst_n` transitions from 0 to 1. | `4` |

In all cases, `protocol_violation_sticky` (`led[4]`) transitions from 0 to 1 and remains latched.

---

## 7. Automated Test Log

The following is the expected simulation output from a passing run:

```
==================================================
   STARTING PROTOCOL MONITOR IP SELF-TESTBENCH
==================================================

--- Running Scenario 0: Normal Handshake Operations ---
[PASS] ... - Test Passed: Scenario 0: 5 Normal Handshakes Counted
[PASS] ... - Test Passed: Scenario 0: Zero Violations in Normal Handshakes

--- Running Scenario 1: DROP_VALID Violation ---
[PASS] ... - Test Passed: Scenario 1: Live Violation Code 1 (DROP_VALID)
[PASS] ... - Test Passed: Scenario 1: Sticky Violation Latched
[PASS] ... - Test Passed: Scenario 1: Drop Valid Counter Incremented

--- Running Scenario 2: DATA_CHANGE Violation ---
[PASS] ... - Test Passed: Scenario 2: Live Violation Code 2 (DATA_CHANGE)
[PASS] ... - Test Passed: Scenario 2: Data Change Counter Incremented

--- Running Scenario 3: TIMEOUT Violation ---
[PASS] ... - Test Passed: Scenario 3: Timeout Counter Incremented

--- Running Scenario 4: RESET Grace Violation ---
[PASS] ... - Test Passed: Scenario 4: Live Violation Code 4 (RESET_VALID)
[PASS] ... - Test Passed: Scenario 4: Reset Violation Counter Incremented

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

> **Note:** The final summary counters reflect post-reset values. Scenario 4 asserts active-low reset, which zeroes all counters. Only the Reset Grace violation recorded after reset release is visible in the final report.
