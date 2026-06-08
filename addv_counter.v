`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: addv_counter
// Description: 32-bit synchronous loop-index register for ADDV.
//              Reset to 0 on counter_reset, +1 on counter_en, else hold.
//////////////////////////////////////////////////////////////////////////////////


module addv_counter(input clock,
                    input counter_reset,
                    input counter_en,
                    output reg [31:0] count);

initial begin
    count = 0;
end

always@(posedge clock)
begin
    if (counter_reset)
        count <= 32'd0;
    else if (counter_en)
        count <= count + 32'd1;
end
endmodule
