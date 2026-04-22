`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: aes_top
// What this does:
// - Clean top-level wrapper for synthesis and simulation.
// - Right now it is just a direct wrapper around aes128_core.
//////////////////////////////////////////////////////////////////////////////////

module aes_top(
    input  wire         clk,
    input  wire         rst,
    input  wire         start,
    input  wire [127:0] plaintext,
    input  wire [127:0] key,
    output wire [127:0] ciphertext,
    output wire         done,
    output wire         busy
);

aes128_core u_core (
    .clk(clk),
    .rst(rst),
    .start(start),
    .plaintext(plaintext),
    .key(key),
    .ciphertext(ciphertext),
    .done(done),
    .busy(busy)
);

endmodule