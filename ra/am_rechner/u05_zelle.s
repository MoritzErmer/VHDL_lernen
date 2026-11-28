; U05: zelle(r1 = Istfeld, r2 = Folgefeld, r3 = Index) - ein Schritt fuer eine Zelle
; Spielfeld 6 x 6 (SIZE = 6), ein Wort pro Zelle, Nachbarn bei -7 -6 -5 -1 +1 +5 +6 +7
; Gleiter: Zeile 1 Spalte 2, Zeile 2 Spalte 3, Zeile 3 Spalten 1-3
.mem $100: 0,0,0,0,0,0, 0,0,1,0,0,0, 0,0,0,1,0,0, 0,1,1,1,0,0, 0,0,0,0,0,0, 0,0,0,0,0,0
.mem $200: 9,9,9,9,9,9, 9,9,9,9,9,9, 9,9,9,9,9,9, 9,9,9,9,9,9, 9,9,9,9,9,9, 9,9,9,9,9,9
; @test r1=$100, r2=$200, r3=14 => m[$20E]=0
; @test r1=$100, r2=$200, r3=13 => m[$20D]=1
; @test r1=$100, r2=$200, r3=21 => m[$215]=1
; @test r1=$100, r2=$200, r3=8 => m[$208]=0
; @test r1=$100, r2=$200, r3=27 => m[$21B]=0
; @test r1=$100, r2=$200, r3=26 => m[$21A]=1

zelle:    add  r5 := r1,r3         ; Adresse der Zelle im Istfeld
          ldd  r6 := (r5,-7)       ; links oben
          ldd  r7 := (r5,-6)       ; oben
          add  r6 := r6,r7
          ldd  r7 := (r5,-5)       ; rechts oben
          add  r6 := r6,r7
          ldd  r7 := (r5,-1)       ; links
          add  r6 := r6,r7
          ldd  r7 := (r5,1)        ; rechts
          add  r6 := r6,r7
          ldd  r7 := (r5,5)        ; links unten
          add  r6 := r6,r7
          ldd  r7 := (r5,6)        ; unten
          add  r6 := r6,r7
          ldd  r7 := (r5,7)        ; rechts unten
          add  r6 := r6,r7
          add  r8 := r2,r3         ; Adresse der Zelle im Folgefeld
          cmpsi r9 := r6,#3
          beq  r9,lebt             ; genau 3 Nachbarn
          cmpsi r9 := r6,#2
          beq  r9,bleibt           ; genau 2 Nachbarn
          std  (r8,0) := r0        ; sonst tot
          jmp  r31
lebt:     addi r9 := r0,#1
          std  (r8,0) := r9
          jmp  r31
bleibt:   ldd  r9 := (r5,0)
          std  (r8,0) := r9
          jmp  r31
