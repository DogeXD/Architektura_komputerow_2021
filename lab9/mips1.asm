.data #strings 
#operations
chooseOpText: .asciiz "\nwybierz dzialanie:\n"
addText: .asciiz "1: Dodawanie\n"
subText:.asciiz "2: Odejmowanie\n"
divText:.asciiz "3: Dzielenie\n"
mulText: .asciiz "4: Mnozenie\n"
invText: .asciiz "5: Odwrotnosc\n"
pwrText: .asciiz "6: a^b\n"
facText: .asciiz "7: n!\n"
loadAdressText: .asciiz "8: load Adress Exception\n"
storeAdressText: .asciiz "9: store Adress Exception\n"
trapExText: .asciiz "10: 4th trap\n"

floatconst:.float 1.0
floatZero: .float 0.0

#buffer

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
	la $a0, pwrText 
	syscall 
	la $a0, facText 
	syscall 
	la $a0, loadAdressText 
	syscall 
	la $a0, storeAdressText 
	syscall 
	la $a0 trapExText 
	syscall 
		#pobranie od uzytkownika 
	li $v0,5
	syscall
	move $t0,$v0
	
	
		#na calkowitych 
	beq $t0,1,getFirstInt
	beq $t0,3,getFirstInt
	beq $t0,6,getFirstInt
	beq $t0,7,getInt
	beq $t0,8,loadAdress
	beq $t0,9,storeAdress
	beq $t0,10,trap





	
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
	beq $t0,6,getInt #pwr
	
	j getSecondFloat
storeAdress:
	sw $t0,($zero)
loadAdress:
	lw $t0,($zero)
trap:
	li $t7,7
	teq $zero,$zero

	
	
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
	j performOperation


getFirstInt: 
	li  $v0,4
	la $a0,getNumberText
	syscall
	
	li $v0,5
	syscall
	move  $t2,$v0
getSecondInt: 
	li  $v0,4
	la $a0,getNumberText
	syscall
	
	li $v0,5
	syscall
	move  $t3,$v0


	
performOperation: 	#wykonanie wybranego dzialania
	beq $t0,1,add
	beq $t0,2,sub
	beq $t0,3,div
	beq $t0,4,mul
	beq $t0,5,inv
	beq $t0,6,pwr
	beq $t0,7,fac

add:	#dodawanie
	add 	$t4,$t2,$t3
	j printResInt
	
sub:	# odejmowanie
	sub.s	 $f3,$f1,$f2
	j printRes
	
mul:	#mnozenie
	mul.s	 $f3,$f1,$f2
	j printRes
	
div:	#dzielenie
	div  $t4,$t2,$t3
	j printResInt
inv:
	l.s     $f5, floatZero
	c.eq.s   $f5, $f1
	l.s     $f2, floatconst	
	div.s $f3,$f2,$f1
	j printRes

	



pwr:	#potegowanie 


	li $t4 1 
	
	beq $t2,0,possibleException
	possibleException:
		li $t8,8
		teq $t3,$zero
		
		
		
	LOOP2:
		addi $t3 ,$t3, -1 
		mul $t4, $t4 ,$t2
 		bnez $t3,LOOP2
	j printResInt

	
	
	
	
fac:
	li $t3 1 
	li $t4,14
	tge $t2,$t4
	tlti $t2,0
 	LOOP: mul $t3, $t3 ,$t2 
 		addi $t2 ,$t2, -1 
 		bne  $t2,0, LOOP 
 	mtc1 $t3, $f3
 	cvt.s.w $f3, $f3
 	j printRes
 	
 	
	
printRes:
	li $v0,4
	la $a0,resText
	syscall

	
	li,$v0,2
	mov.s   $f12,$f3	#wypisanie wyniku
	syscall
	li $v0, 10
 	syscall
printResInt:
	li $v0,4
	la $a0,resText
	syscall

	
	li,$v0,1
	move   $a0,$t4	#wypisanie wyniku
	syscall

.kdata
		
overflow: .asciiz "Overflow (arithmetic)\n\n" 
undefined_exception: .asciiz "Undefined Exception\n\n"
toobig: .asciiz "(trap ex 1)\ninteger is greater than 13\n\n"
negativeFact: .asciiz "(trap ex2)\ninteger is negative\n\n"
divByZero: .asciiz "DIVIDE_BY_ZERO_EXCEPTION\n\n"
storeException: .asciiz "ADDRESS_EXCEPTION_STORE\n\n"
loadException: .asciiz "ADDRESS_EXCEPTION_LOAD\n\n"
zeroToZero: .asciiz"(trap ex3)\n0^0 is undefined\n\n"
fourthTrap: .asciiz "(trap ex4)\n4th trap\n\n"

.ktext 0x80000180  
   
__kernel_entry_point:

	mfc0 $k0, $13   
	andi $k1, $k0, 0x00007c  
	srl  $k1, $k1, 2

__exception:
 	beq $k1, 12, __overflow_exception
	beq $k1 ,13 , __trap_exception
	beq $k1, 9, __div_by_zero_exception
	beq $k1,4, __load_adress_exception
	beq $k1,5,__store_adress_exception
	
	
	
	la $a0,($k1)
	li $v0,1
	syscall
	
	
	li $v0, 4
	la $a0, undefined_exception
 	syscall
 	li $v0, 10
 	syscall
 

__div_by_zero_exception:
	li $v0, 4
	la $a0, divByZero
 	syscall
 	li $v0, 10
 	syscall
 
__load_adress_exception:
	li $v0, 4
	la $a0,loadException
 	syscall
 	li $v0, 10
 	syscall
__store_adress_exception:
	li $v0, 4
	la $a0, storeException
 	syscall
 	li $v0, 10
 	syscall


__overflow_exception:
	
 	li $v0, 4
	 la $a0, overflow
 	syscall
 	li $v0, 10
 	syscall
 
 __trap_exception:
 	beq $t7,7 __fourthTrap
 	bge $t2,$t4 __tooBig
 	ble $t2,-1 __negativeFact
 	beq $t8 ,8 __zero_to_zero
 	beq $t7,7 __fourthTrap
 	
 __fourthTrap:
	li $v0, 4
	la $a0, fourthTrap
 	syscall
 	li $v0, 10
 	syscall
 __zero_to_zero:
 	li $v0, 4
	 la $a0, zeroToZero
 	syscall
 	li $v0, 10
 	syscall
 
 __tooBig:
 	li $v0, 4
	 la $a0, toobig
 	syscall
 	li $v0, 10
 	syscall
 __negativeFact:
 	li $v0, 4
	 la $a0, negativeFact
 	syscall
 	li $v0, 10
 	syscall
 

