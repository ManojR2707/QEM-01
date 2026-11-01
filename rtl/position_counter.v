module position_counter (
    input  wire clk,
    input  wire rst_n,

    input  wire count_up,
    input  wire count_down,
    input  wire clear_position,

    output reg signed [31:0] position,
    output reg overflow_status
);

    localparam signed [31:0] MAX_POSITION = 32'sh7FFFFFFF;
    localparam signed [31:0] MIN_POSITION = 32'sh80000000;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            position       <= 32'sd0;
            overflow_status <= 1'b0;
        end
        else if (clear_position) begin
            position       <= 32'sd0;
            overflow_status <= 1'b0;
        end
        else begin
            case ({count_up, count_down})

                2'b10: begin
                    if (position == MAX_POSITION)
                        overflow_status <= 1'b1;
                    else
                        position <= position + 1'b1;
                end

                2'b01: begin
                    if (position == MIN_POSITION)
                        overflow_status <= 1'b1;
                    else
                        position <= position - 1'b1;
                end

                default: begin
                    position <= position;
                end

            endcase
        end
    end

endmodule
