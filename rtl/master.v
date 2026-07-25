// ============================================================================
// File: master.v
// Project: Protocol-Monitor-IP
// Description: Master Producer module mapping switch inputs sw[7:3] into 32-bit
//              payload data and sw[1] into valid output.
// ============================================================================

`timescale 1ns / 1ps

module master(
    input  wire [7:0]  sw,
    output wire        valid,
    output wire [31:0] data
);

    assign valid = sw[1];

    // 5-bit data from SW7:SW3, padded to 32 bits
    assign data  = {27'd0, sw[7:3]};

endmodule
