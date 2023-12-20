module play_music_module (
    input wire clk,
    input wire reset,
    input wire success,
    input wire fail,
    output [3:0] piezo_out,
    output [3:0] led_out
);

    reg [22:0] ticker; // 23 bits needed to count up to 5M bits
    wire click;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ticker <= 0;
        end else if (ticker == 5000000) begin
            ticker <= 0;
        end else begin
            ticker <= ticker + 1;
        end
    end


    assign click = (ticker == 5000000) ? 1'b1 : 1'b0;



    /*
        auto index 와 max index 가 같으면, 음악 재생을 멈추고 index를 0으로 바꾼다
        if (auto_index == last_index) {
            auto_index <= 0;
            is_music_playing <= 0;
        }
    */

    reg [10:0] last_index;    // 각 음정의 last index : 2 ~ 7
    reg [10:0] auto_index;       // 노래 자동 재생 index
    reg [2:0] click_counter;
    reg is_music_playing;
    reg [3:0] piezo_reg;
    reg [3:0] led_reg;
    reg stop_music_flag;
    reg success_flag;
    reg fail_flag;


    always @(posedge clk or posedge reset or posedge success or posedge fail) begin

        if (reset) begin
            piezo_reg <= 0;
            led_reg <= 0;

            // 정답 index 는 0 ~ last_index 까지 반복, last_index 초기값은 2로 설정
            auto_index <= 0;
            last_index <= 26;

            is_music_playing <= 0;
            

            success_flag <= 0;
            fail_flag <= 0;
            
            // reset 시 music replay 가 1로 설정되어 자동으로 노래가 재생되고,
            // 이후에는 miss 가 발생하거나, last index 까지 모든 답을 맞춘 뒤에
            // music_replay 가 1로 설정되어 노래를 재생한다.
        end else if (success) begin
            success_flag <= 1;
            is_music_playing <= 1;
            click_counter <= 3;

        end else if (fail) begin
            fail_flag <= 1;
            is_music_playing <= 1;
            click_counter <= 3;


        end else if ((click_counter == 3) && is_music_playing) begin
            if (success_flag) begin
                case(auto_index)
                    0 : 
                    begin
                        piezo_reg <= 1;
                        led_reg <= 1;
                    end
                    1 : 
                    begin
                        piezo_reg <= 2;
                        led_reg <= 2;
                    end
                    2 : 
                    begin
                        piezo_reg <= 3;
                        led_reg <= 3;
                    end
                    3 : 
                    begin
                        piezo_reg <= 4;
                        led_reg <= 4;
                    end
                    4 : 
                    begin
                        piezo_reg <= 5;
                        led_reg <= 5;
                    end
                    5 : 
                    begin
                        piezo_reg <= 4;
                        led_reg <= 4;
                    end
                    6 : 
                    begin
                        piezo_reg <= 3;
                        led_reg <= 3;
                    end
                    7 : 
                    begin
                        piezo_reg <= 2;
                        led_reg <= 2;
                    end
                    8 : 
                    begin
                        piezo_reg <= 1;
                        led_reg <= 1;
                    end
                    9 : 
                    begin
                        piezo_reg <= 1;
                        led_reg <= 1;
                    end
                    10 : 
                    begin
                        piezo_reg <= 5;
                        led_reg <= 5;
                    end
                    11 : 
                    begin
                        piezo_reg <= 5;
                        led_reg <= 5;
                    end
                    12 : 
                    begin
                        piezo_reg <= 8;
                        led_reg <= 8;
                    end
                    13 : 
                    begin
                        piezo_reg <= 0;
                        led_reg <= 0;
                    end
                    14 : 
                    begin
                        piezo_reg <= 1;
                        led_reg <= 1;
                    end
                    15 : 
                    begin
                        piezo_reg <= 2;
                        led_reg <= 2;
                    end
                    16 : 
                    begin
                        piezo_reg <= 3;
                        led_reg <= 3;
                    end
                    17 : 
                    begin
                        piezo_reg <= 4;
                        led_reg <= 4;
                    end
                    18 : 
                    begin
                        piezo_reg <= 5;
                        led_reg <= 5;
                    end
                    19 : 
                    begin
                        piezo_reg <= 4;
                        led_reg <= 4;
                    end
                    20 : 
                    begin
                        piezo_reg <= 3;
                        led_reg <= 3;
                    end
                    21 : 
                    begin
                        piezo_reg <= 2;
                        led_reg <= 2;
                    end
                    22 : 
                    begin
                        piezo_reg <= 1;
                        led_reg <= 1;
                    end
                    23 : 
                    begin
                        piezo_reg <= 1;
                        led_reg <= 1;
                    end
                    24 : 
                    begin
                        piezo_reg <= 5;
                        led_reg <= 5;
                    end
                    25 : 
                    begin
                        piezo_reg <= 5;
                        led_reg <= 5;
                    end
                    26 : 
                    begin
                        piezo_reg <= 8;
                        led_reg <= 8;
                    end
                endcase

            end if (fail_flag) begin
                case(auto_index)
                    0 : 
                    begin
                        piezo_reg <= 6;
                        led_reg <= 6;
                    end
                    1 : 
                    begin
                        piezo_reg <= 5;
                        led_reg <= 5;
                    end
                    2 : 
                    begin
                        piezo_reg <= 6;
                        led_reg <= 6;
                    end
                    3 : 
                    begin
                        piezo_reg <= 6;
                        led_reg <= 6;
                    end
                    4 : 
                    begin
                        piezo_reg <= 5;
                        led_reg <= 5;
                    end
                    5 : 
                    begin
                        piezo_reg <= 0;
                        led_reg <= 0;
                    end
                    6 : 
                    begin
                        piezo_reg <= 3;
                        led_reg <= 3;
                    end
                    7 : 
                    begin
                        piezo_reg <= 2;
                        led_reg <= 2;
                    end
                    8 : 
                    begin
                        piezo_reg <= 3;
                        led_reg <= 3;
                    end
                    9 : 
                    begin
                        piezo_reg <= 3;
                        led_reg <= 3;
                    end
                    10 : 
                    begin
                        piezo_reg <= 2;
                        led_reg <= 2;
                    end
                    11 : 
                    begin
                        piezo_reg <= 0;
                        led_reg <= 0;
                    end
                    12 : 
                    begin
                        piezo_reg <= 6;
                        led_reg <= 6;
                    end
                    13 : 
                    begin
                        piezo_reg <= 5;
                        led_reg <= 5;
                    end
                    14 : 
                    begin
                        piezo_reg <= 6;
                        led_reg <= 6;
                    end
                    15 : 
                    begin
                        piezo_reg <= 6;
                        led_reg <= 6;
                    end
                    16 : 
                    begin
                        piezo_reg <= 5;
                        led_reg <= 5;
                    end
                    17 : 
                    begin
                        piezo_reg <= 0;
                        led_reg <= 0;
                    end
                    18 : 
                    begin
                        piezo_reg <= 3;
                        led_reg <= 3;
                    end
                    19 : 
                    begin
                        piezo_reg <= 2;
                        led_reg <= 2;
                    end
                    20 : 
                    begin
                        piezo_reg <= 3;
                        led_reg <= 3;
                    end
                    21 : 
                    begin
                        piezo_reg <= 3;
                        led_reg <= 3;
                    end
                    22 : 
                    begin
                        piezo_reg <= 2;
                        led_reg <= 2;
                    end
                    23 : 
                    begin
                        piezo_reg <= 0;
                        led_reg <= 0;
                    end
                    24 : 
                    begin
                        piezo_reg <= 0;
                        led_reg <= 0;
                    end
                    25 : 
                    begin
                        piezo_reg <= 0;
                        led_reg <= 0;
                    end
                    26 : 
                    begin
                        piezo_reg <= 0;
                        led_reg <= 0;
                    end
                    
                endcase
            end

            click_counter <= 0;

            if (auto_index == last_index) begin
                auto_index <= 0;
                stop_music_flag <= 1;

            end else begin
                auto_index <= auto_index + 1;
            end
        
        // click_counter 는 3 0 1 2 를 반복하며, 
        // 3일 때는 노래 재생을, 1 일때는 재생을 멈추어 노래가 일정하게 재생되도록 한다.
        end else if (click && is_music_playing) begin
            click_counter <= click_counter + 1;

            if (click_counter == 1) begin
                piezo_reg <= 0;
                led_reg <= 0;
                if (stop_music_flag) begin
                    is_music_playing <= 0;
                    stop_music_flag <= 0;
                end
            end
        end
    end

    assign piezo_out = piezo_reg;
    assign led_out = led_reg;


endmodule
