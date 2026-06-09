# Performance Analysis — SCU ISA Pipelined CPU
## CSEN 122L Spring 2026

---

## 1. Pipeline Architecture Summary

The CPU implements a **4-stage in-order pipeline** with no data forwarding:

| Stage | Function | Key Components |
|-------|----------|----------------|
| IF | Fetch instruction | Instruction memory (combinational) |
| ID | Decode + register read | Register file (read on `negedge`) |
| EX | Execute + data memory | ALU + data memory |
| WB | Write-back | Register file (write on `negedge`) |

**Register file** reads and writes both occur on `negedge clk` using blocking assignments, with reads executing before writes in the same `always` block.  
**Branch/jump** signals are resolved combinationally in the EX stage: `Z`/`N` flags come from the ALU, and `branch_zero`/`branch_neg` come from the ID-stage control unit. One **delay slot** follows every branch and jump.

---

## 2. Cycle Time Analysis

Only instruction memory, data memory, register file, and ALU (adder) contribute delay. All other components (muxes, PC adder, pipeline registers) are ignored.

| Stage | Critical Path | Delay |
|-------|--------------|-------|
| IF | PC → instruction memory → IF/ID input | **2 ns** |
| ID | IF/ID output → register file read → ID/EX input | **1.5 ns** |
| EX | ID/EX output → ALU  **or**  data memory read | max(2, 2) = **2 ns** |
| WB | EX/WB output → MUX → register file write | **1.5 ns** |

$$T_{\text{cycle (theoretical)}} = \max(2,\ 1.5,\ 2,\ 1.5) = \boxed{2 \text{ ns}} \quad \Rightarrow \quad f_{\text{max}} = 500 \text{ MHz}$$

### ALU Truth Table (from Appendix)

| ADD | NEG | SUB | OUT | Operation |
|-----|-----|-----|-----|-----------|
| 0 | 0 | 0 | A + B | Add |
| 0 | 1 | 0 | Don't Care | No Operation |
| 1 | 0 | 1 | A − B | Subtract |
| 1 | 1 | 0 | −A | 2's Complement |
| 1 | 1 | 1 | A | Pass A |

`Z = 1` iff OUT = 0; `N = 1` iff OUT is negative (OUT[31] = 1).

### Implemented Clock Period

The implementation uses `forever #2 clock = ~clock` → **T = 4 ns** (f = 250 MHz).  
This 2× margin accounts for the negedge-triggered register file, where the ALU result (Z/N flag) must settle before `negedge` for the branch mux to function correctly, constraining the half-period to ≥ 2 ns.

---

## 3. Hazard Analysis and NOP Requirements

Because there is **no forwarding**, data hazards must be resolved entirely by software-inserted NOPs.

**Write-to-read timing:**
- A writing instruction entering IF at cycle *N* writes its result to the register file at `negedge(N+3)`.
- A dependent reading instruction entering IF at cycle *M* reads the register file at `negedge(M+1)`.
- For correct data: `negedge(M+1) > negedge(N+3)` → **M ≥ N+3** → minimum **2 NOPs** between writer and reader.

**Branch/jump delay slots:**
- Z/N flags are read combinationally from the ALU (EX stage) when the branch is in ID.
- The flag-setting instruction immediately before the branch is in EX at that moment — no NOP required between flag-setter and branch.
- One instruction after every branch/jump **always executes** (delay slot).

| Instruction pair | NOPs required | Effective slots |
|-----------------|--------------|-----------------|
| Writer → dependent reader | 2 | 3 slots for 2 useful instructions |
| Branch/jump delay slot | 1 | 1 slot overhead per branch |
| Flag-setter → BRZ/BRN | 0 | back-to-back is correct |
| Independent consecutive | 0 | 1 slot per instruction |

---

## 4. Instruction Count and Cycle Count in Terms of n

### Version 1: Software Loop (benchmark.asm, no ADDV)

The vector-add loop body structure (one iteration over elements a[i] and b[i]):

