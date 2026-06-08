`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2024 07:17:22 PM
// Design Name: 
// Module Name: id_ex_buffer
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


module id_ex_buffer(input clock,
                    input in_reg_wrt, 
                    input in_mem_two_reg, 
                    input in_mem_wrt, 
                    input in_mem_rd, 
                    input [2:0] in_alu_op, 
                    input in_alu_src, 
                    input in_save_pc,
                    input [31:0] in_pc,
                    input [31:0] in_Y,
                    input [31:0] in_xrs,
                    input [31:0] in_xrt,
                    input [5:0] in_rd,
                    output reg out_reg_wrt, 
                    output reg out_mem_two_reg, 
                    output reg out_mem_wrt, 
                    output reg out_mem_rd, 
                    output reg [2:0] out_alu_op, 
                    output reg out_alu_src, 
                    output reg out_save_pc,
                    output reg [31:0] out_pc,
                    output reg [31:0] out_Y,
                    output reg [31:0] out_xrs,
                    output reg [31:0] out_xrt,
                    output reg [5:0] out_rd);
                    
initial begin
    out_reg_wrt = 0;
    out_mem_two_reg = 0;
    out_mem_wrt = 0;
    out_mem_rd = 0;
    out_alu_op = 0;
    out_alu_src = 0;
    out_save_pc = 0;
    out_pc = 0;
    out_Y = 0;
    out_xrs = 0;
    out_xrt = 0;
    out_rd = 0;
end

always@(posedge clock)
begin
    out_reg_wrt <= in_reg_wrt;
    out_mem_two_reg <= in_mem_two_reg;
    out_mem_wrt <= in_mem_wrt;
    out_mem_rd <= in_mem_rd;
    out_alu_op <= in_alu_op;
    out_alu_src <= in_alu_src;
    out_save_pc <= in_save_pc;
    out_pc <= in_pc;
    out_Y <= in_Y;
    out_xrs <= in_xrs;
    out_xrt <= in_xrt;
    out_rd <= in_rd;
end
endmodule
