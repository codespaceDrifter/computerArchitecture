`timescale 1ns / 1ps

module instruction_memory_addv(output reg [31:0] instruction,
                                input [7:0] address,
                                input clk);
reg [31:0] instructionMem [255:0];
integer ii;

initial
begin
    for (ii = 0; ii < 256; ii = ii + 1) instructionMem[ii] = 32'b0;

    // INC x10, x0, 2   → x10 = 2  (base address of array a)
    instructionMem[0] = 32'b0101_001010_000000_000000_0000000010;
    // INC x11, x0, 12  → x11 = 12 (base address of array b)
    instructionMem[1] = 32'b0101_001011_000000_000000_0000001100;
    // INC x12, x0, 6   → x12 = 6  (n-1 = 7-1 = 6)
    instructionMem[2] = 32'b0101_001100_000000_000000_0000000110;
    // NOP x3 - wait for INC writebacks to reach register file
    instructionMem[3] = 32'b0;
    instructionMem[4] = 32'b0;
    instructionMem[5] = 32'b0;
    // ADDV x12, x10, x11
    instructionMem[6] = 32'b0001_001100_001010_001011_0000000000;
end

always@(*)
begin
    instruction = instructionMem[address];
end

endmodule