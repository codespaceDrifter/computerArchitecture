# SCU ISA — Binary Encoding & Control Truth Table

## Instruction Format (32 bits)

| Field | op | rd | rs | rt | unused/imm |
|---|---|---|---|---|---|
| Bits | 4 | 6 | 6 | 6 | 10 |
| Range | 31:28 | 27:22 | 21:16 | 15:10 | 9:0 |


---

## Binary Encoding Table

| Symbol | op | rd | rs | rt | bits[9:0] |
|---|---|---|---|---|---|
| NOP | 0000 | 000000 | 000000 | 000000 | 0000000000 |
| ADDV rd,rs,rt | 0001 | rd | rs | rt | 0000000000 |
| ST rt,rs | 0011 | 000000 | rs | rt | 0000000000 |
| ADD rd,rs,rt | 0100 | rd | rs | rt | 0000000000 |
| INC rd,rs,y | 0101 | rd | rs | y[15:10] | y[9:0] |
| NEG rd,rs | 0110 | rd | rs | 000000 | 0000000000 |
| SUB rd,rs,rt | 0111 | rd | rs | rt | 0000000000 |
| JM rs | 1000 | 000000 | rs | 000000 | 0000000000 |
| BRZ rs | 1001 | 000000 | rs | 000000 | 0000000000 |
| BRN rs | 1011 | 000000 | rs | 000000 | 0000000000 |
| LD rd,rs | 1110 | rd | rs | 000000 | 0000000000 |
| SVPC rd,y | 1111 | rd | y[21:16] | y[15:10] | y[9:0] |


---

## Control Truth Table

| Instruction | Opcode | ALUSrc1 | ALUSrc2 | ADD | NEG | SUB | Jump | BRZ | BRN | RegWrite | MemRead | MemWrite | MemtoReg | ImmSel |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| NOP | 0000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ADDV | 0001 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ST | 0011 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 |
| ADD | 0100 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 |
| INC | 0101 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 |
| NEG | 0110 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 |
| SUB | 0111 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 |
| JM | 1000 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| BRZ | 1001 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |
| BRN | 1011 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| LD | 1110 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 1 | 0 |
| SVPC | 1111 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1 |

---

## ALU Truth Table

| ADD | NEG | SUB | Output | Operation |
|---|---|---|---|---|
| 0 | 0 | 0 | A+B | add |
| 1 | 1 | 0 | −A | 2's complement |
| 1 | 0 | 1 | A-B | subtract |
| 0 | 1 | 0 | don't care | no operation |
| 1 | 1 | 1 | A | pass A |

