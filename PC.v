`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2024 07:17:22 PM
// Design Name: 
// Module Name: PC
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


module PC(PCin, PCout, clock);
    input [31:0] PCin;
    input clock;
    output reg [31:0] PCout;
    
initial
begin
    PCout = 0;
end

always@(posedge clock)
begin
    PCout <= PCin;
end
endmodule
