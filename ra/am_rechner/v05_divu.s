; V05: divu(r1 = a, r2 = b > 0) -> r1 = a / b, r2 = a mod b (vorzeichenlos, 32 Schritte)
; @test r1=100, r2=7 => r1=14, r2=2
; @test r1=5, r2=9 => r1=0, r2=5
; @test r1=-1, r2=16 => r1=$0FFFFFFF, r2=15
; @test r1=42, r2=1 => r1=42, r2=0

divu:     add  r3 := r0,r0         ; Rest
          add  r4 := r0,r0         ; Quotient
          addi r5 := r0,#32
loop:     beq  r5,fertig
          lsl  r3 := r3            ; Rest nach links ...
          bge  r1,null             ; ... und oberstes Bit von a hinein
          ori  r3 := r3,#1
null:     lsl  r1 := r1
          lsl  r4 := r4
          cmpu r6 := r3,r2
          blt  r6,kleiner          ; Rest < b: Quotientenbit 0
          sub  r3 := r3,r2
          ori  r4 := r4,#1
kleiner:  addi r5 := r5,#-1
          bra  loop
fertig:   add  r1 := r4,r0
          add  r2 := r3,r0
          jmp  r31
