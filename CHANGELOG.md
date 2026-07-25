# Changelog

All notable changes to the **Protocol Monitor IP** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-07-26

### Added
- **RTL Architecture**: Parameterized core protocol monitor (`rtl/protocol_monitor.v`) enforcing Valid/Ready streaming protocol assertions.
- **Rule Enforcement**: Real-time hardware assertion checking for Drop Valid (`VIOL_DROP_VALID`), Data Change during wait (`VIOL_DATA_CHG`), Timeout (`VIOL_TIMEOUT`), and Reset Grace (`VIOL_RESET_VALID`) violations.
- **Performance Telemetry**: Cycle-accurate minimum, maximum, and last latency measurement registers alongside a 1000-cycle sliding-window throughput percentage calculator.
- **Top-Level FPGA Demo**: Hardware wrapper (`rtl/top.v`) and ZedBoard XDC constraints (`constraints/constraints.xdc`) mapping monitor status to physical switches (`sw[7:0]`) and LEDs (`led[7:0]`).
- **On-Chip Debugging**: Integrated Xilinx Logic Analyzer (`u_ila_0`) configuration in `constraints/constraints.xdc` for Vivado Hardware Manager probing.
- **Automated Verification**: Self-checking testbench (`tb/tb.v`) exercising normal handshakes and all 4 violation scenarios with automated PASS/FAIL reporting.
- **Automated Build Scripts**: Vivado batch build TCL script (`scripts/create_project.tcl`).
- **Documentation Suite**: Comprehensive documentation suite including `docs/architecture.md`, `docs/protocol_rules.md`, `docs/integration_guide.md`, and `docs/verification.md`.
