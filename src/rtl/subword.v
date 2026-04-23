`timescale 1ns / 1ps

module subword(
    input  wire [31:0] word_in,
    output wire [31:0] word_out
);

sbox u_sbox0 (.in_byte(word_in[31:24]), .out_byte(word_out[31:24]));
sbox u_sbox1 (.in_byte(word_in[23:16]), .out_byte(word_out[23:16]));
sbox u_sbox2 (.in_byte(word_in[15:8]),  .out_byte(word_out[15:8]));
sbox u_sbox3 (.in_byte(word_in[7:0]),   .out_byte(word_out[7:0]));

endmodule