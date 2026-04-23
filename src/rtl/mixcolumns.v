`timescale 1ns / 1ps

module mixcolumns(
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

function [7:0] xtime2;
    input [7:0] x;
    begin
        xtime2 = x[7] ? ((x << 1) ^ 8'h1b) : (x << 1);
    end
endfunction

function [7:0] xtime3;
    input [7:0] x;
    begin
        xtime3 = xtime2(x) ^ x;
    end
endfunction

function [31:0] mix_one_column;
    input [31:0] col;
    reg [7:0] s0;
    reg [7:0] s1;
    reg [7:0] s2;
    reg [7:0] s3;
    reg [7:0] r0;
    reg [7:0] r1;
    reg [7:0] r2;
    reg [7:0] r3;
    begin
        s0 = col[31:24];
        s1 = col[23:16];
        s2 = col[15:8];
        s3 = col[7:0];

        r0 = xtime2(s0) ^ xtime3(s1) ^ s2 ^ s3;
        r1 = s0 ^ xtime2(s1) ^ xtime3(s2) ^ s3;
        r2 = s0 ^ s1 ^ xtime2(s2) ^ xtime3(s3);
        r3 = xtime3(s0) ^ s1 ^ s2 ^ xtime2(s3);

        mix_one_column = {r0, r1, r2, r3};
    end
endfunction

assign state_out[127:96] = mix_one_column(state_in[127:96]);
assign state_out[95:64]  = mix_one_column(state_in[95:64]);
assign state_out[63:32]  = mix_one_column(state_in[63:32]);
assign state_out[31:0]   = mix_one_column(state_in[31:0]);

endmodule