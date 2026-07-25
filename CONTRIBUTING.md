# Contributing to Protocol Monitor IP

Thank you for your interest in contributing to the **Protocol Monitor IP** open-source project! We welcome contributions from FPGA engineers, verification specialists, RTL architects, and technical writers.

---

## 1. Development & Git Workflow

1. **Fork the Repository**: Create your personal fork of the repository on GitHub.
2. **Clone your Fork**:
   ```bash
   git clone https://github.com/your-username/Protocol-Monitor-IP.git
   cd Protocol-Monitor-IP
   ```
3. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Make & Test your Changes**: Ensure all simulations pass locally in Vivado or open-source Verilog tools (Icarus Verilog).
5. **Commit your Changes**: Follow the Commit Message Guidelines outlined below.
6. **Push & Open a Pull Request**: Push your branch to GitHub and submit a PR against the `main` branch.

---

## 2. RTL Coding Style & Guidelines

When contributing Verilog/SystemVerilog RTL or testbench code:

- **Language Standard**: IEEE 1364-2001 Verilog for synthesizable RTL modules.
- **Naming Conventions**:
  - Module names: `lowercase_with_underscores` (e.g. `protocol_monitor`).
  - Signal names: `lowercase_with_underscores` (e.g. `violation_code`, `total_handshakes`).
  - Active-low signals: Must end with `_n` (e.g. `rst_n`).
  - Parameters: `UPPERCASE_WITH_UNDERSCORES` (e.g. `DATA_WIDTH`, `TIMEOUT_LIMIT`).
- **File Headers**: Every new `.v`, `.sv`, or `.xdc` file must begin with a standard header comment block stating file name, project name, author, and description.
- **Procedural Assignments**: Always use non-blocking assignments (`<=`) for sequential logic inside `always @(posedge clk)` blocks.

---

## 3. Pull Request Process

1. Ensure your code does not break existing functional test scenarios in `tb/tb.v`.
2. Update relevant documentation in `docs/` or `README.md` if adding or modifying ports, parameters, or features.
3. Reference any related GitHub issue numbers in your PR description (e.g. `Fixes #12`).
4. Maintain clean commit history. Squashing minor fixup commits before submitting a PR is encouraged.

---

## 4. Commit Message Guidelines

We follow Conventional Commits formatting:

```
<type>(<scope>): <short summary>

[optional body description]
```

### Types:
- `feat`: A new RTL module, parameter, or functionality.
- `fix`: A bug fix in RTL, testbench, constraints, or scripts.
- `docs`: Documentation updates (README, docs/*.md).
- `test`: Adding or modifying verification testbenches.
- `refactor`: RTL or script organization changes that do not alter functionality.

### Example:
```
feat(monitor): add clear_error input port to deassert sticky flag

Adds an active-high clear_error input port allowing host software to deassert
protocol_violation_sticky without performing a full chip reset. Updated tb.v.
```
