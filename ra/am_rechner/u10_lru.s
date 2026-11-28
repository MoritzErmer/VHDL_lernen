; U10: lru(r1 = LIST, r2 = N, r3 = element) -> r1 = am laengsten nicht benutztes Element
.mem $100: 0, 1, 2, 3, 4, 5, 6, 7
; @test r1=$100, r2=8, r3=5 => r1=7, m[$100]=5, m[$101]=0, m[$105]=4, m[$106]=6, m[$107]=7
; @test r1=$100, r2=8, r3=7 => r1=6, m[$100]=7, m[$101]=0, m[$107]=6
; @test r1=$100, r2=8, r3=0 => r1=7, m[$100]=0, m[$101]=1

lru:      add  r4 := r0,r0         ; ret_val = 0
          addi r5 := r2,#-1        ; i = N - 1
suche:    blt  r5,ende             ; i < 0: nicht gefunden
          ldr  r6 := (r1,r5)       ; LIST[i]
          sub  r7 := r6,r3
          beq  r7,gefunden
          addi r5 := r5,#-1
          bra  suche
gefunden: addi r8 := r5,#-1        ; j = i - 1
schieben: blt  r8,vorne
          ldr  r6 := (r1,r8)       ; tmp = LIST[j]
          add  r9 := r1,r8
          std  (r9,1) := r6        ; LIST[j + 1] = tmp
          addi r8 := r8,#-1
          bra  schieben
vorne:    std  (r1,0) := r3        ; LIST[0] = element
          add  r9 := r1,r2
          ldd  r4 := (r9,-1)       ; ret_val = LIST[N - 1]
ende:     add  r1 := r4,r0
          jmp  r31
