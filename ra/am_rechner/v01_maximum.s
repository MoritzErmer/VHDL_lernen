; V01: maximum(r1 = Adresse, r2 = Laenge > 0) -> r1 = groesstes Element (mit Vorzeichen)
.mem $100: 3, -7, 12, 5, 12, -1
; @test r1=$100, r2=6 => r1=12
; @test r1=$101, r2=1 => r1=-7
; @test r1=$100, r2=2 => r1=3

maximum:  ldd  r3 := (r1,0)        ; max = erstes Element
          addi r1 := r1,#1
          addi r2 := r2,#-1
loop:     beq  r2,fertig
          ldd  r4 := (r1,0)
          cmps r5 := r4,r3
          ble  r5,kleiner          ; nicht groesser
          add  r3 := r4,r0
kleiner:  addi r1 := r1,#1
          addi r2 := r2,#-1
          bra  loop
fertig:   add  r1 := r3,r0
          jmp  r31
