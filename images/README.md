# Simulation Waveforms & Hardware Captures

This directory stores behavioral simulation waveform exports and hardware logic analyzer captures for the Protocol Monitor IP core.

## Waveform Artifacts

| Filename | Source | Description |
| :--- | :--- | :--- |
| `waveform_clean_handshake.png` | GTKWave or Vivado | Valid/Ready handshake sequence under nominal timing (Scenario 0). |
| `waveform_drop_valid.png` | GTKWave or Vivado | Valid deasserted prematurely before handshake, asserting `violation_code` = 1 (Scenario 1). |
| `waveform_data_change.png` | GTKWave or Vivado | Data payload changed while waiting for Ready, asserting `violation_code` = 2 (Scenario 2). |
| `waveform_timeout.png` | GTKWave or Vivado | Handshake wait latency exceeding `TIMEOUT_LIMIT`, asserting `violation_code` = 3 (Scenario 3). |
| `waveform_reset_violation.png` | GTKWave or Vivado | Valid asserted during reset recovery grace window, asserting `violation_code` = 4 (Scenario 4). |
| `ila_hardware_debug.png` | Vivado Hardware Manager | On-chip Integrated Logic Analyzer (ILA) trace captured on ZedBoard hardware. |

## Waveform Export Procedure

1. Launch behavioral simulation in Vivado:
   ```tcl
   launch_simulation
   ```
2. In the waveform viewer, add the monitored interface signals:
   - `clk`, `rst_n`, `vld`, `rdy`, `data`
   - `protocol_violation_sticky`, `violation_code`, `total_handshakes`, `total_violations`
3. Execute the simulation run:
   ```tcl
   run -all
   ```
4. Zoom to the corresponding scenario interval (refer to [docs/verification.md](../docs/verification.md)).
5. Export waveform snapshots via `File → Export → Waveform Image`.
