---
name: Bug Report
about: Create a report to help us fix an RTL, testbench, or constraint issue.
title: '[BUG] '
labels: bug
assignees: ''
---

**Describe the Bug**
A clear and concise description of what the bug is in the RTL, testbench, constraints, or TCL scripts.

**Affected Component**
- [ ] RTL (`rtl/protocol_monitor.v`, `top.v`, etc.)
- [ ] Testbench (`tb/tb.v`)
- [ ] Constraints (`constraints/constraints.xdc`)
- [ ] Build Scripts (`scripts/create_project.tcl`)
- [ ] Documentation (`docs/`)

**To Reproduce**
Steps to reproduce the behavior in Vivado, GTKWave, or ModelSim:
1. Run simulation command '...'
2. Set stimulus inputs to '...'
3. See error in waveform / log at time X ns

**Expected Behavior**
A clear description of what you expected to happen in accordance with the protocol spec.

**Environment & Tools**
- OS: [e.g. Windows 11, Ubuntu 22.04]
- EDA Tool & Version: [e.g. Xilinx Vivado 2022.2, Icarus Verilog 11.0]
- Target Board/FPGA: [e.g. ZedBoard xc7z020clg484-1]

**Screenshots / Waveforms / Log Output**
If applicable, attach GTKWave/Vivado waveform screenshots or console log error snippets.
