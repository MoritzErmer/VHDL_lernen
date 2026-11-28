; V06: popcount(r1) -> r1 = Anzahl gesetzter Bits, r2 = Paritaet (1 bei ungerader Anzahl)
; @test r1=0 => r1=0, r2=0
; @test r1=$F0 => r1=4, r2=0
; @test r1=-1 => r1=32, r2=0
; @test r1=$80000001 => r1=2, r2=0
; @test r1=7 => r1=3, r2=1

popcount: add  r3 := r0,r0
loop:     beq  r1,fertig           ; keine Einsen mehr: fertig (spart Durchlaeufe)
          and0i r4 := r1,#1
          add  r3 := r3,r4
          lsr  r1 := r1            ; logisch: von links kommt 0
          bra  loop
fertig:   add  r1 := r3,r0
          and0i r2 := r3,#1
          jmp  r31
