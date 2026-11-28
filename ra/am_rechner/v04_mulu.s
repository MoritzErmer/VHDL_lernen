; V04: mulu(r1, r2) -> r1 = r1 * r2 (untere 32 Bit), nur mit Schieben und Addieren
; @test r1=13, r2=11 => r1=143
; @test r1=0, r2=99 => r1=0
; @test r1=65535, r2=65537 => r1=-1
; @test r1=7, r2=1 => r1=7

mulu:     add  r3 := r0,r0         ; Produkt
loop:     beq  r2,fertig           ; keine Bits mehr im Multiplikator
          and0i r4 := r2,#1
          beq  r4,schieben
          add  r3 := r3,r1         ; Bit gesetzt: Multiplikand addieren
schieben: lsl  r1 := r1            ; Multiplikand mal 2
          lsr  r2 := r2            ; naechstes Bit
          bra  loop
fertig:   add  r1 := r3,r0
          jmp  r31
