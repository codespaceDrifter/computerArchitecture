`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2024 08:41:27 PM
// Design Name: 
// Module Name: register_file
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


module register_file(output reg [31:0] rt_out, 
                    output reg [31:0] rs_out, 
                    input [31:0] data_in, 
                    input [5:0] rd, 
                    input [5:0] rt, 
                    input [5:0] rs, 
                    input write, 
                    input clk );
reg [31:0] registers [63:0] ;

initial
begin
    rt_out = 0;
    rs_out = 0;
    registers[0] = 0;
    registers[1] = 0;
    registers[2] = 2; // starting address of data to find max
    registers[3] = 5 ; // n numbers to compare
    registers[4] = 0;
    registers[5] = 0;
    registers[6] = 0;
    registers[7] = 0;
    registers[8] = 0;
    registers[9] = 0;
    registers[10] = 0;
    registers[11] = 0;
    registers[12] = 0;
    registers[13] = 0;
    registers[14] = 0;
    registers[15] = 1000;
end
                    
always@(negedge clk)
begin
    rt_out = registers[rt];
    rs_out = registers[rs];
    if(write)begin
        registers[rd] = data_in;
    end
end
endmodule
