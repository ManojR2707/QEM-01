module quadrature_decoder (
    input  wire clk,
    input  wire rst_n,

    input  wire enc_a_sync,
    input  wire enc_b_sync,

    output reg  count_up,
    output reg  count_down,
    output reg  invalid_transition
);

    reg [1:0] previous_state;
    reg       initialized;

    wire [1:0] current_state = {enc_a_sync, enc_b_sync};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            previous_state    <= 2'b00;
            initialized       <= 1'b0;
            count_up          <= 1'b0;
            count_down        <= 1'b0;
            invalid_transition <= 1'b0;
        end
        else begin
            // Default: outputs are one-clock pulses
            count_up           <= 1'b0;
            count_down         <= 1'b0;
            invalid_transition <= 1'b0;

            if (!initialized) begin
                // Capture the initial encoder state without counting
                previous_state <= current_state;
                initialized    <= 1'b1;
            end
            else if (current_state != previous_state) begin

                case ({previous_state, current_state})

                    // Forward transitions
                    4'b0001,
                    4'b0111,
                    4'b1110,
                    4'b1000: count_up <= 1'b1;

                    // Reverse transitions
                    4'b0010,
                    4'b1011,
                    4'b1101,
                    4'b0100: count_down <= 1'b1;

                    // Illegal transitions
                    default: invalid_transition <= 1'b1;

                endcase

                previous_state <= current_state;
            end
        end
    end

endmodule
