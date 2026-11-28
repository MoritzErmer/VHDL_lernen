; V02 b: zaehle(r1 = Adresse, r2 = Zeichen) -> r1 = wie oft das Zeichen im String vorkommt
.mem $100: 98, 97, 110, 97, 110, 97, 0   ; "banana"
; @test r1=$100, r2=97 => r1=3
; @test r1=$100, r2=120 => r1=0

zaehle:   add  r4 := r0,r0
loop:     ldd  r3 := (r1,0)
          beq  r3,fertig
          sub  r5 := r3,r2
          bne  r5,weiter
          addi r4 := r4,#1
weiter:   addi r1 := r1,#1
          bra  loop
fertig:   add  r1 := r4,r0
          jmp  r31
