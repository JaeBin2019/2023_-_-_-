// https://simplefpga.blogspot.com/2012/07/to-code-stopwatch-in-verilog.html


module timer (
    input clock,
    input reset,
    input start,
    input miss,
    input game_end,
    output a, b, c, d, e, f, g, dp,
    output [7:0] an,
    output game_over
  );

reg [7:0] reg_d0, reg_d1, reg_d2, reg_d3, reg_d4, reg_d5, reg_d6, reg_d7; //registers that will hold the individual counts
reg [22:0] ticker; //23 bits needed to count up to 5M bitsa
reg [22:0] timer;
reg miss_flag;
reg start_flag;
reg game_end_reg;
wire click;

//the mod 5M clock to generate a tick ever 0.1 second

always @ (posedge clock or posedge reset)
begin
 if(reset)
  ticker <= 0;

  // 50MHz * 0.0001 = 5000
 else if(ticker == 5000) // if it reaches the desired max value reset it
  ticker <= 0;

 else
  ticker <= ticker + 1;
end

assign click = ((ticker == 5000)?1'b1:1'b0); //click to be assigned high every 0.1 second
reg game_over_flag;

always @ (posedge clock or posedge reset) begin
  if (reset) begin
    game_over_flag <= 0;
    timer <= 1800000;
    start_flag <= 0;
    miss_flag <= 0;
    game_end_reg <= 0;
    reg_d0 <= 0;
    reg_d1 <= 0;
    reg_d2 <= 0;
    reg_d3 <= 8;
    reg_d4 <= 1;
    reg_d5 <= 0;
    reg_d6 <= 0;
    reg_d7 <= 0;
  end else begin
    if (game_end) begin
      game_end_reg <= 1;

    end if (game_end_reg) begin
      start_flag <= 0;

    end if (start) begin
      start_flag <= 1;
    end
    if (start_flag) begin
      if (miss) begin
        if (timer < 11) begin
          timer <= 0;
          game_over_flag <= 1;
        end else begin
          timer <= timer - 50000;
        end
      end else if (click) begin
        if (timer > 1) begin
          timer <= timer - 1;
          reg_d0 <= timer / 100 % 10;
          reg_d1 <= timer / 1000 % 10;
          reg_d2 <= timer / 10000 % 10;
          reg_d3 <= timer / 100000 % 10;
          reg_d4 <= timer / 1000000 % 10;
          reg_d5 <= 0;
          reg_d6 <= 0;
          reg_d7 <= 0;
        end else begin
          timer <= 0;
          game_over_flag <= 1;
        end
      end
    end
  end
end

assign game_over = game_over_flag;

//The Circuit for Multiplexing - Look at my other post for details on this

localparam N = 6;

reg [N-1:0]count; //the 14 bit counter which allows us to multiplex at 1000Hz

always @ (posedge clock or posedge reset)
 begin
  if (reset)
   count <= 0;
  else
   count <= count + 1;
 end

reg [6:0]sseg;
reg [7:0]an_temp;
reg reg_dp;
always @ (*)
 begin
  case(count[N-1:N-3])
   
   3'b000 : 
    begin
     sseg = reg_d0;
     an_temp = 8'b11111110;
     reg_dp = 1'b0;
    end
   
   3'b001:
    begin
     sseg = reg_d1;
     an_temp = 8'b11111101;
     reg_dp = 1'b0;
    end
   
   3'b010:
    begin
     sseg = reg_d2;
     an_temp = 8'b11111011;
     reg_dp = 1'b1;
    end
    
   3'b011:
    begin
     sseg = reg_d3;
     an_temp = 8'b11110111;
     reg_dp = 1'b0;
    end
   
   3'b100 : 
    begin
     sseg = reg_d4;
     an_temp = 8'b11101111;
     reg_dp = 1'b0;
    end
   
   3'b101:
    begin
     sseg = reg_d5;
     an_temp = 8'b11011111;
     reg_dp = 1'b0;
    end
   
   3'b110:
    begin
     sseg = reg_d6;
     an_temp = 8'b10111111;
     reg_dp = 1'b0;
    end
    
   3'b111:
    begin
     sseg = reg_d7;
     an_temp = 8'b01111111;
     reg_dp = 1'b0;
    end
  endcase
 end
assign an = an_temp;

reg [6:0] sseg_temp; 
always @ (*)
 begin
  case(sseg)
   4'd0 : sseg_temp = 7'b0111111;
   4'd1 : sseg_temp = 7'b0000110;
   4'd2 : sseg_temp = 7'b1011011;
   4'd3 : sseg_temp = 7'b1001111;
   4'd4 : sseg_temp = 7'b1100110;
   4'd5 : sseg_temp = 7'b1101101;
   4'd6 : sseg_temp = 7'b1111101;
   4'd7 : sseg_temp = 7'b0000111;
   4'd8 : sseg_temp = 7'b1111111;
   4'd9 : sseg_temp = 7'b1101111;
   default : sseg_temp = 7'b1000000; //dash
  endcase
 end
assign {g, f, e, d, c, b, a} = sseg_temp; 
assign dp = reg_dp;


endmodule