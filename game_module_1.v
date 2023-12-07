module game_module(
    input wire clk,
    input wire reset,
    input wire [3:0] keypad_data,
    input wire [31:0] data_in,
    input wire write_enable,
    input wire keypad_enable,
	input wire game_start,
    output [3:0] data_out,
    output [3:0] piezo_out,
    output [3:0] led_out,
    output miss_out,
    output [2:0] game_mode_out,
    output [2:0] click_detected_out,
    output [31:0] register_out,
    output play_music,
    output music_replay_out,
	output [3:0] auto_index_out,
	output [3:0] last_index_out,
    output game_end
);

    reg [20:0] ticker; // 23 bits needed to count up to 5M bits
    wire click;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ticker <= 0;
        end else if (ticker == 2) begin
            ticker <= 0;
        end else begin
            ticker <= ticker + 1;
        end
    end


    assign click = (ticker == 2) ? 1'b1 : 1'b0; 
    reg [31:0] register;
    reg [3:0] last_index;    // 각 음정의 last index : 2 ~ 7
    reg [3:0] max_index;    // 노래 재생 시 마지막 index : 7
    reg [3:0] auto_index;       // 노래 자동 재생 index
    reg [2:0] click_detected;
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
    reg start_flag;
    reg stop_music_flag;
    reg keypad_enable_flag;
    reg game_start_flag;
    reg game_end_reg;

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
            click_detected <= 0;
            auto_index <= 0;
            music_replay <= 1;
            miss_reg <= 0;
            problem_count <= 0;
            start_flag <= 0;
			stop_music_flag <= 0;
			keypad_enable_flag <= 0;
            game_start_flag <= 0;
            game_end_reg <= 0;

            // 정답 index 는 0 ~ last_index 까지 반복, last_index 초기값은 2로 설정
            answer_index <= 0;
            last_index <= 2;
            max_index <= 7;
        end else if (write_enable) begin
            register <= data_in;
            start_flag <= 1;
        
        end else if (game_start) begin
            game_start_flag <= 1;

        // keypad 에 값이 들어오면, keypad 값을 읽어 처리할 수 있도록 한다
        // 만약 노래가 재생 중이라면, 위의 if 문에 걸려 keypad 가 동작하지 않게 된다
        end else if (keypad_enable) begin
            if (!is_music_playing) begin
                keypad_reg <= keypad_data;
                keypad_enable_flag <= 1;
                led_reg <= keypad_reg;
                piezo_reg <= keypad_reg;
            end

        end else begin
            if (game_start_flag) begin
                // end else if (!keypad_enable && game_mode == 0) begin
                //     led_reg <= 0;

                // mode가 0이고, register 값이 비어있지 않고, flag 가 true 면 노래를 시작한다
                // is_music_playing 을 1으로 바꿔준다
                if (start_flag && music_replay) begin
                    auto_index <= 0;
                    click_detected <= 3;
                    is_music_playing <= 1;
                    stop_music_flag <= 0;
                    music_replay <= 0;
                end
                
                else if ((click_detected == 3) && is_music_playing) begin
                    
                    case(auto_index)
                    0 : 
                    begin
                        piezo_reg <= register[3:0];
                        led_reg <= register[3:0];
                    end
                    1 : 
                    begin
                        piezo_reg <= register[7:4];
                        led_reg <= register[7:4];
                    end
                    2 : 
                    begin
                        piezo_reg <= register[11:8];
                        led_reg <= register[11:8];
                    end
                    3 : 
                    begin
                        piezo_reg <= register[15:12];
                        led_reg <= register[15:12];
                    end
                    4 : 
                    begin
                        piezo_reg <= register[19:16];
                        led_reg <= register[19:16];
                    end
                    5 : 
                    begin
                        piezo_reg <= register[23:20];
                        led_reg <= register[23:20];
                    end
                    6 : 
                    begin
                        piezo_reg <= register[27:24];
                        led_reg <= register[27:24];
                    end
                    7 : 
                    begin
                        piezo_reg <= register[31:28];
                        led_reg <= register[31:28];
                    end
                    endcase
                    click_detected <= 0;
                        
                    if (auto_index == last_index) begin
                        auto_index <= 0;
                        stop_music_flag <= 1;

                    end else begin
                        auto_index <= auto_index + 1;
                    end
                    
                end else if (click && is_music_playing) begin
                    click_detected <= click_detected + 1;
                    if (click_detected == 1) begin
                        piezo_reg <= 0;
                        led_reg <= 0;
                        if (stop_music_flag) begin
                            is_music_playing <= 0;
                            stop_music_flag <= 0;
                        end
                    end
                        
                    
                

                // keypad 값이 입력되었다면, answer 값과 keypad 값을 비교하여
                // miss 라면 index 값을 그대로, 답과 같은 값을 입력했다면,
                // last index 가 될 때까지 답을 계속해서 맞춰나간다.
                end else if (keypad_enable_flag) begin
                    keypad_enable_flag <= 0;

                    case(answer_index)
                    0 : 
                    begin
                        answer_reg <= register[3:0];
                    end
                    1 : 
                    begin
                        answer_reg <= register[7:4];
                    end
                    2 : 
                    begin
                        answer_reg <= register[11:8];
                    end
                    3 : 
                    begin
                        answer_reg <= register[15:12];
                    end
                    4 : 
                    begin
                        answer_reg <= register[19:16];
                    end
                    5 : 
                    begin
                        answer_reg <= register[23:20];
                    end
                    6 : 
                    begin
                        answer_reg <= register[27:24];
                    end
                    7 : 
                    begin
                        answer_reg <= register[31:28];
                    end
                    endcase

                    // 정답과 틀리면, index 를 0으로 되돌리고 노래 재생을 시작한다
                    if (keypad_reg != answer_reg) begin
                        answer_index <= 0;
                        music_replay <= 1;

                    // 마지막 index의 정답을 맞추었다면, last_index 값을 1 증가시키고
                    // 음정을 하나 추가하여 노래를 다시 재생한다
                    end else if (answer_index == last_index) begin

                        // 게임 종료 index 인 7에 도달했다면, start flag 를 0으로 바꾸고,
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
                    end else if (keypad_data == answer_reg) begin
                        answer_index <= answer_index + 1;
                    end
                end
            end
        end

    end

    assign game_end = game_end_reg;
    assign music_replay_out = music_replay;
    assign register_out = register;
    assign click_detected_out = click_detected;
    assign led_out = led_reg;
    assign miss_out = miss_reg;
    assign piezo_out = piezo_reg;
    assign data_out = data_reg;
	assign last_index_out = last_index;
	assign auto_index_out = auto_index;

endmodule
