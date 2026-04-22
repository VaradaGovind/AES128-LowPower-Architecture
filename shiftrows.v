`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: shiftrows
// What this does:
// - Performs the AES ShiftRows transformation.
// - AES state is treated as 16 bytes arranged in a 4x4 matrix.
// - Row 0: no shift
// - Row 1: left shift by 1 byte
// - Row 2: left shift by 2 bytes
// - Row 3: left shift by 3 bytes
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
// FIXED ShiftRows (aligned with MixColumns implementation)
//////////////////////////////////////////////////////////////////////////////////

module shiftrows(
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

// Extract bytes
wire [7:0] b[0:15];

genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin
        assign b[i] = state_in[127 - i*8 -: 8];
    end
endgenerate

// Correct AES row shifts (column-major assumption)
assign state_out = {
    b[0],  b[5],  b[10], b[15],
    b[4],  b[9],  b[14], b[3],
    b[8],  b[13], b[2],  b[7],
    b[12], b[1],  b[6],  b[11]
};

endmodule

