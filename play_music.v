module play_music (
    input clock,
    input wrong,
    input is_round,
    output is_music_playing,
    output reset_current_index,
    output counter
);

reg [15:0] ticker; //23 bits needed to count up to 5M bitsa
wire click;
reg is_begin;

always @ (posedge clock or posedge reset)
begin
 if(reset)
  ticker <= 0;
 else if(ticker == 5000000) // 1초
  ticker <= 0;
end

assign click = ((ticker == 5000000)?1'b1:1'b0); //click to be assigned high every 0.1 second

always @ (posedge clock or posedge reset)
begin
 if (reset)
  begin
   click <= 0;
   is_music_playing <= 0;
   reset_current_index <= 0;
   is_begin <= 0;
  end

 else if (is_begin == 0)
  begin
    reset_current_index <= 1;
    is_begin <= 1;
  end

 else if (click) //increment at every click
  begin
   if (is_begin == 1) begin
    reset_current_index <= 0;
  end
  
  
  

   
  end
end


endmodule 