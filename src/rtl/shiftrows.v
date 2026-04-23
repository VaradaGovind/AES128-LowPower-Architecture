`timescale 1ns / 1ps

module shiftrows(
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

wire [7:0] b [0:15];

genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : gen_extract
        assign b[i] = state_in[127 - i * 8 -: 8];
    end
endgenerate

assign state_out = {
    b[0],  b[5],  b[10], b[15],
    b[4],  b[9],  b[14], b[3],
    b[8],  b[13], b[2],  b[7],
    b[12], b[1],  b[6],  b[11]
};

endmodule

