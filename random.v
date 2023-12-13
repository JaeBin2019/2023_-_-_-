`timescale 1ns / 1ps
// lcg.v
//  Linear Congruential Generator PRNG
// Default parameters taken from glibc
module random #(parameter a=1103515245, c=12345) (
    input clk,
    input change_answer,
    output reg [31:0] rand,
    output write_enable
    );
    
    initial rand = 1; // I think this seed is good enough
    
    reg [31:0] next_rand;
    reg change_answer_flag = 0;
    reg write_enable_reg = 0;
    
    always @ (*) begin
        next_rand = (a * rand + c) % 8 + 1 >> 4 + (a * rand + c) % 8 + 1 >> 4 + (a * rand + c) % 8 + 1;

    end
    always @ (posedge clk or posedge change_answer) begin
        if (change_answer) begin
            change_answer_flag <= 1;

        end else if (change_answer_flag) begin
            change_answer_flag <= 0;
            write_enable_reg <= 1;
            
        end else if (write_enable_reg) begin
            write_enable_reg <= 0;
        end
    end

    assign write_enable = write_enable_reg;
    assign rand = next_rand;
endmodule