; U15: zug_oben(r1 = board): fuer jede Spalte compact, merge, compact
.reg r30 = $1000
.mem $100: 0, 3, 2, 0,  4, 0, 0, 0,  4, 0, 0, 2,  1, 2, 0, 0
; Ergebnis wie im Beispiel: oben 32 8 4 4, darunter 2 4
; @test r1=$100 => m[$100]=5, m[$101]=3, m[$102]=2, m[$103]=2, m[$104]=1, m[$105]=2, m[$106]=0, m[$107]=0, m[$108]=0, m[$10B]=0, m[$10C]=0, r1=1, r30=$1000

zug_oben: addi r30 := r30,#-4
          std  (r30,0) := r31
          std  (r30,1) := r10
          std  (r30,2) := r11
          std  (r30,3) := r12
          add  r10 := r1,r0        ; Adresse der aktuellen Spalte (oben)
          addi r11 := r0,#4        ; 4 Spalten
          add  r12 := r0,r0        ; hat sich irgendetwas veraendert?
spalte:   beq  r11,zug_ende
          add  r1 := r10,r0
          addi r2 := r0,#4
          bsr  compact
          or   r12 := r12,r1
          add  r1 := r10,r0
          addi r2 := r0,#4
          bsr  merge
          or   r12 := r12,r1
          add  r1 := r10,r0
          addi r2 := r0,#4
          bsr  compact             ; durch merge entstandene Luecken schliessen
          addi r10 := r10,#1
          addi r11 := r11,#-1
          bra  spalte
zug_ende: add  r1 := r12,r0
          ldd  r31 := (r30,0)
          ldd  r10 := (r30,1)
          ldd  r11 := (r30,2)
          ldd  r12 := (r30,3)
          addi r30 := r30,#4
          jmp  r31

; merge(r1 = Startadresse, r2 = Schrittweite) -> r1 = 1, wenn vereinigt wurde
merge:    add  r3 := r1,r0         ; aktuelles Feld
          addi r5 := r0,#3         ; noch zu pruefende Paare
          add  r9 := r0,r0
m_loop:   ble  r5,m_fertig
          ldd  r6 := (r3,0)
          add  r4 := r3,r2         ; Nachbar entgegen der Zugrichtung
          ldd  r7 := (r4,0)
          beq  r6,m_weiter         ; leeres Feld
          sub  r8 := r6,r7
          bne  r8,m_weiter         ; verschiedene Steine
          addi r6 := r6,#1         ; doppelter Wert = Exponent + 1
          std  (r3,0) := r6
          std  (r4,0) := r0
          addi r9 := r0,#1
          add  r3 := r4,r2         ; neuer Stein darf nicht nochmal vereinigt werden
          addi r5 := r5,#-2
          bra  m_loop
m_weiter: add  r3 := r4,r0
          addi r5 := r5,#-1
          bra  m_loop
m_fertig: add  r1 := r9,r0
          jmp  r31

compact:  add  r3 := r1,r0
          add  r4 := r1,r0
          addi r5 := r0,#4
          add  r9 := r0,r0
c_loop:   beq  r5,c_fertig
          ldd  r6 := (r4,0)
          beq  r6,c_weiter
          sub  r7 := r4,r3
          beq  r7,c_passt
          std  (r3,0) := r6
          std  (r4,0) := r0
          addi r9 := r0,#1
c_passt:  add  r3 := r3,r2
c_weiter: add  r4 := r4,r2
          addi r5 := r5,#-1
          bra  c_loop
c_fertig: add  r1 := r9,r0
          jmp  r31
