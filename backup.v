module save_answer(
    input wire clk,
    input wire reset,
    input wire play_music,
    input wire [3:0] answer,
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


    assign click = (ticker == 5000000) ? 1'b1 : 1'b0; 
    reg [31:0] register;
    reg [3:0] max_index_reg;
    reg [3:0] auto_index;
    reg click_detected;
    reg is_music_playing;
    reg [3:0] piezo_reg;
    reg [3:0] data_reg;
    reg [3:0] answer_index;

    /*
        auto index 와 max index 가 같으면, 음악 재생을 멈추고 index를 0으로 바꾼다
        if (auto_index == max_index_reg) {
            auto_index <= 0;
            is_music_playing <= 0;
        }


    */
    always @(posedge clk or posedge reset or posedge play_music or posedge answer) begin
        if (reset) begin
            register <= 0;
            click_detected <= 0;
            auto_index <= 0;
            is_music_playing <= 0;
        end else if (write_enable) begin
            register <= data_in;
        end
        else if (play_music && !is_music_playing) begin
            auto_index <= 0;
            is_music_playing <= 1;
            click_detected <= 1;
        end
        else if (click_detected && is_music_playing) begin
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
                if (auto_index == max_index_reg) {
                    auto_index <= 0;
                    is_music_playing <= 0;
                }
                auto_index <= auto_index + 1;
            end
            4 : 
            begin
                piezo_reg <= register[19:16];
                if (auto_index == max_index_reg) {
                    auto_index <= 0;
                    is_music_playing <= 0;
                }
                auto_index <= auto_index + 1;
            end
            5 : 
            begin
                piezo_reg <= register[23:20];
                if (auto_index == max_index_reg) {
                    auto_index <= 0;
                    is_music_playing <= 0;
                }
                auto_index <= auto_index + 1;
            end
            6 : 
            begin
                piezo_reg <= register[27:24];
                if (auto_index == max_index_reg) {
                    auto_index <= 0;
                    is_music_playing <= 0;
                }
                auto_index <= auto_index + 1;
            end
            7 : 
            begin
                piezo_reg <= register[31:28];
                if (auto_index == max_index_reg) {
                    auto_index <= 0;
                    is_music_playing <= 0;
                }
            end
            endcase
        
    
        // click_detected 를 1초마다 뒤집어서, 다시 위의 노래 재생 코드가 1초동안 실행되도록 한다
        // detected 되지 않을 때는, piezo 를 끈다
        end else if (click && is_music_playing) begin
            click_detected <= !click_detected;
            if (click_detected == 0) {
                piezo_reg <= 0;
            }
        end else begin
            case(answer_index)
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