```
LOOP_TOP:
    INC  r1, r1, 0          ; [1] check counter (sets Z flag)
    BRZ  r11                ; [2] exit if counter == 0
    NOP                      ; [3] branch delay slot
    NOP                      ; [4] pipeline padding (conservative)
    LD   r20, r2            ; [5] load a[i]
    LD   r21, r3            ; [6] load b[i]
    NOP                      ; [7] \
    NOP                      ; [8]  2-cycle data hazard: r20/r21 not yet written
    ADD  r22, r20, r21      ; [9] compute sum
    NOP                      ; [10] \
    NOP                      ; [11]  2-cycle data hazard: r22 not yet written
    ST   r22, r2            ; [12] a[i] = sum
    INC  r2, r2, 1          ; [13] pa++
    INC  r3, r3, 1          ; [14] pb++
    INC  r1, r1, -1         ; [15] counter--
    SUB  r23, r23, r23      ; [16] force Z=1 for unconditional backward branch
    BRZ  r10                ; [17] jump back to LOOP_TOP
    NOP                      ; [18] branch delay slot
    ; [PC skips here — backward branch taken, next fetch is LOOP_TOP]
```

**Slot count per iteration (non-exit):** 18  
  — 11 useful instructions + 7 NOPs (4 data-hazard + 2 delay-slot + 1 padding)

**Setup overhead (before loop):** 3 slots (SVPC, SVPC, NOP)  
**Exit iteration (when counter = 0):** 4 slots (INC, BRZ, NOP delay, DONE NOP)

$$\boxed{I_{\text{V1}}(n) = 18n + 7 \approx 18n}$$

$$\boxed{\text{Cycles}_{\text{V1}}(n) = 18n + 7 \approx 18n}$$

(CPI = 1 per slot; no hardware stalls)

**Effective CPI per useful (non-NOP) instruction:**

$$\text{CPI}_{\text{eff}} = \frac{18}{11} \approx \boxed{1.64}$$

---

### Version 2: ADDV Hardware Instruction

The ADDV program (benchmark.asm Version 2):

```
INC  r4, r1, -1   ; [1] r4 = n-1  (xrd for ADDV)
NOP               ; [2] \
NOP               ; [3]  2-cycle data hazard: r4 must be in reg file before ADDV reads it
ADDV r4, r2, r3   ; [4] hardware vector add
```

Setup: 4 slots (constant, independent of n).  
The ADDV FSM runs a 4-state loop (IDLE → LOAD_A → LOAD_B → STORE) for each element:

| FSM State | Action | Cycles |
|-----------|--------|--------|
| LOAD_A | Read M[xrs + i] into temp_a | 1 per element |
| LOAD_B | Read M[xrt + i] into temp_b | 1 per element |
| STORE | Write ALU(temp_a + temp_b) to M[xrs + i]; i++ | 1 per element |

Each element requires exactly **3 FSM stall cycles**. The pipeline is frozen (PC, IF/ID, ID/EX re-circulate) during the entire FSM run.

$$\boxed{I_{\text{V2}}(n) = \text{constant} = 7 \text{ slots}}$$

$$\boxed{\text{Cycles}_{\text{V2}}(n) = 3n + 9 \approx 3n}$$

(3 FSM cycles per element × n elements, plus ~9 cycles of setup and pipeline fill)

---

## 5. Summary Table

| Metric | Version 1 (software) | Version 2 (ADDV) |
|--------|-----------------------|------------------|
| Instruction count | 18n + 7 | 7 (constant) |
| Total cycles | 18n + 7 | 3n + 9 |
| Cycles per element | 18 | 3 |
| Effective CPI | 18/11 ≈ **1.64** | — |
| Clock period | 4 ns (impl.), 2 ns (max) | same |
| Execution time @ 4 ns | ≈ 72n ns | ≈ 12n ns |

$$\boxed{\text{Speedup (ADDV vs. software)}} = \frac{18n}{3n} = \mathbf{6\times} \quad \text{(for large } n\text{)}$$

---

## 6. Simulation Verification

### 6.1 Demo Assembly Test — CPI Verification

**Testbench:** `tb_cpu_demo.v` using `instruction_memory_demo.v`  
**Clock:** `forever #2 clock = ~clock` → T = 4 ns

The demo program executes 30 instruction slots (including NOPs and delay slots), taking branches at PC=10 (BRN, skips PC=12) and PC=22 (BRZ, skips PC=24), then jumps via JM to PC=100.

