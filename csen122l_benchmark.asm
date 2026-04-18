; CSEN 122L Week 3 — vector add a[i] = a[i] + b[i]
; Assumes: r1 = n, r2 = &a[0], r3 = &b[0]


; ===== Version 1: no ADDV =====
; r1 = counter, r2/r3 = pa/pb, r10 = loop top, r11 = exit
; r20/r21 = loaded a,b, r22 = sum

V1_START:
    SVPC r10, LOOP_TOP      ; grab loop addr (no branch-to-imm in ISA)
    SVPC r11, DONE

LOOP_TOP:
    INC  r1, r1, 0          ; set Z flag on counter
    BRZ  r11                ; done if counter == 0

    LD   r20, r2            ; a[i]
    LD   r21, r3            ; b[i]
    ADD  r22, r20, r21
    ST   r22, r2            ; a[i] = sum

    INC  r2,  r2,  1        ; pa++
    INC  r3,  r3,  1        ; pb++
    INC  r1,  r1,  -1       ; counter--

    SUB  r23, r23, r23      ; force Z=1 for uncond branch
    BRZ  r10                ; jump to LOOP_TOP

DONE:
    NOP


; ===== Version 2: with ADDV =====
; ADDV needs xrd = n-1

V2_START:
    INC  r4, r1, -1         ; r4 = n-1
    ADDV r4, r2, r3
    NOP


; perf notes:
; V1: ~10 instr per iter + 2 setup  -> ~10n + 4 dynamic
; V2: 2 instr total, ADDV does n loads/adds/stores internally
