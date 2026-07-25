// ============================================================================
// File: protocol_monitor.v
// Project: Protocol-Monitor-IP
// Description: Core Parameterized Protocol Checker & Performance Telemetry IP.
//              Monitors Valid/Ready streaming transactions, detects rules violations,
//              and measures latency metrics and sliding-window throughput percentage.
// ============================================================================

`timescale 1ns / 1ps

module protocol_monitor #(
    parameter DATA_WIDTH         = 32,
    parameter COUNTER_W          = 32,
    parameter TIMEOUT_LIMIT      = 100000000,
    parameter WINDOW_SIZE        = 1000,
    parameter RESET_GRACE_CYCLES = 3
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  vld,
    input  wire                  rdy,
    input  wire [DATA_WIDTH-1:0] data,

    output reg                   protocol_violation_sticky,
    output reg  [3:0]            violation_code,

    output reg  [COUNTER_W-1:0]  total_violations,
    output reg  [COUNTER_W-1:0]  total_handshakes,

    output reg  [COUNTER_W-1:0]  latency_last,
    output reg  [COUNTER_W-1:0]  latency_min,
    output reg  [COUNTER_W-1:0]  latency_max,

    output reg  [COUNTER_W-1:0]  window_handshakes,
    output reg  [COUNTER_W-1:0]  throughput_pct,

    output reg  [COUNTER_W-1:0]  drop_valid_count,
    output reg  [COUNTER_W-1:0]  data_change_count,
    output reg  [COUNTER_W-1:0]  timeout_count,
    output reg  [COUNTER_W-1:0]  reset_violation_count
);

    // =========================================================
    // Updated violation codes (NO CODE 3 anymore)
    // =========================================================
    localparam [3:0] VIOL_NONE        = 4'd0;
    localparam [3:0] VIOL_DROP_VALID  = 4'd1;
    localparam [3:0] VIOL_DATA_CHG    = 4'd2;
    localparam [3:0] VIOL_TIMEOUT     = 4'd3;  // shifted
    localparam [3:0] VIOL_RESET_VALID = 4'd4;

    reg [COUNTER_W-1:0]   wait_counter;
    reg [DATA_WIDTH-1:0]  data_hold;
    reg                   transaction_active;

    reg [3:0]             reset_grace_cnt;
    reg                   reset_violation_seen;
    reg                   latency_seen;

    reg [COUNTER_W-1:0]   window_next;
    reg [WINDOW_SIZE-1:0] handshake_hist;

    wire handshake_now    = vld && rdy;
    wire oldest_handshake = handshake_hist[WINDOW_SIZE-1];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            protocol_violation_sticky <= 1'b0;
            violation_code            <= VIOL_NONE;

            total_violations          <= 0;
            total_handshakes          <= 0;

            latency_last              <= 0;
            latency_min               <= 0;
            latency_max               <= 0;

            window_handshakes         <= 0;
            throughput_pct            <= 0;

            drop_valid_count          <= 0;
            data_change_count         <= 0;
            timeout_count             <= 0;
            reset_violation_count     <= 0;

            wait_counter              <= 0;
            data_hold                 <= 0;
            transaction_active        <= 0;

            reset_grace_cnt           <= RESET_GRACE_CYCLES[3:0];
            reset_violation_seen      <= 0;
            latency_seen              <= 0;

            window_next               <= 0;
            handshake_hist            <= 0;
        end
        else begin
            // =====================================================
            // LIVE MODE: default = no violation
            // =====================================================
            violation_code <= VIOL_NONE;

            // =====================================================
            // Throughput window
            // =====================================================
            window_next = window_handshakes;
            if (handshake_now && !oldest_handshake)
                window_next = window_handshakes + 1;
            else if (!handshake_now && oldest_handshake)
                window_next = window_handshakes - 1;

            window_handshakes <= window_next;
            throughput_pct    <= (window_next * 100) / WINDOW_SIZE;
            handshake_hist    <= {handshake_hist[WINDOW_SIZE-2:0], handshake_now};

            // =====================================================
            // Reset grace
            // =====================================================
            if (reset_grace_cnt != 0)
                reset_grace_cnt <= reset_grace_cnt - 1;

            // =====================================================
            // RESET VIOLATION
            // =====================================================
            if (reset_grace_cnt != 0) begin
                if (!reset_violation_seen && vld) begin
                    protocol_violation_sticky <= 1'b1;
                    violation_code            <= VIOL_RESET_VALID;
                    total_violations          <= total_violations + 1;
                    reset_violation_count     <= reset_violation_count + 1;
                    reset_violation_seen      <= 1'b1;
                end
            end
            else begin
                // =================================================
                // TRANSACTION LOGIC
                // =================================================
                if (!transaction_active) begin
                    if (vld && rdy) begin
                        total_handshakes <= total_handshakes + 1;
                        latency_last     <= 0;

                        if (!latency_seen) begin
                            latency_min  <= 0;
                            latency_max  <= 0;
                            latency_seen <= 1;
                        end
                        else begin
                            if (0 < latency_min)
                                latency_min <= 0;
                            if (0 > latency_max)
                                latency_max <= 0;
                        end
                    end
                    else if (vld && !rdy) begin
                        transaction_active <= 1;
                        wait_counter       <= 1;
                        data_hold          <= data;
                    end
                end
                else begin
                    if (vld && rdy) begin
                        total_handshakes <= total_handshakes + 1;
                        latency_last     <= wait_counter;

                        if (!latency_seen) begin
                            latency_min  <= wait_counter;
                            latency_max  <= wait_counter;
                            latency_seen <= 1;
                        end
                        else begin
                            if (wait_counter < latency_min)
                                latency_min <= wait_counter;
                            if (wait_counter > latency_max)
                                latency_max <= wait_counter;
                        end

                        transaction_active <= 0;
                        wait_counter       <= 0;
                    end

                    // ===============================
                    // 1) DROP VALID
                    // ===============================
                    else if (!vld) begin
                        protocol_violation_sticky <= 1'b1;
                        violation_code            <= VIOL_DROP_VALID;
                        total_violations          <= total_violations + 1;
                        drop_valid_count          <= drop_valid_count + 1;

                        transaction_active        <= 0;
                        wait_counter              <= 0;
                    end

                    // ===============================
                    // 2) DATA CHANGE
                    // ===============================
                    else if (data != data_hold) begin
                        protocol_violation_sticky <= 1'b1;
                        violation_code            <= VIOL_DATA_CHG;
                        total_violations          <= total_violations + 1;
                        data_change_count         <= data_change_count + 1;

                        transaction_active        <= 0;
                        wait_counter              <= 0;
                    end

                    // ===============================
                    // 3) TIMEOUT
                    // ===============================
                    else begin
                        if (wait_counter >= TIMEOUT_LIMIT) begin
                            protocol_violation_sticky <= 1'b1;
                            violation_code            <= VIOL_TIMEOUT;
                            total_violations          <= total_violations + 1;
                            timeout_count             <= timeout_count + 1;

                            transaction_active        <= 0;
                            wait_counter              <= 0;
                        end
                        else begin
                            wait_counter <= wait_counter + 1;
                        end
                    end
                end
            end
        end
    end

endmodule
