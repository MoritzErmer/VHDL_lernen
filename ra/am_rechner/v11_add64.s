; V11: add64: (r1:r2) + (r3:r4) -> (r1:r2), r1/r3 = obere 32 Bit, r2/r4 = untere 32 Bit
; @test r1=0, r2=-1, r3=0, r4=1 => r1=1, r2=0
; @test r1=5, r2=10, r3=7, r4=20 => r1=12, r2=30
; @test r1=0, r2=$80000000, r3=0, r4=$80000000 => r1=1, r2=0
; @test r1=-1, r2=-1, r3=0, r4=1 => r1=0, r2=0

add64:    addx r5 := r2,r4         ; Uebertrag der unteren Haelfte (0 oder 1)
          add  r2 := r2,r4         ; untere Haelfte
          add  r1 := r1,r3         ; obere Haelfte
          add  r1 := r1,r5         ; plus Uebertrag
          jmp  r31
