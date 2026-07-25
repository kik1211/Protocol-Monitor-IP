`timescale 1ns / 1ps

// ============================================================================
// File: tb.v
// Project: Protocol-Monitor-IP
// Description: Self-Checking Testbench for Top-Level Protocol Monitor Verification.
//              Instantiates `top uut` cleanly with valid ports (.clk, .sw, .led)
//              and monitors internal telemetry using hierarchical references.
// ============================================================================

module tb;

    // Stimulus Signals
    reg  clk;
    reg  [7:0] sw;

    // Output Telemetry Wires from DUT
    wire [7:0] led;

    // Instantiate Unit Under Test (UUT) - Connecting ONLY valid top ports
    top uut (
        .clk (clk),
        .sw  (sw),
        .led (led)
    );

    // Hierarchical bindings to internal top / monitor telemetry signals
    wire        protocol_violation_sticky = uut.protocol_violation_sticky;
    wire [3:0]  violation_code            = uut.violation_code;

    wire [31:0] total_violations          = uut.total_violations;
    wire [31:0] total_handshakes          = uut.total_handshakes;

    wire [31:0] latency_last              = uut.latency_last;
    wire [31:0] latency_min               = uut.latency_min;
    wire [31:0] latency_max               = uut.latency_max;

    wire [31:0] window_handshakes         = uut.window_handshakes;
    wire [31:0] throughput_pct            = uut.throughput_pct;

    wire [31:0] drop_valid_count          = uut.drop_valid_count;
    wire [31:0] data_change_count         = uut.data_change_count;
    wire [31:0] timeout_count             = uut.timeout_count;
    wire [31:0] reset_violation_count     = uut.reset_violation_count;

    // Error Tracking Counter
    integer error_count = 0;

    // Override TIMEOUT_LIMIT for fast simulation verification
    defparam uut.u_checker.TIMEOUT_LIMIT = 10;

    // Clock Generation (100 MHz, 10ns Period)
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Wait Helper Task
    task wait_cycles(input integer n);
        integer i;
        begin
            for (i = 0; i < n; i = i + 1)
                @(posedge clk);
        end
    endtask

    // Check Task for Self-Checking Assertions
    task check_condition(input expression, input [256*8-1:0] test_name);
        begin
            if (!expression) begin
                $display("[FAIL] %0t ns - Test Failed: %s", $time, test_name);
                error_count = error_count + 1;
            end else begin
                $display("[PASS] %0t ns - Test Passed: %s", $time, test_name);
            end
        end
    endtask

    // Main Test Stimulus Sequence
    initial begin
        sw = 8'b0000_0000;

        $display("==================================================");
        $display("   STARTING PROTOCOL MONITOR IP SELF-TESTBENCH    ");
        $display("==================================================");

        wait_cycles(4);
        sw[0] = 1'b1;   // Release reset (active-low)
        wait_cycles(4); // Wait through reset grace period (3 cycles)

        // ----------------------------------------------------
        // SCENARIO 0: Clean / Normal Handshake Operations
        // ----------------------------------------------------
        $display("\n--- Running Scenario 0: Normal Handshake Operations ---");
        sw[1]   = 1'b1; // valid = 1
        sw[2]   = 1'b1; // ready = 1
        sw[7:3] = 5'b00001; // data payload
        wait_cycles(5); // 5 successful handshakes
        sw[1]   = 1'b0; // stop valid
        sw[2]   = 1'b0; // stop ready
        wait_cycles(2);

        check_condition(total_handshakes == 5, "Scenario 0: 5 Normal Handshakes Counted");
        check_condition(total_violations == 0, "Scenario 0: Zero Violations in Normal Handshakes");

        // ----------------------------------------------------
        // SCENARIO 1: DROP_VALID Violation (VIOL_DROP_VALID = 1)
        // ----------------------------------------------------
        $display("\n--- Running Scenario 1: DROP_VALID Violation ---");
        sw[1]   = 1'b1; // valid = 1
        sw[2]   = 1'b0; // ready = 0
        sw[7:3] = 5'b00001;
        wait_cycles(2);
        sw[1]   = 1'b0; // Dropping valid before ready!
        wait_cycles(1);

        check_condition(violation_code == 4'd1, "Scenario 1: Live Violation Code 1 (DROP_VALID)");
        check_condition(protocol_violation_sticky == 1'b1, "Scenario 1: Sticky Violation Latched");
        check_condition(drop_valid_count == 1, "Scenario 1: Drop Valid Counter Incremented");
        wait_cycles(2);

        // ----------------------------------------------------
        // SCENARIO 2: DATA_CHANGE Violation (VIOL_DATA_CHG = 2)
        // ----------------------------------------------------
        $display("\n--- Running Scenario 2: DATA_CHANGE Violation ---");
        sw[1]   = 1'b1; // valid = 1
        sw[2]   = 1'b0; // ready = 0
        sw[7:3] = 5'b00010; // data = 2
        wait_cycles(2);
        sw[7:3] = 5'b00101; // Data changed to 5 while waiting!
        wait_cycles(1);

        check_condition(violation_code == 4'd2, "Scenario 2: Live Violation Code 2 (DATA_CHANGE)");
        check_condition(data_change_count == 1, "Scenario 2: Data Change Counter Incremented");
        sw[1]   = 1'b0; // Clean up valid
        wait_cycles(2);

        // ----------------------------------------------------
        // SCENARIO 3: TIMEOUT Violation (VIOL_TIMEOUT = 3)
        // ----------------------------------------------------
        $display("\n--- Running Scenario 3: TIMEOUT Violation ---");
        sw[1]   = 1'b1; // valid = 1
        sw[2]   = 1'b0; // ready = 0
        sw[7:3] = 5'b01001;
        wait_cycles(11); // Exceeds TIMEOUT_LIMIT = 10

        check_condition(timeout_count == 1, "Scenario 3: Timeout Counter Incremented");
        sw[1]   = 1'b0; // Clean up valid
        wait_cycles(2);

        // ----------------------------------------------------
        // SCENARIO 4: RESET Grace Violation (VIOL_RESET_VALID = 4)
        // ----------------------------------------------------
        $display("\n--- Running Scenario 4: RESET Grace Violation ---");
        sw[1]   = 1'b1; // valid = 1
        sw[2]   = 1'b0; // ready = 0
        wait_cycles(2);

        sw[0]   = 1'b0; // Assert active-low reset
        wait_cycles(4);

        sw[0]   = 1'b1; // Release reset while valid is high!
        wait_cycles(1);

        check_condition(violation_code == 4'd4, "Scenario 4: Live Violation Code 4 (RESET_VALID)");
        check_condition(reset_violation_count == 1, "Scenario 4: Reset Violation Counter Incremented");
        sw[1]   = 1'b0;
        wait_cycles(5);

        // ----------------------------------------------------
        // Final Summary Report
        // ----------------------------------------------------
        $display("\n==================================================");
        if (error_count == 0) begin
            $display("   *** ALL VERIFICATION TESTS PASSED (0 ERRORS) ***");
        end else begin
            $display("   *** VERIFICATION FAILED (%0d ERROR(S)) ***", error_count);
        end
        $display("   Total Handshakes : %0d", total_handshakes);
        $display("   Total Violations : %0d", total_violations);
        $display("   Drop Valid Count : %0d", drop_valid_count);
        $display("   Data Change Count: %0d", data_change_count);
        $display("   Timeout Count    : %0d", timeout_count);
        $display("   Reset Violations : %0d", reset_violation_count);
        $display("==================================================");

        $finish;
    end

endmodule
