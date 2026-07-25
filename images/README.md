# Waveform & Hardware Screenshot Placeholders

This directory stores simulation waveform captures and hardware debug screenshots. The following images are referenced in the project documentation. Replace each placeholder with an actual PNG capture from GTKWave or Vivado.

## Expected Images

| Filename | Source | Description |
| :--- | :--- | :--- |
| `waveform_clean_handshake.png` | GTKWave or Vivado | Normal Valid/Ready handshake sequence (Scenario 0). |
| `waveform_drop_valid.png` | GTKWave or Vivado | Valid deasserted before handshake, `violation_code` = 1 (Scenario 1). |
| `waveform_data_change.png` | GTKWave or Vivado | Data payload changed while waiting for Ready, `violation_code` = 2 (Scenario 2). |
| `waveform_timeout.png` | GTKWave or Vivado | `wait_counter` exceeding `TIMEOUT_LIMIT`, `violation_code` = 3 (Scenario 3). |
| `waveform_reset_violation.png` | GTKWave or Vivado | Valid asserted during reset grace period, `violation_code` = 4 (Scenario 4). |
| `ila_hardware_debug.png` | Vivado Hardware Manager | ILA logic analyzer capture from ZedBoard hardware. |

## Capture Instructions

1. Run the simulation in Vivado (`Run Simulation → Run Behavioral Simulation`).
2. In the waveform viewer, add signals: `clk`, `sw`, `led`, `protocol_violation_sticky`, `violation_code`, `total_handshakes`, `total_violations`.
3. Run the simulation to completion (`$finish`).
4. Zoom to the relevant time range for each scenario (see [docs/verification.md](../docs/verification.md) for the timeline).
5. Export each waveform view as a PNG file using `File → Export → Waveform Image`.
6. Save each file into this `images/` directory with the exact filename listed above.
