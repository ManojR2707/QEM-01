`timescale 1ns/1ps

module tb_encoder_frontend;

    reg clk;
    reg rst_n;
    reg encoder_a;
    reg encoder_b;

    wire count_up;
    wire count_down;
    wire invalid_transition;

    encoder_frontend dut (
        .clk(clk),
        .rst_n(rst_n),
        .encoder_a(encoder_a),
        .encoder_b(encoder_b),
        .count_up(count_up),
        .count_down(count_down),
        .invalid_transition(invalid_transition)
    );

    always #10 clk = ~clk;

    task apply_state;
    input [1:0] state;
    begin
        @(negedge clk);
        {encoder_a, encoder_b} = state;

        // Wait for the two synchronizer stages
        repeat (2) @(posedge clk);

        // Wait for decoder to process synchronized state
        @(posedge clk);
        #1;

        $display("Input=%b | UP=%b DOWN=%b INVALID=%b",
                 state, count_up, count_down,
                 invalid_transition);
    end
endtask
    initial begin
        clk = 0;
        rst_n = 0;
        encoder_a = 0;
        encoder_b = 0;

        #25;
        rst_n = 1;

        // Allow synchronizer and decoder to initialize
        repeat (4) @(posedge clk);

        // Forward sequence
        apply_state(2'b01);
        apply_state(2'b11);
        apply_state(2'b10);
        apply_state(2'b00);

        // Reverse sequence
        apply_state(2'b10);
        apply_state(2'b11);
        apply_state(2'b01);
        apply_state(2'b00);

        // Illegal transition
        apply_state(2'b11);

        #20;
        $finish;
    end

endmodule
