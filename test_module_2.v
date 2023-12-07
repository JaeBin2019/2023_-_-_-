module game_module(
    input wire clk,
    input wire reset,
    input wire [31:0] data_in,
    input wire write_enable,
    input wire [3:0] keypad_data,
    input wire keypad_enable,
	input wire game_start,
    output [3:0] piezo_out,
    output [3:0] led_out,
    output miss_out,
    output [2:0] click_counter_out,
    output [31:0] register_out,
	output [3:0] auto_index_out,
    output [6:0] current_count_out,
    output change_answer,
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
    reg [3:0] limit_index;    // 노래 재생 시 마지막 index : 7
    reg [2:0] click_counter;
    reg [3:0] piezo_reg;
    reg [3:0] problem_index;     // 정답 index
    reg miss_reg;
    reg [3:0] keypad_reg;
    reg [3:0] answer_reg;
    reg [3:0] led_reg;
    reg [6:0] problem_count;
    reg [6:0] current_count;
    reg answer_saved_flag;
    reg keypad_enable_flag;
    reg game_start_flag;
    reg game_end_reg;
    reg change_answer_reg;

    always @(posedge clk or posedge reset or posedge keypad_enable) begin
        if (reset) begin
            keypad_reg <= 0;
            keypad_enable_flag <= 0;

        end else if (keypad_enable && answer_saved_flag) begin
            keypad_reg <= keypad_data;
            keypad_enable_flag <= 1;
            led_reg <= keypad_reg;
            piezo_reg <= keypad_reg;
        end
    end

    always @(posedge clk or posedge reset or posedge write_enable or posedge game_start) begin

        if (reset) begin
            register <= 0;
            click_counter <= 0;
            problem_index <= 0;
            miss_reg <= 0;
            current_count <= 0;
            problem_count <= 30;
            answer_saved_flag <= 0;
			keypad_enable_flag <= 0;
            game_start_flag <= 0;
            game_end_reg <= 0;
            limit_index <= 7;
            change_answer_reg <= 0;
            piezo_reg <= 0;
            led_reg <= 0;

        end else if (write_enable) begin
            register <= data_in;
            answer_saved_flag <= 1;
        
        end else if (game_start) begin
            game_start_flag <= 1;

        // 1 clk 만 출력
        end else if (miss_reg || change_answer_reg) begin
            miss_reg <= 0;
            change_answer_reg <= 0;

        // game start 신호와 register 에 정답이 저장된 이후에 동작
        end else if (game_start_flag && answer_saved_flag) begin

            // 모든 문제가 종료되면, game_end 신호를 출력
            if (current_count == problem_count) begin
                game_start_flag <= 0;
                game_end_reg <= 1;
            end

            // answer 이 저장되지 않은 상태로 변경하고
            // random module 에 값을 요청하는 신호를 보내고
            // index 를 0으로 초기화 한다
            if (problem_index == limit_index + 1) begin
                answer_saved_flag <= 0;
                change_answer_reg <= 1;
                problem_index <= 0;
            end

            // click_counter 1씩 증가
            if (click) begin
                click_counter <= click_counter + 1;
            end
            
            // 3click 동안 답을 맞추지 못하면 index를 증가시키고, miss 출력
            if (click && (click_counter == 3)) begin
                click_counter <= 0;
                miss_reg <= 1;
                problem_index <= problem_index + 1;
                current_count <= current_count + 1;

            // keypad 입력이 들어오면, click_counter 와 keypad_flag 를 초기화
            end else begin

                case(problem_index)
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


                // 현재 두더지 위치 출력
                led_reg <= answer_reg;

                if (keypad_enable_flag) begin
                    keypad_enable_flag <= 0;
                    click_counter <= 0;

                    // 입력값이 다르면 miss 출력
                    if (keypad_reg != answer_reg) begin
                        miss_reg <= 1;
                    end

                    current_count <= current_count + 1;
                    problem_index <= problem_index + 1;
                end
            end
        end
    end

    assign current_count_out = current_count;
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
