; V08: binsuche(r1 = Adresse, r2 = Laenge, r3 = Wert) -> r1 = Index oder -1
; das Array ist aufsteigend sortiert
.mem $100: -5, 1, 4, 8, 13, 21, 34, 55
; @test r1=$100, r2=8, r3=13 => r1=4
; @test r1=$100, r2=8, r3=-5 => r1=0
; @test r1=$100, r2=8, r3=55 => r1=7
; @test r1=$100, r2=8, r3=9 => r1=-1
; @test r1=$100, r2=0, r3=1 => r1=-1

binsuche: add  r4 := r0,r0         ; links
          addi r5 := r2,#-1        ; rechts
loop:     cmps r6 := r4,r5
          bgt  r6,nicht            ; links > rechts: leer
          add  r7 := r4,r5
          asr  r7 := r7            ; Mitte = (links + rechts) / 2
          ldr  r8 := (r1,r7)
          cmps r9 := r8,r3
          beq  r9,gefunden
          blt  r9,rechts_weiter
          addi r5 := r7,#-1        ; Wert liegt links
          bra  loop
rechts_weiter: addi r4 := r7,#1    ; Wert liegt rechts
          bra  loop
gefunden: add  r1 := r7,r0
          jmp  r31
nicht:    addi r1 := r0,#-1
          jmp  r31
