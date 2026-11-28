; U16: spawn(r1 = board): neuen Stein (Exponent 1 in 3/4 der Faelle, sonst 2) auf ein freies Feld
; 6 Zufallsbits aus lfsr: die unteren 2 bestimmen den Wert, die oberen 4 die Position
.reg r30 = $1000
.mem $100: 0, 3, 2, 0,  4, 0, 0, 0,  4, 0, 0, 2,  1, 2, 0, 0
.mem $300: 1
; @test r1=$100 => m[$109]=1, m[$108]=4, r1=9, m[$300]=$A4B14648, r30=$1000
; @test r1=$100, m[$300]=$12345679 => m[$109]=2, r1=9, m[$300]=$369D75A3

spawn:    addi r30 := r30,#-4
          std  (r30,0) := r31
          std  (r30,1) := r10
          std  (r30,2) := r11
          std  (r30,3) := r12
          add  r10 := r1,r0        ; board (ueberlebt die lfsr-Aufrufe)
          add  r12 := r0,r0        ; Zufallszahl
          addi r11 := r0,#6        ; 6 Bits holen
bits:     beq  r11,auswerten
          bsr  lfsr
          lsl  r12 := r12
          or   r12 := r12,r1
          addi r11 := r11,#-1
          bra  bits
auswerten: and0i r3 := r12,#3      ; Wert-Bits
          addi r4 := r0,#1         ; Exponent 1 (Stein 2)
          bne  r3,pos
          addi r4 := r0,#2         ; nur bei 00: Exponent 2 (Stein 4)
pos:      lsr  r5 := r12
          lsr  r5 := r5
          and0i r5 := r5,#15       ; Positions-Index 0..15
frei:     ldr  r6 := (r10,r5)
          beq  r6,setzen           ; Feld frei
          addi r5 := r5,#1         ; sonst naechstes Feld
          and0i r5 := r5,#15
          bra  frei
setzen:   str  (r10,r5) := r4
          add  r1 := r5,r0         ; Rueckgabe: Index
          ldd  r31 := (r30,0)
          ldd  r10 := (r30,1)
          ldd  r11 := (r30,2)
          ldd  r12 := (r30,3)
          addi r30 := r30,#4
          jmp  r31

lfsr:     addi r2 := r0,#$300
          ldd  r3 := (r2,0)
          and0i r1 := r3,#1
          lsr  r3 := r3
          sub  r4 := r0,r1
          addhi r5 := r0,#$C330
          addli r5 := r5,#$8398
          and  r4 := r4,r5
          xor  r3 := r3,r4
          std  (r2,0) := r3
          jmp  r31
