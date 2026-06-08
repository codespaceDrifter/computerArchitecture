`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2024 08:41:27 PM
// Design Name: 
// Module Name: instruction_memory
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


module instruction_memory(output reg [31:0] instruction, input [7:0] address, input clk);
reg [31:0] instructionMem [255:0];

integer ii;
initial
begin
    for (ii = 0; ii < 256; ii = ii + 1) instructionMem[ii] = 32'b0;

    // PC=0  INC x10, x0, 2    →  x10 = 2  (&a, base of array A)
    instructionMem[0] = 32'b0101_001010_000000_000000_0000000010;

    // PC=1  INC x11, x0, 12   →  x11 = 12 (&b, base of array B)
    instructionMem[1] = 32'b0101_001011_000000_000000_0000001100;

    // PC=2  INC x12, x0, 6    →  x12 = 6  (rd = n-1 = 7-1)
    instructionMem[2] = 32'b0101_001100_000000_000000_0000000110;

    // PC=3,4,5  NOP × 3  - let INC writebacks reach register file
    instructionMem[3] = 32'b0;
    instructionMem[4] = 32'b0;
    instructionMem[5] = 32'b0;

    // PC=6  ADDV x12, x10, x11
    //        opcode=0001, rd=x12(001100), rs=x10(001010), rt=x11(001011)
    instructionMem[6] = 32'b0001_001100_001010_001011_0000000000;
end

always@(*)
begin
    instruction = instructionMem[address];
end

endmodule