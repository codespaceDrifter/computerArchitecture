`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2024 07:30:58 PM
// Design Name: 
// Module Name: if_id_buffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module if_id_buffer(input clock,
                    input [31:0] in_instruction,
                    input [31:0] in_PC, 
                    output reg[31:0] out_instruction, 
                    output reg[31:0] out_PC);

initial begin
    out_instruction = 0;
    out_PC = 0;
end

always@(posedge clock)
begin
    out_instruction <= in_instruction;
    out_PC <= in_PC;
end
  
endmodule
