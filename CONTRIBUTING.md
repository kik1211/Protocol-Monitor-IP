# Contributing to Protocol Monitor IP

Thank you for your interest in contributing. This project welcomes contributions from FPGA engineers, verification engineers, and technical writers.

---

## 1. Development Workflow

1. **Fork** this repository on GitHub.
2. **Clone** your fork:
   ```bash
   git clone https://github.com/<your-username>/Protocol-Monitor-IP.git
   cd Protocol-Monitor-IP
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Make and test your changes.** Verify that the self-checking testbench passes in Vivado or Icarus Verilog before submitting.
5. **Commit** using the guidelines below.
6. **Push and open a Pull Request** against the `main` branch.

---

## 2. Coding Style

### Verilog RTL

- **Standard**: IEEE 1364-2001 Verilog for all synthesizable modules.
- **Module names**: `lowercase_with_underscores` (e.g. `protocol_monitor`).
- **Signal names**: `lowercase_with_underscores` (e.g. `violation_code`, `total_handshakes`).
- **Active-low signals**: Suffix with `_n` (e.g. `rst_n`).
- **Parameters**: `UPPERCASE_WITH_UNDERSCORES` (e.g. `DATA_WIDTH`, `TIMEOUT_LIMIT`).
- **Sequential logic**: Use non-blocking assignments (`<=`) inside `always @(posedge clk)` blocks.
- **File headers**: Every `.v` or `.xdc` file must include a header comment block with file name, project name, and description.

### Documentation

- Use relative links in Markdown files (e.g. `[architecture.md](docs/architecture.md)`), not absolute `file:///` paths.
- Signal names in prose should use backtick formatting (e.g. `violation_code`).

---

## 3. Pull Request Process

1. Ensure the self-checking testbench (`tb/tb.v`) reports `0 ERRORS`.
2. Update relevant documentation in `docs/` or `README.md` if you add or modify ports, parameters, or features.
3. Reference related issue numbers in your PR description (e.g. `Fixes #12`).
4. Squash minor fixup commits before submitting.

---

## 4. Commit Message Guidelines

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short summary>

[optional body]
```

### Types

| Type | Use For |
| :--- | :--- |
| `feat` | New RTL modules, parameters, or functionality |
| `fix` | Bug fixes in RTL, testbench, constraints, or scripts |
| `docs` | Documentation changes |
| `test` | Testbench additions or modifications |
| `refactor` | Code organization changes with no functional impact |

### Example

```
feat(monitor): add clear_error input port

Adds an active-high clear_error input allowing the host to deassert
protocol_violation_sticky without a full chip reset.
```
