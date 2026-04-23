`timescale 1ns / 1ps

module aes_final_round(
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    output wire [127:0] state_out
);

wire [127:0] sb_out;
wire [127:0] sr_out;

subbytes u_subbytes (
    .state_in(state_in),
    .state_out(sb_out)
);

shiftrows u_shiftrows (
    .state_in(sb_out),
    .state_out(sr_out)
);

addroundkey u_addroundkey (
    .state_in(sr_out),
    .round_key(round_key),
    .state_out(state_out)
);

endmodule
