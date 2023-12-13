
// lcg.v
//  Linear Congruential Generator PRNG
// Default parameters taken from glibc
module random (
    input clk,
    input change_answer,
    output reg [31:0] rand,
    output write_enable
    );
    
    initial rand = 1; // I think this seed is good enough
    
    reg [31:0] next_rand;
    reg change_answer_flag = 0;
    reg write_enable_reg = 0;
    reg [20:0] ticker; // 23 bits needed to count up to 5M bits
    reg [31:0] seed = 1;
    wire click;

    always @(posedge clk) begin
        if (ticker == 1) begin
            ticker <= 0;
        end else begin
            ticker <= ticker + 1;
        end
    end


    assign click = (ticker == 1) ? 1'b1 : 1'b0; 
    
    always @ (posedge clk or posedge change_answer) begin
        next_rand = (click % 8 + 1) + ((7 * click) % 8 + 1) * 16 + ((13 * click) % 8 + 1) * 16 * 16 + ((23 * click) % 8 + 1) * 16 * 16 * 16
            + ((17 * click) % 8 + 1) * 16 * 16 * 16 * 16 + ((31 * click) % 8 + 1) * 16 * 16 * 16 * 16 * 16 + ((37 * click) % 8 + 1) * 16 * 16 * 16 * 16 * 16 * 16
            + ((43 * click) % 8 + 1) * 16 * 16 * 16 * 16 * 16 * 16 * 16;
        rand = next_rand;
        if (change_answer) begin
            change_answer_flag <= 1;

        end else if (change_answer_flag) begin
            change_answer_flag <= 0;
            write_enable_reg <= 1;
            
        end else if (write_enable_reg) begin
            write_enable_reg <= 0;
        end else if (click) begin
            seed <= seed + 1;
        end
    end

    assign write_enable = write_enable_reg;
endmodule