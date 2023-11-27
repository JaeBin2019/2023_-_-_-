// https://simplefpga.blogspot.com/2012/07/to-code-stopwatch-in-verilog.html


module stopwatch(
    input clock,
    input reset,
    input start,
    input miss,
    output a, b, c, d, e, f, g, dp, fail,
    output [7:0] an
    );

reg [7:0] reg_d0, reg_d1, reg_d2, reg_d3, reg_d4, reg_d5, reg_d6, reg_d7; //registers that will hold the individual counts
reg [22:0] ticker; //23 bits needed to count up to 5M bitsa
reg [22:0] timer;
wire click;

//the mod 5M clock to generate a tick ever 0.1 second

always @ (posedge clock or posedge reset)
begin
 if(reset)

  ticker <= 0;

  // 50MHz * 0.0001 = 5000
 else if(ticker == 5000) //if it reaches the desired max value reset it
  ticker <= 0;
 else if(start) //only start if the input is set high
  ticker <= ticker + 1;
end

assign click = ((ticker == 5000)?1'b1:1'b0); //click to be assigned high every 0.1 second

always @ (posedge clock or posedge reset or posedge miss)
begin
 if (reset)
  begin
   timer <= 1800000;
   fail <= 0;
   reg_d0 <= 0;
   reg_d1 <= 0;
   reg_d2 <= 0;
   reg_d3 <= 0;
   reg_d4 <= 0;
   reg_d5 <= 8;
   reg_d6 <= 1;
   reg_d7 <= 0;
  end
  
 else if (click) //increment at every click
  if (timer > 0) begin
   // When Miss
   if (miss == 1) begin
    timer <= timer - 10;
   end
   timer <= timer - 1;
   reg_d0 <= timer % 10;
   reg_d1 <= timer / 10 % 10;
   reg_d2 <= timer / 100 % 10;
   reg_d3 <= timer / 1000 % 10;
   reg_d4 <= timer / 10000 % 10;
   reg_d5 <= timer / 100000 % 10;
   reg_d6 <= timer / 1000000 % 10;
   reg_d7 <= timer / 10000000 % 10;
  end else begin
    fail <= 1;
  end
end


//The Circuit for Multiplexing - Look at my other post for details on this

localparam N = 14;

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
     an_temp = 4'b11111110;
     reg_dp = 1'b0;
    end
   
   3'b001:
    begin
     sseg = reg_d1;
     an_temp = 4'b11111101;
     reg_dp = 1'b0;
    end
   
   3'b010:
    begin
     sseg = reg_d2;
     an_temp = 4'b11111011;
     reg_dp = 1'b0;
    end
    
   3'b011:
    begin
     sseg = reg_d3;
     an_temp = 4'b11110111;
     reg_dp = 1'b0;
    end
   
   3'b100 : 
    begin
     sseg = reg_d4;
     an_temp = 4'b11101111;
     reg_dp = 1'b1;
    end
   
   3'b101:
    begin
     sseg = reg_d5;
     an_temp = 4'b11011111;
     reg_dp = 1'b0;
    end
   
   3'b110:
    begin
     sseg = reg_d6;
     an_temp = 4'b10111111;
     reg_dp = 1'b0;
    end
    
   3'b111:
    begin
     sseg = reg_d7;
     an_temp = 4'b01111111;
     reg_dp = 1'b0;
    end
  endcase
 end
assign an = an_temp;

reg [6:0] sseg_temp; 
always @ (*)
 begin
  case(sseg)
   4'd0 : sseg_temp = 7'b1000000;
   4'd1 : sseg_temp = 7'b1111001;
   4'd2 : sseg_temp = 7'b0100100;
   4'd3 : sseg_temp = 7'b0110000;
   4'd4 : sseg_temp = 7'b0011001;
   4'd5 : sseg_temp = 7'b0010010;
   4'd6 : sseg_temp = 7'b0000010;
   4'd7 : sseg_temp = 7'b1111000;
   4'd8 : sseg_temp = 7'b0000000;
   4'd9 : sseg_temp = 7'b0010000;
   default : sseg_temp = 7'b0111111; //dash
  endcase
 end
assign {g, f, e, d, c, b, a} = sseg_temp; 
assign dp = reg_dp;


endmodule