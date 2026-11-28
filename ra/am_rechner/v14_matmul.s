; V14: matmul(r1 = A, r2 = B, r3 = C): C = A * B fuer 3 x 3-Matrizen (zeilenweise, ein Wort pro Element)
; nutzt mulu als Unterprogramm, Zaehler und Zeiger in callee-save Registern
.reg r30 = $1000
.mem $100: 1, 2, 3,  4, 5, 6,  7, 8, 9
.mem $110: 9, 8, 7,  6, 5, 4,  3, 2, 1
; @test r1=$100, r2=$110, r3=$120 => m[$120]=30, m[$121]=24, m[$122]=18, m[$123]=84, m[$124]=69, m[$125]=54, m[$126]=138, m[$127]=114, m[$128]=90, r30=$1000

matmul:   addi r30 := r30,#-9
          std  (r30,0) := r31
          std  (r30,1) := r10
          std  (r30,2) := r11
          std  (r30,3) := r12
          std  (r30,4) := r13
          std  (r30,5) := r14
          std  (r30,6) := r15
          std  (r30,7) := r16
          std  (r30,8) := r17
          add  r10 := r1,r0        ; Zeilenanfang in A
          add  r11 := r2,r0        ; B
          add  r12 := r3,r0        ; naechstes Element von C
          addi r13 := r0,#3        ; Zeilen
zeile:    beq  r13,fertig
          addi r14 := r0,#0        ; Spalte j
spalte:   cmpsi r4 := r14,#3
          bge  r4,zeile_ende
          add  r15 := r0,r0        ; Summe
          addi r16 := r0,#0        ; k
skalar:   cmpsi r4 := r16,#3
          bge  r4,skalar_ende
          ldr  r1 := (r10,r16)     ; A[i][k]
          add  r17 := r16,r16
          add  r17 := r17,r16      ; 3 * k
          add  r17 := r17,r14      ; 3 * k + j
          ldr  r2 := (r11,r17)     ; B[k][j]
          bsr  mulu
          add  r15 := r15,r1
          addi r16 := r16,#1
          bra  skalar
skalar_ende: std (r12,0) := r15    ; C[i][j]
          addi r12 := r12,#1
          addi r14 := r14,#1
          bra  spalte
zeile_ende: addi r10 := r10,#3     ; naechste Zeile von A
          addi r13 := r13,#-1
          bra  zeile
fertig:   ldd  r31 := (r30,0)
          ldd  r10 := (r30,1)
          ldd  r11 := (r30,2)
          ldd  r12 := (r30,3)
          ldd  r13 := (r30,4)
          ldd  r14 := (r30,5)
          ldd  r15 := (r30,6)
          ldd  r16 := (r30,7)
          ldd  r17 := (r30,8)
          addi r30 := r30,#9
          jmp  r31

mulu:     add  r3 := r0,r0
m_loop:   beq  r2,m_fertig
          and0i r4 := r2,#1
          beq  r4,m_schieben
          add  r3 := r3,r1
m_schieben: lsl r1 := r1
          lsr  r2 := r2
          bra  m_loop
m_fertig: add  r1 := r3,r0
          jmp  r31
