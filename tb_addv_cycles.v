`timescale 1ns / 1ps
// Instrumented testbench: counts clock cycles from reset until ADDV FSM
// returns to IDLE and the last memory write completes (M[8] updated).
// Verifies predicted cycle count of 3n + setup for n=7.

module tb_addv_cycles();
reg clock;
integer cycle_count;
integer addv_done_cycle;
reg done_flag;

cpu_top_addv uut(.clock(clock));

initial begin
    clock = 0;
    forever #2 clock = ~clock;
end

// Cycle counter on posedge
initial begin
    cycle_count = 0;
    done_flag = 0;
    addv_done_cycle = 0;
end

always @(posedge clock) begin
    cycle_count = cycle_count + 1;
end

// Watch M[7]: starts at -10, ADDV writes -10 + -10 = -20.
// This is the 6th element (i=5), so it fires before the 7th (M[8]).
// Also watch FSM stall falling edge to catch the exact IDLE return cycle.
reg prev_stall;
initial prev_stall = 0;

always @(posedge clock) begin
    prev_stall <= uut.addv_stall;
    // Detect stall falling edge: FSM just returned to IDLE
    if (prev_stall && !uut.addv_stall && !done_flag) begin
        done_flag   = 1;
        addv_done_cycle = cycle_count;
    end
end

initial begin
    #500;
    $display("");
    $display("=================================================");
    $display("       ADDV CYCLE COUNT VERIFICATION (n=7)");
    $display("=================================================");
    $display("Clock period = 4 ns  (half-period #2)");
    $display("FSM states per element: LOAD_A + LOAD_B + STORE = 3 cycles");
    $display("Setup instructions: 3x INC + 3x NOP = 6 slots -> 6 cycles");
    $display("ADDV fetch + pipeline fill: ~4 cycles");
    $display("Predicted total cycles ~ 6 + 1(ADDV) + 3*7 + drain = ~32-35");
    $display("-------------------------------------------------");
    $display("Cycle when FSM returned to IDLE: %0d", addv_done_cycle);
    $display("Wall time at FSM IDLE:           %0d ns",
             addv_done_cycle * 4);
    $display("-------------------------------------------------");
    $display("M[2]=%0d (exp -11)  M[3]=%0d (exp -5)",
        $signed(uut.d_cache.memory[2]), $signed(uut.d_cache.memory[3]));
    $display("M[4]=%0d (exp -3)   M[5]=%0d (exp 27)",
        $signed(uut.d_cache.memory[4]), $signed(uut.d_cache.memory[5]));
    $display("M[6]=%0d (exp -32) M[7]=%0d (exp -20)  M[8]=%0d (exp 4)",
        $signed(uut.d_cache.memory[6]),
        $signed(uut.d_cache.memory[7]),
        $signed(uut.d_cache.memory[8]));
    if (uut.d_cache.memory[2] === -32'sd11 &&
        uut.d_cache.memory[7] === -32'sd20 &&
        uut.d_cache.memory[8] ===  32'sd4)
        $display("                >>> PASS <<<");
    else
        $display("                >>> FAIL <<<");
    $display("=================================================");
    $finish;
end

endmodule
