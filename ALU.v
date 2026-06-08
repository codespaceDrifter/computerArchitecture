`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2024 05:31:27 PM
// Design Name: 
// Module Name: control_unit
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


module ALU(input [31:0] A, input [31:0] B, input [2:0] opcode, output reg [31:0] out, output reg Z, output reg  N);
always@(*)
begin
    case(opcode)
     3'b100:
        out =  A + B;
     3'b000:
        out =  A + B;
     3'b010:
        out = 0 - B;
     3'b001:
        out = B - A;
     3'b111:
        out = A;
     default:
        out = A + B;
     endcase
N = out[31];
if(out == 0)begin
Z = 1;
end
else begin
Z = 0;
end;
     
end
endmodule


module adder32(input [31:0] A, input [31:0] B, output reg [31:0] out);

always@(*)
begin
    out = A + B;
end
endmodule