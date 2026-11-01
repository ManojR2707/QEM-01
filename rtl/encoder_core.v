module encoder_core #(
    parameter WINDOW_CYCLES = 500000
) (
    input  wire clk,
    input  wire rst_n,
    input  wire enc_a,
    input  wire enc_b,
    input  wire clear_position,
	input  wire clear_error,
output reg  error_status,
    output wire signed [31:0] position,
    output wire [15:0] speed_count,
	output wire overflow_status,
    output wire invalid_transition
);

    wire count_up;
    wire count_down;

    // Synchronize and decode encoder inputs.
    encoder_frontend frontend (
        .clk(clk),
        .rst_n(rst_n),
        .encoder_a(enc_a),
.encoder_b(enc_b),
        .count_up(count_up),
        .count_down(count_down),
        .invalid_transition(invalid_transition)
    );

    // Maintain signed position.
    position_counter position_unit (
        .clk(clk),
        .rst_n(rst_n),
        .count_up(count_up),
        .count_down(count_down),
        .clear_position(clear_position),
        .position(position),
	.overflow_status(overflow_status)
    );

    // Measure transitions over a fixed time window.
    speed_counter #(
        .WINDOW_CYCLES(WINDOW_CYCLES)
    ) speed_unit (
        .clk(clk),
        .rst_n(rst_n),
        .count_up(count_up),
        .count_down(count_down),
        .speed_count(speed_count)
    );
// Sticky illegal-transition error flag.
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        error_status <= 1'b0;
    else if (clear_error)
        error_status <= 1'b0;
    else if (invalid_transition)
        error_status <= 1'b1;
end
endmodule
