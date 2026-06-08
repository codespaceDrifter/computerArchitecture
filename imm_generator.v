`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2024 07:51:13 PM
// Design Name: 
// Module Name: imm_generator
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


module imm_generator(input [31:0] instruction, output reg [31:0] Y);

initial
begin
    Y = 0;
end

always@(instruction)
begin
    case(instruction[31:28])
    // Save PC: Y = RS + RT + 10 unused bits
     4'b1111:
        if(instruction[21] == 1)
            Y = {10'b1111111111,instruction[21:0]};
        else if (instruction[21] == 0)
            Y = {10'b0000000000, instruction[21:0]};
    // Increment: Y = RT + 10 unused bitss     
     4'b0101:
        if(instruction[15] == 1)
            Y = {16'b1111111111111111, instruction[15:0]};
        else if (instruction[15] == 0)
            Y = {16'b0000000000000000, instruction[15:0]};
            
     endcase   
end

endmodule
