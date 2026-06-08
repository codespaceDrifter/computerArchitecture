`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: addv_temp_reg
// Description: 32-bit register with synchronous enable. Used for temp_a, temp_b,
//              and the xrd-value capture register.
//////////////////////////////////////////////////////////////////////////////////


module addv_temp_reg(input clock,
                     input en,
                     input [31:0] din,
                     output reg [31:0] dout);

initial begin
    dout = 0;
end

always@(posedge clock)
begin
    if (en)
        dout <= din;
end
endmodule
