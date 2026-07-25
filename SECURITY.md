# Security Policy

## Supported Versions

| Version | Supported |
| :--- | :---: |
| 1.0.x | ✅ |
| < 1.0.0 | ❌ |

## Reporting a Vulnerability

This is a single-maintainer open-source FPGA project. If you discover a critical RTL flaw, a logic vulnerability that could cause incorrect protocol assertion behavior, or a design issue that could lead to unexpected hardware states:

1. **Do not** open a public GitHub issue.
2. Create a **private GitHub Security Advisory** on this repository. GitHub provides this feature under the **Security** tab → **Advisories** → **New draft security advisory**.
3. Include:
   - A description of the vulnerability.
   - Affected files and versions.
   - Steps to reproduce (simulation commands, stimulus, expected vs. actual behavior).
   - Any proposed fix, if available.

## Response Timeline

- **Acknowledgment**: Within 7 days.
- **Assessment**: Within 14 days.
- **Fix and disclosure**: Within 30 days of confirmed vulnerability, via a patch release.

## Scope

This policy covers the RTL design files, testbench, constraint files, and build scripts in this repository. It does not cover third-party EDA tools (Vivado, Icarus Verilog) or board-level hardware issues.
