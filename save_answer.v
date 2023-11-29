module save_answer(
    input wire clk,
    input wire reset,
    input wire play_music,
    input wire [3:0] index,
    input wire [31:0] data_in,
    input wire write_enable,
    output reg [3:0] data_out,
    output reg [3:0] piezo_out
);

    reg [22:0] ticker; // 23 bits needed to count up to 5M bits
    wire click;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ticker <= 0;
        end else if (ticker == 5000000) begin
            ticker <= 0;
        end else if (play_music) begin
            ticker <= ticker + 1;
        end
    end

    assign click = (ticker == 5000000) ? 1'b1 : 1'b0; // Generates a high pulse every 0.1 second

    reg [31:0] register;
    reg [3:0] out;
    reg click_detected;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            register <= 0;
            click_detected <= 0;
        end else if (write_enable) begin
            register <= data_in;
        end
        if (click && !click_detected) begin
            // Output register[3:0] for 0.1 seconds, then register[7:4] for the next 0.1 seconds
            if (out < 4) begin
                piezo_out <= register[out*4 +: 4];
                out <= out + 1;
            end else begin
                out <= 0;
            end
            click_detected <= 1;
        end else if (!click) begin
            click_detected <= 0;
        end
    end

    assign data_out = register;

endmodule
