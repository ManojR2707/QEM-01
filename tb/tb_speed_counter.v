`timescale 1ns/1ps

module tb_speed_counter;

    reg clk = 0;
    reg rst_n = 0;
    reg count_up = 0;
    reg count_down = 0;

    wire [15:0] speed_count;

    always #10 clk = ~clk;

    speed_counter #(
        .WINDOW_CYCLES(20)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .count_up(count_up),
        .count_down(count_down),
        .speed_count(speed_count)
    );

    initial begin
        $dumpfile("sim/speed_counter.vcd");
        $dumpvars(0, tb_speed_counter);

        #25 rst_n = 1;

        // Generate 5 upward transitions.
        repeat (5) begin
            @(negedge clk);
            count_up = 1;
            @(negedge clk);
            count_up = 0;
        end

        // Wait for the measurement window to complete.
        repeat (25) @(negedge clk);

        $display("Measured speed count = %0d", speed_count);

        if (speed_count == 5)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end

endmodule
