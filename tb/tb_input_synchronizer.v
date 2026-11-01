`timescale 1ns/1ps

module tb_input_synchronizer;

    reg clk;
    reg rst_n;
    reg encoder_a;
    reg encoder_b;

    wire enc_a_sync;
    wire enc_b_sync;

    input_synchronizer dut (
        .clk(clk),
        .rst_n(rst_n),
        .encoder_a(encoder_a),
        .encoder_b(encoder_b),
        .enc_a_sync(enc_a_sync),
        .enc_b_sync(enc_b_sync)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        encoder_a = 0;
        encoder_b = 0;

        #25;
        rst_n = 1;

        // Change asynchronous inputs
        #7;
        encoder_a = 1;
        encoder_b = 1;

        #60;

        encoder_a = 0;
        encoder_b = 1;

        #60;

        $finish;
    end

    initial begin
        $monitor("Time=%0t | A=%b B=%b | A_sync=%b B_sync=%b",
                 $time, encoder_a, encoder_b,
                 enc_a_sync, enc_b_sync);
    end

endmodule
