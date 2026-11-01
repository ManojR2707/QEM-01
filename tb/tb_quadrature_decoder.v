`timescale 1ns/1ps

module tb_quadrature_decoder;

    reg clk;
    reg rst_n;
    reg enc_a_sync;
    reg enc_b_sync;

    wire count_up;
    wire count_down;
    wire invalid_transition;

    quadrature_decoder dut (
        .clk(clk),
        .rst_n(rst_n),
        .enc_a_sync(enc_a_sync),
        .enc_b_sync(enc_b_sync),
        .count_up(count_up),
        .count_down(count_down),
        .invalid_transition(invalid_transition)
    );

    always #10 clk = ~clk;

    task apply_state;
        input [1:0] state;
        begin
            @(negedge clk);
            {enc_a_sync, enc_b_sync} = state;
            @(posedge clk);
            #1;
            $display("State=%b | UP=%b DOWN=%b INVALID=%b",
                     state, count_up, count_down, invalid_transition);
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        enc_a_sync = 0;
        enc_b_sync = 0;

        #25;
        rst_n = 1;

        // Initialize at 00
        apply_state(2'b00);

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

        // Illegal transition: 00 -> 11
        apply_state(2'b11);

        #20;
        $finish;
    end

endmodule
