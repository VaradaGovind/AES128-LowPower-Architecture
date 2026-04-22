`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: aes128_core
// What this does:
// - Sequential AES-128 encryption core
// - Accepts plaintext and key
// - Uses one round per clock cycle
// - Interface:
//   clk, rst, start
//   plaintext, key
//   ciphertext, done, busy
//
// Operation:
//   Cycle 0: on start, perform initial AddRoundKey using rk0
//   Cycles 1-9: perform normal AES rounds
//   Cycle 10: perform final round and assert done
//////////////////////////////////////////////////////////////////////////////////

module aes128_core(
    input  wire         clk,
    input  wire         rst,
    input  wire         start,
    input  wire [127:0] plaintext,
    input  wire [127:0] key,
    output reg  [127:0] ciphertext,
    output reg          done,
    output reg          busy
);

wire [1407:0] all_round_keys;

// Expand the input key into 11 round keys
key_expand u_key_expand (
    .key_in(key),
    .all_round_keys(all_round_keys)
);

// Unpack round keys
wire [127:0] rk0  = all_round_keys[1407:1280];
wire [127:0] rk1  = all_round_keys[1279:1152];
wire [127:0] rk2  = all_round_keys[1151:1024];
wire [127:0] rk3  = all_round_keys[1023:896];
wire [127:0] rk4  = all_round_keys[895:768];
wire [127:0] rk5  = all_round_keys[767:640];
wire [127:0] rk6  = all_round_keys[639:512];
wire [127:0] rk7  = all_round_keys[511:384];
wire [127:0] rk8  = all_round_keys[383:256];
wire [127:0] rk9  = all_round_keys[255:128];
wire [127:0] rk10 = all_round_keys[127:0];

// Internal state register
reg [127:0] state_reg;

// Tracks current round number:
// 1 to 9 = normal rounds
// 10     = final round
reg [3:0] round_ctr;

// Select round key for normal rounds
reg [127:0] current_round_key;

always @(*) begin
    case (round_ctr)
        4'd1: current_round_key = rk1;
        4'd2: current_round_key = rk2;
        4'd3: current_round_key = rk3;
        4'd4: current_round_key = rk4;
        4'd5: current_round_key = rk5;
        4'd6: current_round_key = rk6;
        4'd7: current_round_key = rk7;
        4'd8: current_round_key = rk8;
        4'd9: current_round_key = rk9;
        default: current_round_key = 128'h0;
    endcase
end

wire [127:0] normal_round_out;
wire [127:0] final_round_out;

aes_round u_aes_round (
    .state_in(state_reg),
    .round_key(current_round_key),
    .state_out(normal_round_out)
);

aes_final_round u_aes_final_round (
    .state_in(state_reg),
    .round_key(rk10),
    .state_out(final_round_out)
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state_reg   <= 128'h0;
        ciphertext  <= 128'h0;
        round_ctr   <= 4'd0;
        done        <= 1'b0;
        busy        <= 1'b0;
    end
    else begin
        // done is a one-cycle pulse
        done <= 1'b0;

        // Start a fresh encryption when idle
        if (start && !busy) begin
            // Initial AddRoundKey
            state_reg <= plaintext ^ rk0;
            round_ctr <= 4'd1;
            busy      <= 1'b1;
        end
        else if (busy) begin
            if (round_ctr >= 4'd1 && round_ctr <= 4'd9) begin
                // Perform one normal round per clock
                state_reg <= normal_round_out;
                round_ctr <= round_ctr + 4'd1;
            end
            else if (round_ctr == 4'd10) begin
                // Final round, store output, finish operation
                ciphertext <= final_round_out;
                busy       <= 1'b0;
                done       <= 1'b1;
                round_ctr  <= 4'd0;
            end
        end
    end
end

endmodule