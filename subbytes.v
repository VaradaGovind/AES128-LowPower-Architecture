`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: subbytes
// What this does:
// - Applies AES S-Box substitution to all 16 bytes of the 128-bit state.
// - Input:  128-bit AES state
// - Output: 128-bit substituted state
//////////////////////////////////////////////////////////////////////////////////

module subbytes(
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : GEN_SBOX
        sbox u_sbox (
            .in_byte (state_in [127 - i*8 -: 8]),
            .out_byte(state_out[127 - i*8 -: 8])
        );
    end
endgenerate

endmodule