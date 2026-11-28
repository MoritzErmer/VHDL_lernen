; U04: absum(r1 = Adresse, r2 = Laenge) -> r1 = Summe der Betraege
; ruft fuer jedes Element das Unterprogramm abs auf (verschachtelter Aufruf)
.reg r30 = $1000
.mem $100: 3, -4, 5, -6
; @test r1=$100, r2=4, r10=77, r11=88, r12=99 => r1=18, r10=77, r11=88, r12=99, r30=$1000
; @test r1=$100, r2=0 => r1=0, r30=$1000

absum:    addi r30 := r30,#-4      ; Platz fuer 4 Woerter auf dem Stapel
          std  (r30,0) := r31      ; Ruecksprungadresse sichern
          std  (r30,1) := r10      ; callee-save Register sichern, die wir benutzen
          std  (r30,2) := r11
          std  (r30,3) := r12
          add  r10 := r1,r0        ; Zeiger    (ueberlebt den Aufruf von abs)
          add  r11 := r2,r0        ; Zaehler
          add  r12 := r0,r0        ; Summe
loop:     beq  r11,fertig
          ldd  r1 := (r10,0)       ; Parameter fuer abs
          bsr  abs
          add  r12 := r12,r1
          addi r10 := r10,#1
          addi r11 := r11,#-1
          bra  loop
fertig:   add  r1 := r12,r0
          ldd  r31 := (r30,0)
          ldd  r10 := (r30,1)
          ldd  r11 := (r30,2)
          ldd  r12 := (r30,3)
          addi r30 := r30,#4
          jmp  r31

abs:      bge  r1,abs_ende         ; Blatt-Unterprogramm: braucht nichts zu sichern
          sub  r1 := r0,r1
abs_ende: jmp  r31
