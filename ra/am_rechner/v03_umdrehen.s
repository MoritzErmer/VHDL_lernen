; V03: umdrehen(r1 = Adresse, r2 = Laenge): Array an Ort und Stelle umkehren
.mem $100: 1, 2, 3, 4, 5
.mem $110: 10, 20, 30, 40
; @test r1=$100, r2=5 => m[$100]=5, m[$101]=4, m[$102]=3, m[$103]=2, m[$104]=1
; @test r1=$110, r2=4 => m[$110]=40, m[$111]=30, m[$112]=20, m[$113]=10
; @test r1=$100, r2=0 => m[$100]=1

umdrehen: add  r3 := r1,r2
          addi r3 := r3,#-1        ; Zeiger auf das letzte Element
loop:     cmpu r4 := r1,r3
          bge  r4,fertig           ; Zeiger haben sich getroffen
          ldd  r5 := (r1,0)
          ldd  r6 := (r3,0)
          std  (r1,0) := r6
          std  (r3,0) := r5
          addi r1 := r1,#1
          addi r3 := r3,#-1
          bra  loop
fertig:   jmp  r31
