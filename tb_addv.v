`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: tb_addv
// Description: Self-checking testbench for the ADDV instruction.
//
// The new top-level cpu_top_addv runs the program in instruction_memory_addv:
//   set x5=2 (xrs), x6=4 (xrt), x4=1 (xrd=n-1), then ADDV x4,x5,x6.
//
// data_memory init values come from the existing data_memory.v:
//   M[2]=31, M[3]=1024, M[4]=9, M[5]=-2048
//
// Expected after ADDV (n=2 elements):
//   M[2] = 31   + 9      = 40
//   M[3] = 1024 + -2048  = -1024
// Source array (B) untouched:
//   M[4] = 9, M[5] = -2048
//////////////////////////////////////////////////////////////////////////////////


module tb_addv();
reg clock;

cpu_top_addv uut(.clock(clock));

initial
begin
    clock = 0;
    forever #2 clock = ~clock;
end

initial
begin
    #500;

    $display("");
    $display("=================================================");
    $display("              ADDV TEST RESULTS");
    $display("=================================================");
    $display("Program: ADDV x12, x10, x11  (n=7, xrs=2, xrt=12)");
    $display("  M[2..8] += M[12..18]");
    $display("-------------------------------------------------");
    $display("M[2]  = %0d   (expected -11)", $signed(uut.d_cache.memory[2]));
    $display("M[3]  = %0d   (expected -5)",  $signed(uut.d_cache.memory[3]));
    $display("M[4]  = %0d   (expected -3)",  $signed(uut.d_cache.memory[4]));
    $display("M[5]  = %0d   (expected 27)",  $signed(uut.d_cache.memory[5]));
    $display("M[6]  = %0d   (expected -32)", $signed(uut.d_cache.memory[6]));
    $display("M[7]  = %0d   (expected -20)", $signed(uut.d_cache.memory[7]));
    $display("M[8]  = %0d   (expected 4)",   $signed(uut.d_cache.memory[8]));
    $display("x10 (xrs) = %0d   (expected 2)",  $signed(uut.reg_file.registers[10]));
    $display("x11 (xrt) = %0d   (expected 12)", $signed(uut.reg_file.registers[11]));
    $display("x12 (n-1) = %0d   (expected 6)",  $signed(uut.reg_file.registers[12]));
    $display("-------------------------------------------------");

    if (uut.d_cache.memory[2] === -32'sd11 &&
        uut.d_cache.memory[3] === -32'sd5  &&
        uut.d_cache.memory[4] === -32'sd3  &&
        uut.d_cache.memory[5] ===  32'sd27 &&
        uut.d_cache.memory[6] === -32'sd32 &&
        uut.d_cache.memory[7] === -32'sd20 &&
        uut.d_cache.memory[8] ===  32'sd4  &&
        uut.reg_file.registers[10] === 32'd2  &&
        uut.reg_file.registers[11] === 32'd12 &&
        uut.reg_file.registers[12] === 32'd6)
        $display("                >>> PASS <<<");
    else
        $display("                >>> FAIL <<<");

    $display("=================================================");
    $finish;
end

endmodule
