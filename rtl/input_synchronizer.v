module input_synchronizer (
    input  wire clk,
    input  wire rst_n,

    input  wire encoder_a,
    input  wire encoder_b,

    output reg  enc_a_sync,
    output reg  enc_b_sync
);

    reg a_meta;
    reg b_meta;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_meta     <= 1'b0;
            b_meta     <= 1'b0;
            enc_a_sync <= 1'b0;
            enc_b_sync <= 1'b0;
        end
        else begin
            // First stage: may become metastable
            a_meta <= encoder_a;
            b_meta <= encoder_b;

            // Second stage: synchronized outputs
            enc_a_sync <= a_meta;
            enc_b_sync <= b_meta;
        end
    end

endmodule
