module save_answer(
    input wire clk,
    input wire reset,
    input wire play_music,
    input wire [3:0] cur_index,
    input wire [31:0] data_in,
    input wire [3:0] max_index,
    input wire write_enable,
    output reg [3:0] data_out,
    output reg [3:0] piezo_out
);

    reg [22:0] ticker; // 23 bits needed to count up to 5M bits
    wire click;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ticker <= 0;
        end else if (ticker == 5000000 * 2) begin
            ticker <= 0;
        end else begin
            ticker <= ticker + 1;
        end
    end

    assign click = (ticker < 5000000) ? 1'b1 : 1'b0; // Generates a high pulse every 0.1 second

    reg [31:0] register;
    reg [3:0] max_index_reg;
    reg [3:0] auto_index;
    reg click_detected;
    reg is_music_playing;
    reg [3:0] piezo_reg;
    reg [3:0] data_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            register <= 0;
            click_detected <= 0;
            auto_index <= 0;
            is_music_playing <= 0;
        end else if (write_enable) begin
            register <= data_in;
        end
        if (play_music && !is_music_playing) begin
            auto_index <= 0;
            is_music_playing <= 1;
            click_detected <= 0;
        end
        if (click && is_music_playing) begin
            // Output register[3:0] for 1 second
            if (auto_index < max_index_reg) begin
                piezo_reg <= register[(auto_index + 1) * 4 - 1 : auto_index * 4];
                auto_index <= auto_index + 1;
            end else begin
            if (auto_index == max_index_reg)
                piezo_reg <= register[(auto_index + 1) * 4 - 1 : auto_index * 4];
                auto_index <= 0;
                is_music_playing <= 0; // Output completed, stop playing music
            end
            click_detected <= 1;
        end else if (!click) begin
            click_detected <= 0;
        end else begin
            data_reg <= register[(cur_index + 1) * 4 - 1 : cur_index * 4];
        end
    end

    assign piezo_out = piezo_reg;
    assign data_out = register;
    assign data_out = data_reg;

endmodule
