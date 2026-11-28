; V09: fib(r1 = n) -> r1 = Fibonacci-Zahl, rekursiv mit Stapel (r30)
.reg r30 = $1000
; @test r1=0 => r1=0, r30=$1000
; @test r1=1 => r1=1
; @test r1=2 => r1=1
; @test r1=10 => r1=55, r30=$1000
; @test r1=15 => r1=610

fib:      addi r2 := r1,#-2
          bge  r2,rekursion        ; n >= 2
          jmp  r31                 ; fib(0) = 0, fib(1) = 1: r1 ist schon richtig
rekursion: addi r30 := r30,#-3
          std  (r30,0) := r31
          std  (r30,1) := r10
          std  (r30,2) := r11
          add  r10 := r1,r0        ; n merken
          addi r1 := r10,#-1
          bsr  fib                 ; fib(n - 1)
          add  r11 := r1,r0
          addi r1 := r10,#-2
          bsr  fib                 ; fib(n - 2)
          add  r1 := r1,r11
          ldd  r31 := (r30,0)
          ldd  r10 := (r30,1)
          ldd  r11 := (r30,2)
          addi r30 := r30,#3
          jmp  r31
