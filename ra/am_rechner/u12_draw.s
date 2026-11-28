; U12: draw(r1 = board, r2 = Farbtabelle): 4 x 4 Spielfeld in den Bildspeicher ab $80000000
; ein Pixel = ein 32-Bit-Wort, Farbe = Farbtabelle[Exponent]
.mem $100: 0, 3, 2, 0,  4, 0, 0, 0,  4, 0, 0, 2,  1, 2, 0, 0
.mem $200: $FFCDC1B4, $FFEEE4DA, $FFEDE0C8, $FFF2B179, $FFF59563, $FFF67C5F
; @test r1=$100, r2=$200 => m[$80000000]=$FFCDC1B4, m[$80000001]=$FFF2B179, m[$80000004]=$FFF59563, m[$8000000C]=$FFEEE4DA, m[$8000000F]=$FFCDC1B4

draw:     addhi r5 := r0,#$8000    ; VRAM-Basisadresse $80000000
          addi r6 := r0,#16        ; 16 Felder
          add  r7 := r0,r0         ; Index
loop:     beq  r6,fertig
          ldr  r8 := (r1,r7)       ; Exponent des Steins
          ldr  r9 := (r2,r8)       ; Farbe aus der Tabelle
          str  (r5,r7) := r9       ; Pixel schreiben
          addi r7 := r7,#1
          addi r6 := r6,#-1
          bra  loop
fertig:   jmp  r31
