`timescale 1ns/1ps

module tb_encoder_core;

    reg clk;
    reg rst_n;
    reg encoder_a;
    reg encoder_b;
    reg clear_position;
reg clear_error;
wire error_status;
    wire signed [31:0] position;
    wire [15:0] speed_count;
    wire invalid_transition;
	wire overflow_status;

    encoder_core #(
        .WINDOW_CYCLES(100)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enc_a(encoder_a),
        .enc_b(encoder_b),
        .clear_position(clear_position),
        .position(position),
        .speed_count(speed_count),
        .invalid_transition(invalid_transition),
	.clear_error(clear_error),
.error_status(error_status),
.overflow_status(overflow_status)
    );

    always #10 clk = ~clk;

    task apply_state;
        input [1:0] state;
        begin
            @(negedge clk);
            {encoder_a, encoder_b} = state;

            // Allow synchronizer and decoder to process the transition.
            repeat (3) @(posedge clk);
            #1;

            $display("Input=%b | Position=%0d | Speed=%0d | Invalid=%b",
                     state, position, speed_count, invalid_transition);
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        encoder_a = 0;
        encoder_b = 0;
        clear_position = 0;
	clear_error = 0;
        #25;
        rst_n = 1;

        repeat (4) @(posedge clk);

        // Forward rotation: 4 transitions.
        apply_state(2'b01);
        apply_state(2'b11);
        apply_state(2'b10);
        apply_state(2'b00);

        // Reverse rotation: 4 transitions.
        apply_state(2'b10);
        apply_state(2'b11);
        apply_state(2'b01);
        apply_state(2'b00);

        // Illegal transition.
        apply_state(2'b11);
	// Check sticky error.
repeat (3) @(posedge clk);
#1;
$display("Sticky error status = %b", error_status);

// Clear sticky error.
@(negedge clk);
clear_error = 1;
@(posedge clk);
#1;
$display("After error clear = %b", error_status);
@(negedge clk);
clear_error = 0;
        // Clear position.
        @(negedge clk);
        clear_position = 1;
        @(posedge clk);
        #1;
        $display("After clear: Position=%0d", position);
        clear_position = 0;

        // Wait for speed measurement window.
        repeat (110) @(posedge clk);
        #1;
        $display("Final Position=%0d | Speed Count=%0d",
                 position, speed_count);
	// Test positive overflow.
@(negedge clk);
force dut.position_unit.position = 32'sh7FFFFFFF;
@(negedge clk);
release dut.position_unit.position;

force dut.position_unit.position = 32'sh7FFFFFFF;
force dut.position_unit.overflow_status = 1'b0;
@(negedge clk);
release dut.position_unit.position;
release dut.position_unit.overflow_status;

force dut.count_up = 1'b1;
@(posedge clk);
#1;
$display("Positive limit: Position=%0d | Overflow=%b",
         position, overflow_status);
release dut.count_up;

// Clear position and overflow.
@(negedge clk);
clear_position = 1'b1;
@(posedge clk);
#1;
clear_position = 1'b0;
$display("After clear: Position=%0d | Overflow=%b",
         position, overflow_status);

// Test negative overflow.
@(negedge clk);
force dut.position_unit.position = 32'sh80000000;
force dut.position_unit.overflow_status = 1'b0;
@(negedge clk);
release dut.position_unit.position;
release dut.position_unit.overflow_status;

force dut.count_down = 1'b1;
@(posedge clk);
#1;
$display("Negative limit: Position=%0d | Overflow=%b",
         position, overflow_status);
release dut.count_down;

        $finish;
    end

endmodule
