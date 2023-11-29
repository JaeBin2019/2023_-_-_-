module save_answer(
    input wire clk,
    input wire reset,
    input wire play_music,
    input wire [3:0] cur_index,
    input wire [31:0] data_in,
    input wire [3:0] max_index,
    input wire write_enable,
    output [3:0] data_out,
    output [3:0] piezo_out
);

    reg [20:0] ticker; // 23 bits needed to count up to 5M bits
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
            case(auto_index)
            0 : 
            begin
                piezo_reg <= register[3:0];
                auto_index <= auto_index + 1;
            end
            1 : 
            begin
                piezo_reg <= register[7:3];
                auto_index <= auto_index + 1;
            end
            2 : 
            begin
                piezo_reg <= register[11:8];
                auto_index <= auto_index + 1;
            end
            3 : 
            begin
                piezo_reg <= register[15:12];
                auto_index <= auto_index + 1;
            end
            4 : 
            begin
                piezo_reg <= register[19:16];
                auto_index <= auto_index + 1;
            end
            5 : 
            begin
                piezo_reg <= register[23:20];
                auto_index <= auto_index + 1;
            end
            6 : 
            begin
                piezo_reg <= register[27:24];
                auto_index <= auto_index + 1;
            end
            7 : 
            begin
                piezo_reg <= register[31:28];
                auto_index <= 0;
                is_music_playing <= 0;
            end
            endcase
            click_detected <= 1;
        end else if (!click) begin
            click_detected <= 0;
        end else begin
            case(cur_index)
            0 : 
            begin
                piezo_reg <= register[3:0];
            end
            1 : 
            begin
                piezo_reg <= register[7:3];
            end
            2 : 
            begin
                piezo_reg <= register[11:8];
            end
            3 : 
            begin
                piezo_reg <= register[15:12];
            end
            4 : 
            begin
                piezo_reg <= register[19:16];
            end
            5 : 
            begin
                piezo_reg <= register[23:20];
            end
            6 : 
            begin
                piezo_reg <= register[27:24];
            end
            7 : 
            begin
                piezo_reg <= register[31:28];
            end
            endcase
        end
    end

    assign piezo_out = piezo_reg;
    assign data_out = data_reg;

endmodule
