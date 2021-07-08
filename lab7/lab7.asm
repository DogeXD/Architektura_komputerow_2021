.data #strings 
#operations
chooseOpText: .asciiz "\nwybierz dzialanie:\n"
addText: .asciiz "1: Dodawanie\n"
subText:.asciiz "2: Odejmowanie\n"
divText:.asciiz "3: Dzielenie\n"
mulText: .asciiz "4: Mnozenie\n"
invText: .asciiz "5: Odwrotnosc\n"
absText: .asciiz "6: Wartosc bezwzgledna\n"
pwrText: .asciiz "7: a^b\n"
facText: .asciiz "8: n!\n"

floatconst:.float 1.0
floatZero: .float 0.0

#buffer
chooseBufOpText: .asciiz "\nwybierz dzialanie na buforze\n"
addToBufText: .asciiz "1: M+\n"
subFromBufText: .asciiz"2: M-\n"
clearBufText: .asciiz "3: MC\n"
writeBufText: .asciiz "4: MR\n"
nothingBufText: .asciiz "5: nic\n"

getNumberText: .asciiz "podaj liczbe: "
resText: .asciiz "wynik wynosi: "
next: .asciiz "\n0- wykonaj od nowa; 1- wykonaj uzyj wyniku jako liczby 1; (-1)-zakoncz i wyjdz\n"
divBy0: .asciiz "nie dziel przez 0\n"
bufText:  .asciiz"bufor ma wartosc: "
	.text


# t0 - op t1- z poprzedniego t2-int1 t3-wyn t4 op buf 
#f1 float1 f2 float 2 f3 wyn f4 buf 
li	$t1,0	#t1 uzyj wyniku-1; wczytaj liczbe-0 ; zakoncz- -1


getOperation: 
	li $v0 , 4 	#pokazanie mozliwych operacji
	la $a0, chooseOpText 
	syscall 
	la $a0, addText 
	syscall 
	la $a0, subText 
	syscall 
	la $a0, divText 
	syscall 
	la $a0, mulText 
	syscall 
	la $a0, invText 
	syscall 
	la $a0, absText 
	syscall 
	la $a0, pwrText 
	syscall 
	la $a0, facText 
	syscall 
	
		#pobranie od uzytkownika 
	li $v0,5
	syscall
	move $t0,$v0
	
	beq	$t1,1,setFirstFloat	#sprawdzenie czy jako 1 liczba ma byc wynik
	beq $t0,8,getInt
	
	
	
	
getFirstFloa:	#pobieranie 1 liczby
	#wyswietlenie prosby o podanie liczby
	li $v0,4
	la $a0,getNumberText
	syscall
	
	#pobranie floata
	li $v0,6
	syscall
	mov.s   $f1,$f0
	
	beq $t0,5,performOperation #1/x
	beq $t0,6,performOperation #abs(x)
	beq $t0,7,getInt #pwr
	
	j getSecondFloat

setFirstFloat:	#ustawienie 1 liczby jako wynik
	mov.s  $f1,$f3
	beq $t0,5,performOperation #1/x
	beq $t0,6,performOperation #abs(x)
	beq $t0,7,getInt
	
	
getSecondFloat:	#pobieranie 2 liczby
	#wyswietlenie prosby o podanie liczby
	li $v0,4
	la $a0,getNumberText
	syscall
	
	li $v0,6
	syscall
	mov.s  $f2,$f0
	j performOperation
	
getInt:
	li  $v0,4
	la $a0,getNumberText
	syscall
	
	li $v0,5
	syscall
	move  $t2,$v0

	
performOperation: 	#wykonanie wybranego dzialania
	beq $t0,1,add
	beq $t0,2,sub
	beq $t0,3,div
	beq $t0,4,mul
	beq $t0,5,inv
	beq $t0,6,abs
	beq $t0,7,pwr
	beq $t0,8,fac

add:	#dodawanie
	add.s 	$f3,$f1,$f2
	j printRes
	
sub:	# odejmowanie
	sub.s	 $f3,$f1,$f2
	j printRes
	
mul:	#mnozenie
	mul.s	 $f3,$f1,$f2
	j printRes
	
div:	#dzielenie
	l.s     $f5, floatZero
	c.eq.s    $f5, $f2
	bc1t 	divByZero 
	
	div.s	 $f3,$f1,$f2
	j printRes
inv:
	l.s     $f5, floatZero
	c.eq.s   $f5, $f1
	bc1t 	divByZero 
	
	l.s     $f2, floatconst	
	div.s $f3,$f2,$f1
	j printRes
abs:
	abs.s $f3,$f1
	j printRes
	



pwr:	#potegowanie 

	li $t3 1 

	mtc1 $t3, $f3
 	cvt.s.w $f3, $f3
	
	
	LOOP2:
		 mul.s $f3, $f3 ,$f1
 		addi $t2 ,$t2, -1 
 		bne  $t2,0, LOOP2 
 		
	j printRes
	
fac:
	li $t3 1 
 	LOOP: mul $t3, $t3 ,$t2 
 		addi $t2 ,$t2, -1 
 		bne  $t2,0, LOOP 
 	mtc1 $t3, $f3
 	cvt.s.w $f3, $f3
 	j printRes
 	
 	
divByZero:
	li $v0,4
	la $a0,divBy0
	syscall
	j getOperation
	
printRes:
	li $v0,4
	la $a0,resText
	syscall

	
	li,$v0,2
	mov.s   $f12,$f3	#wypisanie wyniku
	syscall

	
	
getBufOperation:
li $v0 , 4 	#pokazanie mozliwych operacji
	la $a0, chooseBufOpText 
	syscall 
	la $a0, addToBufText 
	syscall 
	la $a0, subFromBufText 
	syscall 
	la $a0, clearBufText 
	syscall 
	la $a0, writeBufText 
	syscall
	la $a0, nothingBufText
	syscall
	#pobranie wyboru
	li $v0,5
	syscall
	move $t4,$v0
	
performBufOperation: 	#wykonanie wybranego dzialania
	beq $t4,1,addToBuf
	beq $t4,2,subFromBuf
	beq $t4,3,clearBuf
	beq $t4,4,loadBuf
	beq $t4,5,useRes

addToBuf:
	add.s $f4,$f3,$f4
	j printBuf
subFromBuf:
	sub.s $f4,$f4,$f3
	j printBuf
clearBuf:
	mov.s	$f4,$f6  #W F6 jest 0 
	j printBuf
loadBuf:
	mov.s	$f4,$f3


printBuf:
	li $v0,4
	la $a0,bufText
	syscall

	
	li,$v0,2
	mov.s   $f12,$f4	#wypisanie wyniku
	syscall
	
useRes:
	li $v0,4
	la $a0,next
	syscall
	
	li $v0,5
	syscall
	move $t1,$v0
	bne $t1,-1,getOperation
	
