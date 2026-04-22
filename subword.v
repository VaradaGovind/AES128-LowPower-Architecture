`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: subword
// What this does:
// - Applies the AES S-Box to all 4 bytes of a 32-bit word.
// - Used in AES key expansion.
//////////////////////////////////////////////////////////////////////////////////

module subword(
    input  wire [31:0] word_in,
    output wire [31:0] word_out
);

sbox s0 (.in_byte(word_in[31:24]), .out_byte(word_out[31:24]));
sbox s1 (.in_byte(word_in[23:16]), .out_byte(word_out[23:16]));
sbox s2 (.in_byte(word_in[15:8]),  .out_byte(word_out[15:8]));
sbox s3 (.in_byte(word_in[7:0]),   .out_byte(word_out[7:0]));

endmodule