`timescale 1ns/1ps

module tb_position_counter;

    reg clk;
    reg rst_n;
    reg count_up;
    reg count_down;
    reg clear_position;

    wire signed [31:0] position;

    position_counter dut (
        .clk(clk),
        .rst_n(rst_n),
        .count_up(count_up),
        .count_down(count_down),
        .clear_position(clear_position),
        .position(position)
    );

    always #10 clk = ~clk;

    task apply_pulse;
        input up;
        input down;
        begin
            @(negedge clk);
            count_up = up;
            count_down = down;

            @(posedge clk);
            #1;

            $display("UP=%b DOWN=%b POSITION=%0d",
                     up, down, position);

            count_up = 0;
            count_down = 0;
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        count_up = 0;
        count_down = 0;
        clear_position = 0;

        #25;
        rst_n = 1;

        // Increment three times
        apply_pulse(1, 0);
        apply_pulse(1, 0);
        apply_pulse(1, 0);

        // Decrement twice
        apply_pulse(0, 1);
        apply_pulse(0, 1);

        // Test conflicting pulses
        apply_pulse(1, 1);

        // Clear position
        @(negedge clk);
        clear_position = 1;
        @(posedge clk);
        #1;
        $display("AFTER CLEAR: POSITION=%0d", position);

        clear_position = 0;

        // Verify counting resumes
        apply_pulse(1, 0);

        #20;
        $finish;
    end

endmodule
