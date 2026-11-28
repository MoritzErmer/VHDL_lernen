; U14: compact(r1 = Startadresse, r2 = Schrittweite) -> r1 = 1, wenn sich etwas bewegt hat
; linke Spalte des Beispiels, Zug nach oben: Start = board, Schrittweite = 4
.mem $100: 0, 3, 2, 0,  4, 0, 0, 0,  4, 0, 0, 2,  1, 2, 0, 0
; @test r1=$100, r2=4 => r1=1, m[$100]=4, m[$104]=4, m[$108]=1, m[$10C]=0
; @test r1=$102, r2=4 => r1=0, m[$102]=2, m[$106]=0
; @test r1=$10F, r2=-1 => r1=1, m[$10F]=2, m[$10E]=1, m[$10D]=0, m[$10C]=0

compact:  add  r3 := r1,r0         ; Ziel: naechste freie Stelle
          add  r4 := r1,r0         ; Quelle
          addi r5 := r0,#4         ; 4 Felder
          add  r9 := r0,r0         ; bewegt = false
loop:     beq  r5,fertig
          ldd  r6 := (r4,0)
          beq  r6,weiter           ; leeres Feld: nur Quelle weiter
          sub  r7 := r4,r3
          beq  r7,passt            ; Stein steht schon richtig
          std  (r3,0) := r6        ; aufruecken
          std  (r4,0) := r0
          addi r9 := r0,#1
passt:    add  r3 := r3,r2         ; naechste freie Stelle
weiter:   add  r4 := r4,r2
          addi r5 := r5,#-1
          bra  loop
fertig:   add  r1 := r9,r0
          jmp  r31
