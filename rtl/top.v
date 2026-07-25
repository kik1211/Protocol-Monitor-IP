// ============================================================================
// File: top.v
// Project: Protocol-Monitor-IP
// Description: Hardware Top-Level Wrapper module connecting board switches sw[7:0]
//              and LEDs led[7:0] to master, slave, and protocol_monitor IP.
//              Includes mark_debug attributes for Xilinx ILA integration.
// ============================================================================

`timescale 1ns / 1ps

module top(
    input  wire       clk,
    input  wire [7:0] sw,
    output wire [7:0] led
);

    // =========================================
    // Internal signals
    // =========================================
    wire v;
    wire r;
    wire [31:0] d;

    wire rst_n = sw[0];

    // =========================================
    // Debug signals (for ILA)
    // =========================================
    (* mark_debug = "true" *) wire dbg_v = v;
    (* mark_debug = "true" *) wire dbg_r = r;
    (* mark_debug = "true" *) wire [31:0] dbg_d = d;

    // Monitor outputs (internal only)
    (* mark_debug = "true" *) wire protocol_violation_sticky;
    (* mark_debug = "true" *) wire [3:0] violation_code;

    (* mark_debug = "true" *) wire [31:0] total_violations;
    (* mark_debug = "true" *) wire [31:0] total_handshakes;
    (* mark_debug = "true" *) wire [31:0] latency_last;
    (* mark_debug = "true" *) wire [31:0] latency_min;
    (* mark_debug = "true" *) wire [31:0] latency_max;
    (* mark_debug = "true" *) wire [31:0] window_handshakes;
    (* mark_debug = "true" *) wire [31:0] throughput_pct;

    (* mark_debug = "true" *) wire [31:0] drop_valid_count;
    (* mark_debug = "true" *) wire [31:0] data_change_count;
    (* mark_debug = "true" *) wire [31:0] timeout_count;
    (* mark_debug = "true" *) wire [31:0] reset_violation_count;

    // =========================================
    // Modules
    // =========================================
    master u_master (
        .sw   (sw),
        .valid(v),
        .data (d)
    );

    slave u_slave (
        .sw   (sw),
        .ready(r)
    );

    protocol_monitor u_checker (
        .clk                      (clk),
        .rst_n                    (rst_n),
        .vld                      (v),
        .rdy                      (r),
        .data                     (d),

        .protocol_violation_sticky(protocol_violation_sticky),
        .violation_code           (violation_code),

        .total_violations         (total_violations),
        .total_handshakes         (total_handshakes),

        .latency_last             (latency_last),
        .latency_min              (latency_min),
        .latency_max              (latency_max),

        .window_handshakes        (window_handshakes),
        .throughput_pct           (throughput_pct),

        .drop_valid_count         (drop_valid_count),
        .data_change_count        (data_change_count),
        .timeout_count            (timeout_count),
        .reset_violation_count    (reset_violation_count)
    );

    // =========================================
    // LED mapping
    // =========================================
    assign led[3:0] = violation_code;          // current violation
    assign led[4]   = protocol_violation_sticky; // any violation happened
    assign led[5]   = v;                       // VALID
    assign led[6]   = r;                       // READY
    assign led[7]   = v & r;                   // HANDSHAKE

endmodule
