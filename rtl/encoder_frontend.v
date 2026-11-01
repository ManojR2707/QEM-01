module encoder_frontend (
    input  wire clk,
    input  wire rst_n,

    input  wire encoder_a,
    input  wire encoder_b,

    output wire count_up,
    output wire count_down,
    output wire invalid_transition
);

    wire enc_a_sync;
    wire enc_b_sync;

    input_synchronizer u_sync (
        .clk(clk),
        .rst_n(rst_n),
        .encoder_a(encoder_a),
        .encoder_b(encoder_b),
        .enc_a_sync(enc_a_sync),
        .enc_b_sync(enc_b_sync)
    );

    quadrature_decoder u_decoder (
        .clk(clk),
        .rst_n(rst_n),
        .enc_a_sync(enc_a_sync),
        .enc_b_sync(enc_b_sync),
        .count_up(count_up),
        .count_down(count_down),
        .invalid_transition(invalid_transition)
    );

endmodule
