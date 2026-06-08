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


module control_unit(opcode, regWrite, aluSrc, aluOp, savePc, memWrite, memRead, MemtoReg, branch_neg, branch_zero, jump);
input [3:0] opcode;
output reg [2:0] aluOp;
output reg regWrite, aluSrc, savePc, memWrite, memRead, MemtoReg, branch_neg, branch_zero, jump;

always@(*)
begin

// NOP defaults - covers unmatched opcodes and unknown (X) bits cleanly
regWrite = 0;
aluSrc = 0;
aluOp = 3'b000;
savePc = 0;
memWrite = 0;
memRead = 0;
MemtoReg = 0;
branch_neg = 0;
branch_zero = 0;
jump = 0;

if (opcode == 4'b0000) //No aluOp
begin
     regWrite = 0;
     aluSrc = 0;
     aluOp = 3'b000;
     savePc = 0;
     memWrite = 0;
     memRead = 0;
     MemtoReg = 0;
     branch_neg = 0;
     branch_zero = 0;
     jump = 0;
end

if (opcode == 4'b1111) //Save PC
begin
     regWrite = 1;
     aluSrc = 1;
     aluOp = 3'b100; 
     savePc = 1;
     memWrite = 0;
     memRead = 0;
     MemtoReg = 0;
     branch_neg = 0;
     branch_zero = 0;
     jump = 0;
end

if (opcode == 4'b1110) //load
begin
     regWrite = 1;
     aluSrc = 0;
     aluOp = 3'b000; 
     savePc = 0;
     memWrite = 0;
     memRead = 1;
     MemtoReg = 1;
     branch_neg = 0;
     branch_zero = 0;
     jump = 0;
end

if (opcode == 4'b0011) //store
begin
     regWrite = 0;
     aluSrc = 0;
     aluOp = 3'b000; 
     savePc = 0;
     memWrite = 1;
     memRead = 0;
     MemtoReg = 0;
     branch_neg = 0;
     branch_zero = 0;
     jump = 0;
end

if (opcode == 4'b0100) //add
begin
     regWrite = 1;
     aluSrc = 0;
     aluOp = 3'b100; 
     savePc = 0;
     memWrite = 0;
     memRead = 0;
     MemtoReg = 0;
     branch_neg = 0;
     branch_zero = 0;
     jump = 0;
end

if (opcode == 4'b0101) //inc
begin
     regWrite = 1;
     aluSrc = 1;
     aluOp = 3'b100; 
     savePc = 0;
     memWrite = 0;
     memRead = 0;
     MemtoReg = 0;
     branch_neg = 0;
     branch_zero = 0;
     jump = 0;
end

if (opcode == 4'b0110) //neg
begin
     regWrite = 1;
     aluSrc = 0;
     aluOp = 3'b010; 
     savePc = 0;
     memWrite = 0;
     memRead = 0;
     MemtoReg = 0;
     branch_neg = 0;
     branch_zero = 0;
     jump = 0;
end

if (opcode == 4'b0111) //sub
begin
     regWrite = 1;
     aluSrc = 0;
     aluOp = 3'b001; 
     savePc = 0;
     memWrite = 0;
     memRead = 0;
     MemtoReg = 0;
     branch_neg = 0;
     branch_zero = 0;
     jump = 0;
end

if (opcode == 4'b1000) //jump
begin
     regWrite = 0;
     aluSrc = 0;
     aluOp = 3'b000; 
     savePc = 0;
     memWrite = 0;
     memRead = 0;
     MemtoReg = 0;
     branch_neg = 0;
     branch_zero = 0;
     jump = 1;
end

if (opcode == 4'b1001) //branch zero
begin
     regWrite = 0;
     aluSrc = 0;
     aluOp = 3'b000; 
     savePc = 0;
     memWrite = 0;
     memRead = 0;    
     MemtoReg = 0;
     branch_neg = 0;
     branch_zero = 1;
     jump = 0;
end

if (opcode == 4'b1011) //branch neg
begin
     regWrite = 0;
     aluSrc = 0;
     aluOp = 3'b000; 
     savePc = 1;
     memWrite = 0;
     memRead = 0;
     MemtoReg = 0;
     branch_neg = 1;
     branch_zero = 0;
     jump = 0;
end

end
endmodule