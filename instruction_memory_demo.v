`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Instruction memory for the demo assembly program from demo_assembly (1).txt
//////////////////////////////////////////////////////////////////////////////////

module instruction_memory_demo(output reg [31:0] instruction, input [7:0] address, input clk);
reg [31:0] instructionMem [255:0];

integer ii;
initial
begin
    for (ii = 0; ii < 256; ii = ii + 1) instructionMem[ii] = 32'b00000000000000000000000000000000;

    instructionMem[0] = 32'b11110000010000000000000001100100; // SVPC 1 100
    instructionMem[1] = 32'b11110010100000000000000000001100; // SVPC 10 LABEL1
    instructionMem[2] = 32'b11110010110000000000000000010111; // SVPC 11 LABEL2
    instructionMem[3] = 32'b11110011000000000000000000001110; // SVPC 12 SKIP1
    instructionMem[4] = 32'b11110011010000000000000000011001; // SVPC 13 SKIP2
    instructionMem[5] = 32'b00000000000000000000000000000000; // NOP
    instructionMem[6] = 32'b00000000000000000000000000000000; // NOP
    instructionMem[7] = 32'b00000000000000000000000000000000; // NOP
    instructionMem[8] = 32'b01010000100000010000000000000100; // INC 2 1 4
    instructionMem[9] = 32'b01100000110000010000000000000000; // NEG 3 1
    instructionMem[10] = 32'b10110000000010100000000000000000; // BRN 10
    instructionMem[11] = 32'b00000000000000000000000000000000; // NOP
    instructionMem[12] = 32'b01010000100000100000000000010001; // INC 2 2 17
    instructionMem[13] = 32'b01000001000000010000100000000000; // ADD 4 1 2
    instructionMem[14] = 32'b10110000000011000000000000000000; // BRN 12
    instructionMem[15] = 32'b00000000000000000000000000000000; // NOP
    instructionMem[16] = 32'b01010001000001000000000000000110; // INC 4 4 6
    instructionMem[17] = 32'b00110000000000010000010000000000; // ST 1 1
    instructionMem[18] = 32'b11100001010000010000000000000000; // LD 5 1
    instructionMem[19] = 32'b01000001100000010000100000000000; // ADD 6 1 2
    instructionMem[20] = 32'b00000000000000000000000000000000; // NOP
    instructionMem[21] = 32'b01110001110001010000010000000000; // SUB 7 5 1
    instructionMem[22] = 32'b10010000000010110000000000000000; // BRZ 11
    instructionMem[23] = 32'b00000000000000000000000000000000; // NOP
    instructionMem[24] = 32'b01010000100000101111111111110100; // INC 2 2 -12
    instructionMem[25] = 32'b01000010000000010000100000000000; // ADD 8 1 2
    instructionMem[26] = 32'b10010000000011010000000000000000; // BRZ 13
    instructionMem[27] = 32'b00000000000000000000000000000000; // NOP
    instructionMem[28] = 32'b01010010000010000000000000001010; // INC 8 8 10
    instructionMem[29] = 32'b01010010010000011111111111111011; // INC 9 1 -5
    instructionMem[30] = 32'b10000000000000010000000000000000; // JM 1

    instructionMem[100] = 32'b10000000000000010000000000000000; // JM x1
end

always@(*)
begin
    instruction = instructionMem[address];
end

endmodule
