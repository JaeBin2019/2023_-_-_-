module game_module_1(
    input wire clk,
    input wire reset,
    input wire [3:0] keypad_input,
    input wire [31:0] data_in,
    input wire write_enable,
    input wire keypad_enable,
    input wire game_start,
    output [3:0] data_out,
    output [3:0] piezo_out,
    output [3:0] led_out,
    output miss_out,
    output [2:0] game_mode_out,
    output [2:0] click_counter_out,
    output [31:0] register_out,
    output play_music,
    output music_replay_out,
    output [3:0] auto_index_out,
    output [3:0] last_index_out,
    output game_end,
    output [3:0] keypad_reg_out,
    output [3:0] answer_reg_out,
    output keypad_enable_flag_out,
    output answer_flag_out
);

    reg [20:0] ticker; // 23 bits needed to count up to 5M bits
    wire click;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ticker <= 0;
        end else if (ticker == 1) begin
            ticker <= 0;
        end else begin
            ticker <= ticker + 1;
        end
    end


    assign click = (ticker == 1) ? 1'b1 : 1'b0; 
    reg [31:0] register;
    reg [3:0] last_index;    // 각 음정의 last index : 2 ~ 7
    reg [3:0] max_index;    // 노래 재생 시 마지막 index : 7
    reg [3:0] auto_index;       // 노래 자동 재생 index
    reg [2:0] click_counter;
    reg is_music_playing;
    reg [3:0] piezo_reg;
    reg [3:0] data_reg;
    reg [3:0] answer_index;     // 정답 index
    reg music_replay;
    reg miss_reg;
    reg [3:0] keypad_reg;
    reg [3:0] answer_reg;
    reg [3:0] led_reg;
    reg [6:0] problem_count;
    reg answer_saved_flag;
    reg stop_music_flag;
    reg keypad_enable_flag;
    reg game_start_flag;
    reg game_end_reg;
    reg keypad_down_flag;
    reg answer_flag;

    /*
        auto index 와 max index 가 같으면, 음악 재생을 멈추고 index를 0으로 바꾼다
        if (auto_index == last_index) {
            auto_index <= 0;
            is_music_playing <= 0;
        }
    */

    always @(posedge clk or posedge reset or posedge write_enable or posedge keypad_enable or posedge game_start) begin

        if (reset) begin
            register <= 0;
            click_counter <= 0;
            auto_index <= 0;
            music_replay <= 1;
            miss_reg <= 0;
            problem_count <= 0;
            answer_saved_flag <= 0;
            stop_music_flag <= 0;
            keypad_enable_flag <= 0;
            game_start_flag <= 0;
            game_end_reg <= 0;
            keypad_down_flag <= 0;
            keypad_reg <= 0;
            answer_flag <= 0;

            piezo_reg <= 0;
            led_reg <= 0;

            // 정답 index 는 0 ~ last_index 까지 반복, last_index 초기값은 2로 설정
            answer_index <= 0;
            last_index <= 0;
            max_index <= 1;
        end else if (write_enable) begin
            register <= data_in;
            answer_saved_flag <= 1;
        
        end else if (game_start) begin
            game_start_flag <= 1;

        // keypad 에 값이 들어오면, keypad 값을 읽어 처리할 수 있도록 한다
        // 만약 노래가 재생 중이라면, 위의 if 문에 걸려 keypad 가 동작하지 않게 된다
        end else if (keypad_enable) begin
            if (!is_music_playing) begin
                keypad_reg <= keypad_input;
                keypad_enable_flag <= 1;
                keypad_down_flag <= 1;
                led_reg <= keypad_reg;
                piezo_reg <= keypad_reg;
            end

        // keypad button 을 땐 후에 노래가 멈추도록 한다
        end else if (keypad_down_flag) begin
            keypad_down_flag <= 0;
            led_reg <= 0;
            piezo_reg <= 0;

        // game start 신호와 register 에 정답이 저장된 이후에 동작
        end else if (game_start_flag && answer_saved_flag) begin

            // reset 시 music replay 가 1로 설정되어 자동으로 노래가 재생되고,
            // 이후에는 miss 가 발생하거나, last index 까지 모든 답을 맞춘 뒤에
            // music_replay 가 1로 설정되어 노래를 재생한다.
            if (music_replay) begin
                auto_index <= 0;
                click_counter <= 3;
                is_music_playing <= 1;
                stop_music_flag <= 0;
                music_replay <= 0;
            end
            
            else if ((click_counter == 3) && is_music_playing) begin
                
                case(auto_index)
                0 : 
                begin
                    piezo_reg <= register[2:0] + 1;
                    led_reg <= register[2:0] + 1;
                end
                1 : 
                begin
                    piezo_reg <= register[6:4] + 1;
                    led_reg <= register[6:4] + 1;
                end
                2 : 
                begin
                    piezo_reg <= register[10:8] + 1;
                    led_reg <= register[10:8] + 1;
                end
                3 : 
                begin
                    piezo_reg <= register[14:12] + 1;
                    led_reg <= register[14:12] + 1;
                end
                4 : 
                begin
                    piezo_reg <= register[18:16] + 1;
                    led_reg <= register[18:16] + 1;
                end
                5 : 
                begin
                    piezo_reg <= register[22:20] + 1;
                    led_reg <= register[22:20] + 1;
                end
                6 : 
                begin
                    piezo_reg <= register[26:24] + 1;
                    led_reg <= register[26:24] + 1;
                end
                7 : 
                begin
                    piezo_reg <= register[30:28] + 1;
                    led_reg <= register[30:28] + 1;
                end
                endcase
                click_counter <= 0;
                    
                // 마지막 index 에 도달하면, index 를 0으로 초기화 하고 노래 재생을 멈춘다
                // 아니라면, index 를 1 증가시키고 계속해서 노래를 재생한다
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

            // keypad 값이 입력되었다면, answer 에 해당 index register 값을 넣는다.
            end else if (keypad_enable_flag) begin
                keypad_enable_flag <= 0;
                answer_flag <= 1;

                case(answer_index)
                0 : 
                begin
                    answer_reg <= register[2:0] + 1;
                end
                1 : 
                begin
                    answer_reg <= register[6:4] + 1;
                end
                2 : 
                begin
                    answer_reg <= register[10:8] + 1;
                end
                3 : 
                begin
                    answer_reg <= register[14:12] + 1;
                end
                4 : 
                begin
                    answer_reg <= register[18:16] + 1; 
                end
                5 : 
                begin
                    answer_reg <= register[22:20] + 1;
                end
                6 : 
                begin
                    answer_reg <= register[26:24] + 1;
                end
                7 : 
                begin
                    answer_reg <= register[30:28] + 1;
                end
                endcase
            end else if (answer_flag) begin
                answer_flag <= 0;

                // 정답과 틀리면, index 를 0으로 되돌리고 노래 재생을 시작한다
                if (keypad_reg != answer_reg) begin
                    led_reg <= 0;
                    piezo_reg <= 0;
                    answer_index <= 0;
                    music_replay <= 1;

                // 마지막 index의 정답을 맞추었다면, last_index 값을 1 증가시키고
                // 음정을 하나 추가하여 노래를 다시 재생한다
                end else if ((keypad_reg == answer_reg) && (answer_index == last_index)) begin

                    // 게임 종료 max_index 인 7에 도달했다면, start flag 를 0으로 바꾸고,
                    // 게임 종료 신호를 보낸다
                    if (answer_index == max_index) begin
                        game_start_flag <= 0;
                        game_end_reg <= 1;
                    end

                    answer_index <= 0;
                    last_index <= last_index + 1;
                    music_replay <= 1;

                // 정답이 맞다면, answer_index 를 1 증가시키고 계속해서
                // 다음 음정을 맞추는 지 체크한다
                end else if (keypad_reg == answer_reg) begin
                    answer_index <= answer_index + 1;
                end
            end
        end
    end

    assign answer_flag_out = answer_flag;
    assign keypad_enable_flag_out = keypad_enable_flag;
    assign answer_reg_out = answer_reg;
    assign keypad_reg_out = keypad_reg;
    assign game_end = game_end_reg;
    assign music_replay_out = music_replay;
    assign register_out = register;
    assign click_counter_out = click_counter;
    assign led_out = led_reg;
    assign miss_out = miss_reg;
    assign piezo_out = piezo_reg;
    assign data_out = data_reg;
    assign last_index_out = last_index;
    assign auto_index_out = auto_index;

endmodule
