; U03: streq(r1 = Adresse s0, r2 = Adresse s1) -> r1 = 1 bei Gleichheit, sonst 0
; Strings: ein Zeichen pro Wort (ASCII-Code), Ende = 0
.mem $100: 65, 66, 67, 0          ; "ABC"
.mem $110: 65, 66, 67, 0          ; "ABC"
.mem $120: 65, 66, 68, 0          ; "ABD"
.mem $130: 65, 66, 0              ; "AB"
; @test r1=$100, r2=$110 => r1=1
; @test r1=$100, r2=$120 => r1=0
; @test r1=$100, r2=$130 => r1=0
; @test r1=$130, r2=$100 => r1=0

streq:    ldd  r3 := (r1,0)        ; Zeichen aus s0
          ldd  r4 := (r2,0)        ; Zeichen aus s1
          sub  r5 := r3,r4
          bne  r5,ungleich         ; verschieden -> false
          beq  r3,gleich           ; beide 0 -> Ende erreicht, true
          addi r1 := r1,#1
          addi r2 := r2,#1
          bra  streq
ungleich: add  r1 := r0,r0
          jmp  r31
gleich:   addi r1 := r0,#1
          jmp  r31
