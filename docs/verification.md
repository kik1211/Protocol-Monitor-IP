# Verification & Simulation Methodology

## 1. Testbench Overview
The testbench ([tb/tb.v](file:///a:/hackfest/sandisk/protocol_monitor7/protocol_monitor6/Protocol-Monitor-IP/tb/tb.v)) provides a self-checking verification environment for `top` and `protocol_monitor`. It drives clock, reset, and switch control lines to simulate both normal operations and error scenarios.

---

## 2. Simulation Timeline

The following timeline details the sequential execution of verification test scenarios in `tb.v` alongside observed hardware responses:

| Time (approx.) | Test Scenario | Stimulus Driven | Expected Observation |
| :---: | :--- | :--- | :--- |
| **50–140 ns** | Clean Handshake | `sw[1]=1` (`vld`), `sw[2]=1` (`rdy`) for 5 cycles | `total_handshakes` increments to 5; `total_violations = 0`; `violation_code = 0`. |
| **175–190 ns** | Drop VALID | `sw[1]=1`, `sw[2]=0`, wait 2 cycles, `sw[1]=0` | `violation_code = 1` (`VIOL_DROP_VALID`); `drop_valid_count` increments; `protocol_violation_sticky` latches to `1`. |
| **220–240 ns** | Data Change | `sw[1]=1`, `sw[2]=0`, `sw[7:3]=2`, wait 2 cycles, `sw[7:3]=5` | `violation_code = 2` (`VIOL_DATA_CHG`); `data_change_count` increments. |
| **350–370 ns** | Timeout | `sw[1]=1`, `sw[2]=0`, wait 11 cycles (`TIMEOUT_LIMIT=10`) | `violation_code = 3` (`VIOL_TIMEOUT`); `timeout_count` increments. |
| **445–460 ns** | Reset Grace Violation | Assert reset (`sw[0]=0`), release reset while `sw[1]=1` | Reset clears all previous counters; `violation_code = 4` (`VIOL_RESET_VALID`); `reset_violation_count = 1`. |

---

## 3. Verification & Signal Behavior Notes

### `protocol_violation_sticky` Behavior
- The sticky violation signal (`protocol_violation_sticky`) initializes to `0` upon reset release.
- When any protocol violation occurs (Scenario 1 at ~175 ns), `protocol_violation_sticky` latches to `1` and remains `1` across subsequent clock cycles.
- It can **only** be deasserted by asserting active-low system reset (`sw[0] = 0`), as observed at 445 ns.

### `violation_code` Transitions
- `violation_code` operates in **live mode**. It defaults to `4'd0` (`VIOL_NONE`) on every clock cycle unless an active violation occurs on that exact clock edge.
- When an error is detected, `violation_code` pulses to the corresponding non-zero code (`1` for Drop Valid, `2` for Data Change, `3` for Timeout, `4` for Reset Grace) for the cycle duration of the violation event.

### Counter Accumulation & Reset Effect
- Counters (`total_handshakes`, `drop_valid_count`, `data_change_count`, `timeout_count`, `total_violations`) accumulate sequentially during Scenarios 0 through 3.
- In Scenario 4 (445 ns), system reset (`sw[0] = 0`) is asserted. As defined in [protocol_monitor.v](file:///a:/hackfest/sandisk/protocol_monitor7/protocol_monitor6/Protocol-Monitor-IP/rtl/protocol_monitor.v#L58-L88), active-low reset clears all registers and counters to 0.
- Following reset release while `vld == 1`, Scenario 4 records a single Reset Grace violation (`reset_violation_count = 1`, `total_violations = 1`), which is reflected in the final simulation log output at `$finish`.

---

## 4. Throughput Calculation Note

* **Observed Behavior**: `throughput_pct` remains `0%` throughout the simulation.
* **Explanation**: `throughput_pct` calculates integer percentage throughput over a sliding window of `WINDOW_SIZE` cycles (`WINDOW_SIZE = 1000` cycles = 10,000 ns). The default simulation duration is ~500 ns (50 cycles), and only 5 handshakes occur:
  $$\text{throughput\_pct} = \frac{5 \times 100}{1000} = \frac{500}{1000} = 0.5\% \xrightarrow{\text{integer truncation}} 0\%$$
* **Conclusion**: This is expected mathematical behavior for integer division in Verilog and is **NOT** a hardware bug.

---

## 5. Testbench Error Tracking (`error_count`)

* **Definition**: `error_count` is an integer variable declared inside `tb.v` to track verification assertion failures.
* **Mechanism**: Every test condition invokes `check_condition(expression, test_name)`. If `expression` evaluates to `0` (false), `check_condition` prints a `[FAIL]` message and increments `error_count = error_count + 1`.
* **Final Value**: In a successful test run, all 10 checking conditions evaluate to true, resulting in `error_count = 0` and printing `*** ALL VERIFICATION TESTS PASSED (0 ERRORS) ***`.

---

## 6. How to Read the Waveforms

When inspecting GTKWave or Vivado Hardware Manager ILA captures:

1. **Identifying a Successful Handshake**:
   - Locate the `clk` rising edge.
   - Verify both `vld` (`sw[1]`) and `rdy` (`sw[2]`) are high (`1`).
   - Observe `led[7]` (`v & r`) pulsing high and `total_handshakes` incrementing.

2. **Identifying a Protocol Violation**:
   - **Drop VALID**: Observe `vld` dropping from `1` to `0` while `rdy` is `0`. `violation_code` pulses to `1`.
   - **Data Change**: Observe `data` bus changing value while `vld` is `1` and `rdy` is `0`. `violation_code` pulses to `2`.
   - **Timeout**: Observe `vld` remaining `1` and `rdy` remaining `0` for >10 cycles. `violation_code` pulses to `3`.
   - **Reset Grace**: Observe `vld` high immediately after `rst_n` (`sw[0]`) transitions from `0` to `1`. `violation_code` pulses to `4`.
   - In all violation cases, `protocol_violation_sticky` (`led[4]`) transitions from `0` to `1` and stays latched high.

---

## 7. Automated Test Log Matrix

```
==================================================
   STARTING PROTOCOL MONITOR IP SELF-TESTBENCH    
==================================================

--- Running Scenario 0: Normal Handshake Operations ---
[PASS] 160000 ps - Test Passed: Scenario 0: 5 Normal Handshakes Counted
[PASS] 160000 ps - Test Passed: Scenario 0: Zero Violations in Normal Handshakes

--- Running Scenario 1: DROP_VALID Violation ---
[PASS] 210000 ps - Test Passed: Scenario 1: Live Violation Code 1 (DROP_VALID)
[PASS] 210000 ps - Test Passed: Scenario 1: Sticky Violation Latched
[PASS] 210000 ps - Test Passed: Scenario 1: Drop Valid Counter Incremented

--- Running Scenario 2: DATA_CHANGE Violation ---
[PASS] 280000 ps - Test Passed: Scenario 2: Live Violation Code 2 (DATA_CHANGE)
[PASS] 280000 ps - Test Passed: Scenario 2: Data Change Counter Incremented

--- Running Scenario 3: TIMEOUT Violation ---
[PASS] 430000 ps - Test Passed: Scenario 3: Timeout Counter Incremented

--- Running Scenario 4: RESET Grace Violation ---
[PASS] 520000 ps - Test Passed: Scenario 4: Live Violation Code 4 (RESET_VALID)
[PASS] 520000 ps - Test Passed: Scenario 4: Reset Violation Counter Incremented

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
