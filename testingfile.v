module game_module(
    input wire clk,
    input wire reset,
    input wire [3:0] answer,
    input wire [31:0] data_in,
    input wire write_enable,
    input wire answer_enable,
	 input wire my_turn,
    output [3:0] data_out,
    output [3:0] piezo_out,
    output [3:0] led_out,
    output miss_out,
    output [2:0] game_mode_out,
    output [2:0] click_detected_out,
    output [31:0] register_out,
    output play_music,
    output play_miss_out,
    output change_num_out,
	 output [3:0] auto_index_out,
	 output [3:0] max_index_out
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
    reg [3:0] max_index;    // 최대값 index
    reg [3:0] auto_index;       // 노래 자동 재생 index
    reg [2:0] click_detected;
    reg is_music_playing;
    reg [3:0] piezo_reg;
    reg [3:0] data_reg;
    reg [3:0] answer_index;     // 정답 index
    reg play_miss;
    reg [2:0] game_mode;
    reg miss_reg;
    reg change_num;
    reg [3:0] answer_reg;
    reg [3:0] led_reg;
    reg [6:0] problem_count;
    reg start_flag;

    /*
        auto index 와 max index 가 같으면, 음악 재생을 멈추고 index를 0으로 바꾼다
        if (auto_index == max_index) {
            auto_index <= 0;
            is_music_playing <= 0;
        }
    */

    always @(posedge clk or posedge reset or posedge write_enable or posedge answer_enable) begin

        if (reset) begin
            register <= 0;
            click_detected <= 0;
            auto_index <= 0;
            play_miss <= 1;
            game_mode <= 0;
            miss_reg <= 0;
            change_num <= 0;
            problem_count <= 0;
            start_flag <= 0;

            // 정답 index 는 0 ~ max_index 까지 반복, max_index 초기값은 2로 설정
            answer_index <= 0;
            max_index <= 2;
        end else if (write_enable) begin
            register <= data_in;
            start_flag <= 1;

        end else if (answer_enable) begin
            answer_reg <= answer;

        // end else if (!answer_enable && game_mode == 0) begin
        //     led_reg <= 0;

        // mode가 0이고, register 값이 비어있지 않고, flag 가 true 면 노래를 시작한다
        // is_music_playing 을 1으로 바꿔준다
        end else if ((game_mode == 0) && start_flag && play_miss) begin
            auto_index <= 0;
            click_detected <= 3;
            is_music_playing <= 1;
            play_miss <= 0;
        end
		  
		  else if ((game_mode == 0) && (click_detected == 3) && is_music_playing) begin
            
            case(auto_index)
            0 : 
            begin
                piezo_reg <= register[3:0];
                led_reg <= register[3:0];
					 
					 if (auto_index == max_index) begin
                    auto_index <= 0;
                    is_music_playing <= 0;
                end
					 
                auto_index <= auto_index + 1;
            end
            1 : 
            begin
                piezo_reg <= register[7:4];
                led_reg <= register[7:4];
					 
					 if (auto_index == max_index) begin
                    auto_index <= 0;
                    is_music_playing <= 0;
                end
					 
                auto_index <= auto_index + 1;
            end
            2 : 
            begin
                piezo_reg <= register[11:8];
                led_reg <= register[11:8];
					 
					 if (auto_index == max_index) begin
                    auto_index <= 0;
                    is_music_playing <= 0;
                end

                auto_index <= auto_index + 1;
            end
            3 : 
            begin
                piezo_reg <= register[15:12];
                led_reg <= register[15:12];
                if (auto_index == max_index) begin
                    auto_index <= 0;
                    is_music_playing <= 0;
                end
                auto_index <= auto_index + 1;
            end
            4 : 
            begin
                piezo_reg <= register[19:16];
                led_reg <= register[19:16];
                if (auto_index == max_index) begin
                    auto_index <= 0;
                    is_music_playing <= 0;
                end
                auto_index <= auto_index + 1;
            end
            5 : 
            begin
                piezo_reg <= register[23:20];
                led_reg <= register[23:20];
                if (auto_index == max_index) begin
                    auto_index <= 0;
                    is_music_playing <= 0;
                end
                auto_index <= auto_index + 1;
            end
            6 : 
            begin
                piezo_reg <= register[27:24];
                led_reg <= register[27:24];
                if (auto_index == max_index) begin
                    auto_index <= 0;
                    is_music_playing <= 0;
                end
                auto_index <= auto_index + 1;
            end
            7 : 
            begin
                piezo_reg <= register[31:28];
                led_reg <= register[31:28];
                if (auto_index == max_index) begin
                    auto_index <= 0;
                    is_music_playing <= 0;
                end
            end
            endcase

           click_detected <= 0;
			  
			  
        end else if ((game_mode == 0) && click && is_music_playing) begin
            click_detected <= click_detected + 1;
            if (click_detected == 1) begin
                piezo_reg <= 0;
                led_reg <= 0;
            end
			end

  
	 end

    assign play_miss_out = play_miss;
    assign register_out = register;
    assign click_detected_out = click_detected;
    assign led_out = led_reg;
    assign change_num_out = change_num;
    assign game_mode_out = game_mode;
    assign miss_out = miss_reg;
    assign piezo_out = piezo_reg;
    assign data_out = data_reg;
	 assign max_index_out = max_index;
	 assign auto_index_out = auto_index;

endmodule
