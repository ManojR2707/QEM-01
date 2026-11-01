module qem_top (
    input  wire       clk,
    input  wire       rst_n,

    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,

    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe
);

    wire [2:0] address;
    wire write_strobe;

    wire clear_position;
    wire clear_error;

    wire signed [31:0] position;
    wire [15:0] speed_count;
    wire error_status;
    wire overflow_status;
    wire invalid_transition;

    assign address = uio_in[4:2];
    assign write_strobe = uio_in[5];

    // Encoder processing core
    encoder_core core (
        .clk(clk),
        .rst_n(rst_n),
        .enc_a(uio_in[0]),
        .enc_b(uio_in[1]),
        .clear_position(clear_position),
        .clear_error(clear_error),
        .error_status(error_status),
        .position(position),
        .speed_count(speed_count),
        .overflow_status(overflow_status),
        .invalid_transition(invalid_transition)
    );

    // Register interface
    qem_register_bank registers (
        .clk(clk),
        .rst_n(rst_n),
        .address(address),
        .write_strobe(write_strobe),
        .write_data(ui_in),
        .position(position),
        .speed_count(speed_count),
        .error_status(error_status),
        .overflow_status(overflow_status),
        .invalid_transition(invalid_transition),
        .clear_position(clear_position),
        .clear_error(clear_error),
        .read_data(uo_out)
    );

    // Bidirectional pins are used only as inputs.
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

endmodule
