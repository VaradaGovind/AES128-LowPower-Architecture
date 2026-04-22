`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: key_expand
// What this does:
// - Expands a 128-bit AES key into 11 round keys (AES-128).
// - Output contains round keys rk0 to rk10 packed into one 1408-bit bus.
// - Packing order used here:
//   all_round_keys = {rk0, rk1, rk2, rk3, rk4, rk5, rk6, rk7, rk8, rk9, rk10}
//////////////////////////////////////////////////////////////////////////////////

module key_expand(
    input  wire [127:0] key_in,
    output wire [1407:0] all_round_keys
);

function [31:0] rotword;
    input [31:0] w;
    begin
        // Rotate left by one byte
        rotword = {w[23:0], w[31:24]};
    end
endfunction

function [31:0] rcon_word;
    input [3:0] round_idx;
    begin
        case (round_idx)
            4'd1:  rcon_word = 32'h01000000;
            4'd2:  rcon_word = 32'h02000000;
            4'd3:  rcon_word = 32'h04000000;
            4'd4:  rcon_word = 32'h08000000;
            4'd5:  rcon_word = 32'h10000000;
            4'd6:  rcon_word = 32'h20000000;
            4'd7:  rcon_word = 32'h40000000;
            4'd8:  rcon_word = 32'h80000000;
            4'd9:  rcon_word = 32'h1b000000;
            4'd10: rcon_word = 32'h36000000;
            default: rcon_word = 32'h00000000;
        endcase
    end
endfunction

// 44 words of 32 bits each
wire [31:0] w [0:43];

// Initial 128-bit key = first 4 words
assign w[0] = key_in[127:96];
assign w[1] = key_in[95:64];
assign w[2] = key_in[63:32];
assign w[3] = key_in[31:0];

// SubWord outputs for every RotWord stage
wire [31:0] sw1, sw2, sw3, sw4, sw5, sw6, sw7, sw8, sw9, sw10;

subword u_sw1  (.word_in(rotword(w[3])),  .word_out(sw1));
subword u_sw2  (.word_in(rotword(w[7])),  .word_out(sw2));
subword u_sw3  (.word_in(rotword(w[11])), .word_out(sw3));
subword u_sw4  (.word_in(rotword(w[15])), .word_out(sw4));
subword u_sw5  (.word_in(rotword(w[19])), .word_out(sw5));
subword u_sw6  (.word_in(rotword(w[23])), .word_out(sw6));
subword u_sw7  (.word_in(rotword(w[27])), .word_out(sw7));
subword u_sw8  (.word_in(rotword(w[31])), .word_out(sw8));
subword u_sw9  (.word_in(rotword(w[35])), .word_out(sw9));
subword u_sw10 (.word_in(rotword(w[39])), .word_out(sw10));

// Round 1
assign w[4] = w[0] ^ sw1 ^ rcon_word(4'd1);
assign w[5] = w[1] ^ w[4];
assign w[6] = w[2] ^ w[5];
assign w[7] = w[3] ^ w[6];

// Round 2
assign w[8]  = w[4] ^ sw2 ^ rcon_word(4'd2);
assign w[9]  = w[5] ^ w[8];
assign w[10] = w[6] ^ w[9];
assign w[11] = w[7] ^ w[10];

// Round 3
assign w[12] = w[8]  ^ sw3 ^ rcon_word(4'd3);
assign w[13] = w[9]  ^ w[12];
assign w[14] = w[10] ^ w[13];
assign w[15] = w[11] ^ w[14];

// Round 4
assign w[16] = w[12] ^ sw4 ^ rcon_word(4'd4);
assign w[17] = w[13] ^ w[16];
assign w[18] = w[14] ^ w[17];
assign w[19] = w[15] ^ w[18];

// Round 5
assign w[20] = w[16] ^ sw5 ^ rcon_word(4'd5);
assign w[21] = w[17] ^ w[20];
assign w[22] = w[18] ^ w[21];
assign w[23] = w[19] ^ w[22];

// Round 6
assign w[24] = w[20] ^ sw6 ^ rcon_word(4'd6);
assign w[25] = w[21] ^ w[24];
assign w[26] = w[22] ^ w[25];
assign w[27] = w[23] ^ w[26];

// Round 7
assign w[28] = w[24] ^ sw7 ^ rcon_word(4'd7);
assign w[29] = w[25] ^ w[28];
assign w[30] = w[26] ^ w[29];
assign w[31] = w[27] ^ w[30];

// Round 8
assign w[32] = w[28] ^ sw8 ^ rcon_word(4'd8);
assign w[33] = w[29] ^ w[32];
assign w[34] = w[30] ^ w[33];
assign w[35] = w[31] ^ w[34];

// Round 9
assign w[36] = w[32] ^ sw9 ^ rcon_word(4'd9);
assign w[37] = w[33] ^ w[36];
assign w[38] = w[34] ^ w[37];
assign w[39] = w[35] ^ w[38];

// Round 10
assign w[40] = w[36] ^ sw10 ^ rcon_word(4'd10);
assign w[41] = w[37] ^ w[40];
assign w[42] = w[38] ^ w[41];
assign w[43] = w[39] ^ w[42];

// Pack all round keys
assign all_round_keys = {
    w[0],  w[1],  w[2],  w[3],   // rk0
    w[4],  w[5],  w[6],  w[7],   // rk1
    w[8],  w[9],  w[10], w[11],  // rk2
    w[12], w[13], w[14], w[15],  // rk3
    w[16], w[17], w[18], w[19],  // rk4
    w[20], w[21], w[22], w[23],  // rk5
    w[24], w[25], w[26], w[27],  // rk6
    w[28], w[29], w[30], w[31],  // rk7
    w[32], w[33], w[34], w[35],  // rk8
    w[36], w[37], w[38], w[39],  // rk9
    w[40], w[41], w[42], w[43]   // rk10
};

endmodule