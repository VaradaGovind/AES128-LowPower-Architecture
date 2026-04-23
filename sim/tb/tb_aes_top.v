`timescale 1ns / 1ps

module tb_aes_top;

reg          clk;
reg          rst;
reg          start;
reg  [127:0] plaintext;
reg  [127:0] key;
wire [127:0] ciphertext;
wire         done;
wire         busy;

localparam [127:0] KAT_KEY       = 128'h000102030405060708090a0b0c0d0e0f;
localparam [127:0] KAT_PLAINTEXT = 128'h00112233445566778899aabbccddeeff;
localparam [127:0] KAT_EXPECTED  = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;

aes_top dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .plaintext(plaintext),
    .key(key),
    .ciphertext(ciphertext),
    .done(done),
    .busy(busy)
);

always #5 clk = ~clk;

initial begin
    clk       = 1'b0;
    rst       = 1'b1;
    start     = 1'b0;
    plaintext = 128'h0;
    key       = 128'h0;

    #20;
    rst = 1'b0;

    key       = KAT_KEY;
    plaintext = KAT_PLAINTEXT;

    #10;
    start = 1'b1;
    #10;
    start = 1'b0;

    wait(done == 1'b1);

    $display("==============================================");
    $display("AES-128 single-core test complete");
    $display("Key        = %h", key);
    $display("Plaintext  = %h", plaintext);
    $display("Ciphertext = %h", ciphertext);
    $display("Expected   = %h", KAT_EXPECTED);
    if (ciphertext == KAT_EXPECTED)
        $display("RESULT     = PASS");
    else
        $display("RESULT     = FAIL");
    $display("==============================================");

    #20;
    $finish;
end

endmodule