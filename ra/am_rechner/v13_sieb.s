; V13: sieb(r1 = Adresse, r2 = N): Sieb des Eratosthenes, danach Mem[Adresse + i] = 1 genau fuer Primzahlen i < N
; ohne Multiplikation: Vielfache durch fortgesetztes Addieren
; @test r1=$100, r2=20 => m[$100]=0, m[$101]=0, m[$102]=1, m[$103]=1, m[$104]=0, m[$105]=1, m[$109]=0, m[$10B]=1, m[$10F]=0, m[$111]=1, m[$113]=1

sieb:     addi r3 := r0,#2         ; zuerst alle ab 2 als "prim" markieren
          std  (r1,0) := r0
          std  (r1,1) := r0
          addi r9 := r0,#1
init:     sub  r4 := r3,r2
          bge  r4,init_ende
          str  (r1,r3) := r9
          addi r3 := r3,#1
          bra  init
init_ende: addi r3 := r0,#2        ; p = 2
aussen:   sub  r4 := r3,r2
          bge  r4,fertig
          ldr  r5 := (r1,r3)
          beq  r5,naechstes        ; schon gestrichen: keine Primzahl
          add  r6 := r3,r3         ; erstes Vielfaches 2p
streichen: sub r4 := r6,r2
          bge  r4,naechstes
          str  (r1,r6) := r0
          add  r6 := r6,r3         ; naechstes Vielfaches
          bra  streichen
naechstes: addi r3 := r3,#1
          bra  aussen
fertig:   jmp  r31
