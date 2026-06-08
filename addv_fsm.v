`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: addv_fsm
// Description: 4-state Moore FSM that takes over the EX/MEM stage for ADDV.
//              IDLE -> LOAD_A -> LOAD_B -> STORE; loops until count == xrd.
//////////////////////////////////////////////////////////////////////////////////


module addv_fsm(input clock,
                input [3:0] opcode,
                input loop_done,
                output reg addv_stall,
                output reg fsm_mem_read,
                output reg fsm_mem_write,
                output reg [1:0] addr_sel,
                output reg base_sel,
                output reg temp_a_en,
                output reg temp_b_en,
                output reg counter_reset,
                output reg counter_en,
                output reg alu_a_sel,
                output reg alu_b_sel,
                output reg [2:0] fsm_alu_op,
                output reg wd_sel);

localparam IDLE   = 2'b00,
           LOAD_A = 2'b01,
           LOAD_B = 2'b10,
           STORE  = 2'b11;

reg [1:0] state, next_state;

initial begin
    state = IDLE;
end

always@(posedge clock)
begin
    state <= next_state;
end

// next-state logic
always@(*)
begin
    case(state)
        IDLE:    next_state = (opcode == 4'b0001) ? LOAD_A : IDLE;
        LOAD_A:  next_state = LOAD_B;
        LOAD_B:  next_state = STORE;
        STORE:   next_state = loop_done ? IDLE : LOAD_A;
        default: next_state = IDLE;
    endcase
end

// Moore outputs
always@(*)
begin
    // defaults (IDLE behavior)
    addv_stall    = 1'b0;
    fsm_mem_read  = 1'b0;
    fsm_mem_write = 1'b0;
    addr_sel      = 2'b00;
    base_sel      = 1'b0;
    temp_a_en     = 1'b0;
    temp_b_en     = 1'b0;
    counter_reset = 1'b0;
    counter_en    = 1'b0;
    alu_a_sel     = 1'b0;
    alu_b_sel     = 1'b0;
    fsm_alu_op    = 3'b000;
    wd_sel        = 1'b0;

    case(state)
        IDLE: begin
            // Pulse counter_reset (and latch xrd) the cycle ADDV is decoded.
            counter_reset = (opcode == 4'b0001);
        end
        LOAD_A: begin
            addv_stall   = 1'b1;
            fsm_mem_read = 1'b1;
            addr_sel     = 2'b01;  // addr_adder, base_sel=xrs
            base_sel     = 1'b0;
            temp_a_en    = 1'b1;
        end
        LOAD_B: begin
            addv_stall   = 1'b1;
            fsm_mem_read = 1'b1;
            addr_sel     = 2'b10;  // addr_adder, base_sel=xrt
            base_sel     = 1'b1;
            temp_b_en    = 1'b1;
        end
        STORE: begin
            addv_stall    = 1'b1;
            fsm_mem_write = 1'b1;
            addr_sel      = 2'b01;  // addr_adder, base_sel=xrs
            base_sel      = 1'b0;
            counter_en    = 1'b1;
            alu_a_sel     = 1'b1;   // route temp_a into ALU port A
            alu_b_sel     = 1'b1;   // route temp_b into ALU port B
            fsm_alu_op    = 3'b100; // force ADD (per ALU encoding in ALU.v)
            wd_sel        = 1'b1;   // route ALU result to data-memory write port
        end
    endcase
end
endmodule
