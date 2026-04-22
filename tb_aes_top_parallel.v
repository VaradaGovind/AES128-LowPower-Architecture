`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_aes_top_parallel
// What this does:
// - Drives multiple ECB blocks into the duplicated parallel AES top
// - Checks output order and correctness against known-answer vectors
//////////////////////////////////////////////////////////////////////////////////

module tb_aes_top_parallel;

reg         clk;
reg         rst;
reg         start;
reg  [127:0] plaintext;
reg  [127:0] key;
wire [127:0] ciphertext;
wire        done;
wire        busy;
wire        ready;

localparam integer NUM_BLOCKS = 6;

reg [127:0] exp_mem [0:NUM_BLOCKS-1];
integer tx_count;
integer rx_count;
integer errors;
integer timeout_cycles;
integer i;

aes_top_parallel #(
    .N(2),
    .ROB_DEPTH(16),
    .SEQ_W(16)
) dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .plaintext(plaintext),
    .key(key),
    .ciphertext(ciphertext),
    .done(done),
    .busy(busy),
    .ready(ready)
);

// 100 MHz clock
always #5 clk = ~clk;

task submit_block;
    input [127:0] p;
    input [127:0] k;
    input [127:0] exp;
    begin
        while (!ready) begin
            @(posedge clk);
        end

        // Drive inputs on the opposite edge so they are stable before sampling.
        @(negedge clk);

        plaintext = p;
        key       = k;
        start     = 1'b1;

        exp_mem[tx_count] = exp;
        tx_count = tx_count + 1;

        @(posedge clk);
        @(negedge clk);
        start = 1'b0;
    end
endtask

always @(posedge clk) begin
    if (done) begin
        if (ciphertext !== exp_mem[rx_count]) begin
            $display("[ERROR] Block %0d mismatch: got=%h expected=%h", rx_count, ciphertext, exp_mem[rx_count]);
            errors = errors + 1;
        end else begin
            $display("[PASS ] Block %0d ciphertext=%h", rx_count, ciphertext);
        end
        rx_count = rx_count + 1;
    end
end

initial begin
    clk       = 1'b0;
    rst       = 1'b1;
    start     = 1'b0;
    plaintext = 128'h0;
    key       = 128'h0;
    tx_count  = 0;
    rx_count  = 0;
    errors    = 0;
    timeout_cycles = 0;

  // remove X (unknown)Z (high impedance) partially driven buses
    for (i = 0; i < NUM_BLOCKS; i = i + 1)
        exp_mem[i] = 128'h0;
    // Reset
    #25;
    rst = 1'b0;

    // Vector A (FIPS-197 known answer)
    // key       = 000102030405060708090a0b0c0d0e0f
    // plaintext = 00112233445566778899aabbccddeeff
    // expected  = 69c4e0d86a7b0430d8cdb78070b4c55a

    // Vector B (all-zero key/plaintext)
    // key       = 00000000000000000000000000000000
    // plaintext = 00000000000000000000000000000000
    // expected  = 66e94bd4ef8a2c3b884cfa59ca342b2e

    // Submit a mixed stream to exercise dispatch and ordered merge
    submit_block(
        128'h00112233445566778899aabbccddeeff,
        128'h000102030405060708090a0b0c0d0e0f,
        128'h69c4e0d86a7b0430d8cdb78070b4c55a
    );

    submit_block(
        128'h00000000000000000000000000000000,
        128'h00000000000000000000000000000000,
        128'h66e94bd4ef8a2c3b884cfa59ca342b2e
    );

    submit_block(
        128'h00112233445566778899aabbccddeeff,
        128'h000102030405060708090a0b0c0d0e0f,
        128'h69c4e0d86a7b0430d8cdb78070b4c55a
    );

    submit_block(
        128'h00000000000000000000000000000000,
        128'h00000000000000000000000000000000,
        128'h66e94bd4ef8a2c3b884cfa59ca342b2e
    );

    submit_block(
        128'h00112233445566778899aabbccddeeff,
        128'h000102030405060708090a0b0c0d0e0f,
        128'h69c4e0d86a7b0430d8cdb78070b4c55a
    );

    submit_block(
        128'h00000000000000000000000000000000,
        128'h00000000000000000000000000000000,
        128'h66e94bd4ef8a2c3b884cfa59ca342b2e
    );

    // Wait for all outputs
    while (rx_count < NUM_BLOCKS && timeout_cycles < 5000) begin
        @(posedge clk);
        timeout_cycles = timeout_cycles + 1;
    end

    if (rx_count < NUM_BLOCKS) begin
        $display("[ERROR] Timeout waiting for outputs. rx_count=%0d expected=%0d", rx_count, NUM_BLOCKS);
        errors = errors + 1;
    end

    #20;
    $display("==============================================");
    $display("Parallel AES test completed. tx=%0d rx=%0d errors=%0d", tx_count, rx_count, errors);
    if (errors == 0)
        $display("RESULT = PASS");
    else
        $display("RESULT = FAIL");
    $display("==============================================");

    $finish;
end

endmodule
