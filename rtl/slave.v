// ============================================================================
// File: slave.v
// Project: Protocol-Monitor-IP
// Description: Slave Consumer module mapping switch input sw[2] into ready output.
// ============================================================================

`timescale 1ns / 1ps

module slave(
    input  wire [7:0] sw,
    output wire       ready
);

    assign ready = sw[2];

endmodule
