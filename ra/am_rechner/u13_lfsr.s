; U13: lfsr() -> r1 = herausgeschobenes Bit; Zustand r steht fest im Speicher bei $300
; r = (r >> 1) xor (-b and $C3308398), ohne bedingten Sprung
.mem $300: 1
; @test  => r1=1, m[$300]=$C3308398
; @test m[$300]=$C3308398 => r1=0, m[$300]=$619841CC
; @test m[$300]=$619841CC => r1=0, m[$300]=$30CC20E6
; @test m[$300]=$30CC20E6 => r1=0, m[$300]=$18661073

lfsr:     addi r2 := r0,#$300      ; Adresse von r (statisch, nicht auf dem Stapel)
          ldd  r3 := (r2,0)        ; r
          and0i r1 := r3,#1        ; b = r and 1
          lsr  r3 := r3            ; r >> 1
          sub  r4 := r0,r1         ; -b: alle Bits 1, wenn b = 1
          addhi r5 := r0,#$C330
          addli r5 := r5,#$8398    ; Generatorpolynom $C3308398
          and  r4 := r4,r5
          xor  r3 := r3,r4
          std  (r2,0) := r3
          jmp  r31
