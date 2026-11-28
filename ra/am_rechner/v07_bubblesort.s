; V07: bubblesort(r1 = Adresse, r2 = Laenge): aufsteigend sortieren (mit Vorzeichen)
.mem $100: 5, -3, 9, 0, 9, 2, -8
; @test r1=$100, r2=7 => m[$100]=-8, m[$101]=-3, m[$102]=0, m[$103]=2, m[$104]=5, m[$105]=9, m[$106]=9
; @test r1=$100, r2=1 => m[$100]=5

bubblesort: addi r3 := r2,#-1      ; Anzahl Vergleiche im aktuellen Durchlauf
aussen:   ble  r3,fertig
          add  r4 := r1,r0         ; Zeiger
          add  r5 := r3,r0         ; Zaehler innen
          add  r9 := r0,r0         ; getauscht?
innen:    beq  r5,innen_ende
          ldd  r6 := (r4,0)
          ldd  r7 := (r4,1)
          cmps r8 := r6,r7
          ble  r8,kein_tausch
          std  (r4,0) := r7
          std  (r4,1) := r6
          addi r9 := r0,#1
kein_tausch: addi r4 := r4,#1
          addi r5 := r5,#-1
          bra  innen
innen_ende: beq r9,fertig          ; nichts getauscht: schon sortiert
          addi r3 := r3,#-1        ; das Groesste steht jetzt hinten
          bra  aussen
fertig:   jmp  r31