```
Simulation log (key excerpt):
  time=0        pc_out=0   instr=00000000
  time=2000     pc_out=1   instr=f0400064   ← SVPC x1,100; x1 written at negedge
  ...
  time=42000    pc_out=11  instr=b00a0000   ← BRN in ID; N=1 from NEG → branch taken
  time=46000    pc_out=13                   ← delay slot executed; jumped over PC=12
  ...
  time=90000    pc_out=25                   ← BRZ taken; jumped over PC=24
  ...
  time=114000   pc_out=31  instr=80010000   ← JM x1 in ID
  time=118000   pc_out=100                  ← JM executes; delay slot NOP at PC=31 ran
  time=118000   pc_out=101 (infinite loop)
```

**Cycles to reach PC=100:** (118000 − 2000) / 4000 + 1 = **30 cycles**  
**Instructions fetched:** 30 (exactly one per cycle)  
**Measured CPI = 30/30 = 1.00** ✓

```
=================================================
            CPU DEMO ASSEMBLY TEST RESULTS
=================================================
x1 = 100   (expected 100)   ✓
x2 = 104   (expected 104)   ✓
x3 = -100  (expected -100)  ✓
x4 = 210   (expected 210)   ✓
x5 = 100   (expected 100)   ✓
x6 = 204   (expected 204)   ✓
x7 = 0     (expected 0)     ✓
x8 = 214   (expected 214)   ✓
x9 = 95    (expected 95)    ✓
Mem[100] = 100 (expected 100) ✓
                >>> PASS <<<
=================================================
```

### 6.2 ADDV Test — FSM Cycle Count Verification (n = 7)

**Testbench:** `tb_addv_cycles.v` / `tb_addv.v` using `cpu_top_addv` + `instruction_memory_addv`  
**Problem size:** n = 7; xrd = n−1 = 6; xrs = 2 (base of array a); xrt = 12 (base of array b)

**Prediction:** 3n + 9 = 3(7) + 9 = **30 cycles** until FSM returns to IDLE

**Measured result (from `tb_addv_cycles.v`):**

```
=================================================
       ADDV CYCLE COUNT VERIFICATION (n=7)
=================================================
Clock period = 4 ns  (half-period #2)
FSM states per element: LOAD_A + LOAD_B + STORE = 3 cycles
Cycle when FSM returned to IDLE: 30
Wall time at FSM IDLE: 120 ns
-------------------------------------------------
M[2]=-11 (exp -11)  M[3]=-5  (exp -5)
M[4]=-3  (exp -3)   M[5]=27  (exp 27)
M[6]=-32 (exp -32)  M[7]=-20 (exp -20)  M[8]=4 (exp 4)
                >>> PASS <<<
=================================================
```

**Predicted:** 30 cycles  
**Measured:** 30 cycles ✓ (exact match)

**Array-b unchanged (M[12..18]):** confirmed — ADDV only writes to array-a addresses, reads array-b read-only. ✓

### 6.3 Breakdown of 30 ADDV Cycles (n = 7)

| Phase | Cycles | Cumulative |
|-------|--------|------------|
| Setup: 3×INC + 3×NOP | 6 | 6 |
| ADDV fetch into IF/ID | 1 | 7 |
| FSM LOAD_A/LOAD_B/STORE × 7 elements | 21 | 28 |
| Pipeline drain / stall-edge detection | 2 | **30** |

---

## 7. Conclusions

| Claim | Value | Verified |
|-------|-------|----------|
| Minimum cycle time | **2 ns** (IF or EX critical path) | Derived from component delays |
| Implemented clock period | **4 ns** (250 MHz, 2× margin) | Waveform / `#2` toggle |
| CPI (software loop, per slot) | **1.0** (no hardware stalls) | Demo sim: 30 inst / 30 cycles |
| Effective CPI (per useful instruction) | **≈ 1.64** (18 slots / 11 useful) | Benchmark.asm analysis |
| Instruction count (V1, software) | **18n + 7** | Loop body enumeration |
| Total cycles (V1, software) | **18n + 7 ≈ 18n** | CPI = 1 per slot |
| Total cycles (V2, ADDV) | **3n + 9 ≈ 3n** | ADDV sim: n=7 → 30 cycles |
| ADDV speedup over software | **≈ 6×** | 18n / 3n |
