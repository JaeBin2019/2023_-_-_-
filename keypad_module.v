module keypad_module (
    input clk,
    input reset,
    input [3:0] keypad_input,
    input keypad_input_enable,
    output [3:0] keypad_out,
    output keypad_enable_out
  );

    reg [3:0] keypad_reg;
    reg keypad_enable_out_reg;

always @ (posedge clk or posedge reset or posedge keypad_input_enable)
begin
    if(reset) begin
        keypad_reg <= 0;
        keypad_enable_out_reg <= 0;

    end else if (keypad_input_enable) begin
        keypad_enable_out_reg <= 1;
        if (keypad_input != 0) begin
            keypad_reg <= keypad_input;
        end

    end else if (keypad_enable_out_reg) begin
        keypad_enable_out_reg <= 0;
    end

end

assign keypad_out = keypad_reg;
assign keypad_enable_out = keypad_enable_out_reg;

endmodule