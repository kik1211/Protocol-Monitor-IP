# Waveform & Hardware Screenshots Directory

This directory contains placeholders for simulation waveform captures and hardware debug screenshots. Insert actual PNG image files here when captured from GTKWave or Vivado Hardware Manager.

## Image References & Placeholders:

1. **Clean Handshake**: `images/waveform_clean_handshake.png`  
   *[Placeholder: Simulation waveform showing normal valid/ready handshake sequence]*

2. **Drop VALID**: `images/waveform_drop_valid.png`  
   *[Placeholder: Simulation waveform showing premature valid deassertion and violation_code = 1]*

3. **Data Change**: `images/waveform_data_change.png`  
   *[Placeholder: Simulation waveform showing data mutation while waiting for ready and violation_code = 2]*

4. **Timeout Violation**: `images/waveform_timeout.png`  
   *[Placeholder: Simulation waveform showing wait_counter exceeding TIMEOUT_LIMIT and violation_code = 3]*

5. **Reset Grace Violation**: `images/waveform_reset_violation.png`  
   *[Placeholder: Simulation waveform showing valid asserted during reset grace period and violation_code = 4]*

6. **ILA Hardware Debug**: `images/ila_hardware_debug.png`  
   *[Placeholder: Vivado Hardware Manager ILA logic analyzer capture on ZedBoard]*
