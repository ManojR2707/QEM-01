module qem_register_bank (
    input wire clk,
    input wire rst_n,

    input wire [2:0] address,
    input wire write_strobe,
    input wire [7:0] write_data,

    input wire signed [31:0] position,
    input wire [15:0] speed_count,
    input wire error_status,
    input wire overflow_status,
    input wire invalid_transition,

    output wire clear_position,
    output wire clear_error,
    output reg [7:0] read_data
);

    reg signed [31:0] position_snapshot;
    reg [15:0] speed_snapshot;

    // Control commands: address 7
    assign clear_position =
        write_strobe && (address == 3'd7) && write_data[1];

    assign clear_error =
        write_strobe && (address == 3'd7) && write_data[2];

    // Capture a coherent measurement snapshot.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            position_snapshot <= 32'sd0;
            speed_snapshot <= 16'd0;
        end
        else if (write_strobe && (address == 3'd7) && write_data[0]) begin
            position_snapshot <= position;
            speed_snapshot <= speed_count;
        end
    end

    // Register read multiplexer.
    always @(*) begin
        case (address)
            3'd0: read_data = position_snapshot[7:0];
            3'd1: read_data = position_snapshot[15:8];
            3'd2: read_data = position_snapshot[23:16];
            3'd3: read_data = position_snapshot[31:24];

            3'd4: read_data = speed_snapshot[7:0];
            3'd5: read_data = speed_snapshot[15:8];

            3'd6: begin
                read_data = 8'd0;
                read_data[0] = error_status;
                read_data[1] = overflow_status;
                read_data[2] = invalid_transition;
            end

            3'd7: read_data = 8'h01;

            default: read_data = 8'd0;
        endcase
    end

endmodule
