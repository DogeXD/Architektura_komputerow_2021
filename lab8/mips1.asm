.data
	infix: .space 256
	postfix: .space 256
	operator: .space 256
	endMsg: .asciiz "\nczy powtorzyc dzialanie programu? 1-tak 0-nie\n"
	errorMsg: .asciiz "zle wejscie"
	prompt_postfix: .asciiz "Postac w ONP: "
	prompt_result: .asciiz "Wynik: "
	prompt_infix: .asciiz "dzialanie: "
	buff: .asciiz "wybierz dzialanie z buforem"
	welcoma: .asciiz "podaj rownanie\n"
	converter: .word 1
	wordToConvert: .word 1
	stack: .float
	
	chooseBufOpText: .asciiz "wybierz dzialanie na buforze\n"
	addToBufText: .asciiz "1: M+\n"
	subFromBufText: .asciiz"2: M-\n"
	clearBufText: .asciiz "3: MC\n"
	writeBufText: .asciiz "4: MR\n"
	nothingBufText: .asciiz "5: nic\n"
	bufText:  .asciiz"\nbufor ma wartosc: "
.text

start:
#########################################################
# Get infix expression
########################################################
	li $v0,4
	la $a0,welcoma
	syscall


	li $v0, 8
	la $a0, infix
	la $a1, 256
	syscall
 	
	#print infix from stack
	li $v0, 4
	la $a0, prompt_infix	#print prompt
	syscall
	
	li $v0, 4
	la $a0, infix		#print expression
	syscall
	
	li $v0, 11
	li $a0, '\n'		#print newLine
	syscall
	
# utils

	li $s7,0		# Status of a program , helps to decide what to do based on input
				# 0 = no input
				# 1 = number
				# 2 = operator
				# 3 =  opening bracket
				# 4 =  closing brakcet
				
	li $t9,0		# Count digits
	
	li $t5,-1		# Postfix stack top offset
	li $t6,-1		# Operator stack top offset
	la $t1, infix		# Infix stack adress
	la $t2, postfix		#postfix stack adress	
	la $t3, operator	# operator stack adress
	addi $t1,$t1,-1		# Set initial address of infix to -1
	
#################################################	
# Convert to postfix
################################################

scanInfix: 			
#for each character

# Check all valid input option
	addi $t1,$t1,1			# Increase infix top
	lb $t4, ($t1)			# character->t4
	beq $t4, ' ', scanInfix		# if spacebar then continue
	beq $t4, '\n', EOF		# if \n then pop all operators
	beq $t9,0,digit1		# 
	beq $t9,1,digit2		# if digit
	beq $t9,2,digit3		# 
	continueScan:
	beq $t4, '+', plusMinus
	beq $t4, '-', plusMinus
	beq $t4, '*', multiplyDivide
	beq $t4, '/', multiplyDivide
	beq $t4, '(', openBracket
	beq $t4, ')', closeBracket
	beq $t4, '^', plusMinus
	
wrongInput:				#print error messege
	li $v0, 4
 	la $a0, errorMsg
 	syscall
 	j ask
finishScan:
# Print postfix expression
	li $v0, 4
	la $a0, prompt_postfix
	syscall
	li $t6,-1		# Load current of Postfix top offset to -1
printPost:
	#Loop for each character on stack
	addi $t6,$t6,1		# postfix[top++]
	add $t8,$t2,$t6		# Load adress of curr postfix
	lbu $t7,($t8)		# Load value of current Postfix
	bgt $t6,$t5,finishPrint	# Print all postfix --> calculate
	bgt $t7,99,printOp	# If current Postfix > 99 --> an operator
	# If not then current Postfix is a number
	
	li $v0, 1
	add $a0,$t7,$zero	#print int
	syscall
	li $v0, 11
	li $a0, ' '	# print space
	syscall
	j printPost		# loop
	
	
	#print operator
	printOp:
	li $v0, 11
	addi $t7,$t7,-100	# Decode operator
	add $a0,$t7,$zero
	syscall
	
	li $v0, 11
	li $a0, ' '		#print space
	syscall
	j printPost		# Loop
finishPrint:

	li $v0, 11
	li $a0, '\n'
	syscall
	
###################################################################
###### CALCULATE
##################################################
	
	
# Calculate
	li $t9,-4		# decrement stack pointer
	la $t3,stack		
	li $t6,-1		# Load current of Postfix offset to -1
	l.s $f0,converter	# Load converter
calPost:
	addi $t6,$t6,1		# postfix top++ 
	add $t8,$t2,$t6		# Load address 
	lbu $t7,($t8)		# Load value
	bgt $t6,$t5,printResult	# if finished calculating
	bgt $t7,99,calculate	# If current Postfix > 99 popout 2 number to calculate
	# If not then current Postfix is a number
	addi $t9,$t9,4		# current stack top offset
	add $t4,$t3,$t9		# current stack top address
	sw $t7,wordToConvert	
	l.s $f10,wordToConvert	# load number to convert to float
	div.s $f10,$f10,$f0
	s.s $f10,($t4)		# push number into stack
	sub.s $f10,$f10,$f10	# clear $f10
	j calPost		# Loop
	calculate:
		# Pop 1 number
		add $t4,$t3,$t9		
		l.s $f3,($t4)
		# Pop next number
		addi $t9,$t9,-4
		add $t4,$t3,$t9		
		l.s $f2,($t4)
		# Decode operator
		beq $t7,143,plus
		beq $t7,145,minus
		beq $t7,142,multiply
		beq $t7,147,divide
		plus:
			add.s $f1,$f2,$f3
			s.s $f1,($t4)
			sub.s $f2,$f2,$f2	# Reset f2 f3
			sub.s $f3,$f3,$f3	
			j calPost
		minus:
			sub.s $f1,$f2,$f3
			s.s $f1,($t4)	
			sub.s $f2,$f2,$f2	# Reset f2 f3
			sub.s $f3,$f3,$f3
			j calPost
		multiply:
			mul.s $f1,$f2,$f3
			s.s $f1,($t4)	
			sub.s $f2,$f2,$f2	# Reset f2 f3
			sub.s $f3,$f3,$f3
			j calPost
		divide:
			div.s $f1,$f2,$f3
			s.s $f1,($t4)	
			sub.s $f2,$f2,$f2	# Reset f2 f3
			sub.s $f3,$f3,$f3
			j calPost
		
printResult:	
	li $v0, 4
	la $a0, prompt_result
	syscall
	li $v0, 2
	l.s $f12,($t4)
	syscall
	li $v0, 11
	li $a0, '\n'
	syscall
	
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
	j printBuf
addToBuf:
	add.s $f4,$f12,$f4
	j printBuf
subFromBuf:
	sub.s $f4,$f4,$f12
	j printBuf
clearBuf:
	mov.s	$f4,$f6  #W F6 jest 0 
	j printBuf
loadBuf:
	mov.s	$f4,$f12


printBuf:
	li $v0,4
	la $a0,bufText
	syscall

	
	li,$v0,2
	mov.s   $f12,$f4	#wypisanie wyniku
	syscall
ask: 			# Ask user to continue or not
 	li $v0, 4
 	la $a0, endMsg
 	syscall
 	
 	li $v0,5
 	syscall
 	beq $v0,1,start
# End program
end:
 	li $v0, 10
 	syscall
 
 
 ################################################
 # UTILS AND UTILS FOR CALCULATIONS
 #########################################
EOF:
	beq $s7,2,wrongInput			# End with an operator or open bracket
	beq $s7,3,wrongInput
	beq $t5,-1,wrongInput			# Input nothing
	j popAll
	
digit1:
	beq $t4,'0',store1Digit
	beq $t4,'1',store1Digit
	beq $t4,'2',store1Digit
	beq $t4,'3',store1Digit
	beq $t4,'4',store1Digit
	beq $t4,'5',store1Digit
	beq $t4,'6',store1Digit
	beq $t4,'7',store1Digit
	beq $t4,'8',store1Digit
	beq $t4,'9',store1Digit
	j continueScan
	
digit2: 
	beq $t4,'0',store2Digit
	beq $t4,'1',store2Digit
	beq $t4,'2',store2Digit
	beq $t4,'3',store2Digit
	beq $t4,'4',store2Digit
	beq $t4,'5',store2Digit
	beq $t4,'6',store2Digit
	beq $t4,'7',store2Digit
	beq $t4,'8',store2Digit
	beq $t4,'9',store2Digit
	
	jal numberToPost
	j continueScan
digit3: 
	beq $t4,'0',wrongInput
	beq $t4,'1',wrongInput
	beq $t4,'2',wrongInput
	beq $t4,'3',wrongInput
	beq $t4,'4',wrongInput
	beq $t4,'5',wrongInput
	beq $t4,'6',wrongInput
	beq $t4,'7',wrongInput
	beq $t4,'8',wrongInput
	beq $t4,'9',wrongInput
	jal numberToPost
	j continueScan
	
plusMinus:			# Input is + -
	beq $s7,2,wrongInput		# two operators in row or (
	beq $s7,3,wrongInput
	beq $s7,0,wrongInput		# operator was 1st
	li $s7,2			# change input status to 2
	continuePlusMinus:
	beq $t6,-1,inputToOp		# stack is empty-> push
	add $t8,$t6,$t3			# top op
	lb $t7,($t8)			# val of top operator
	beq $t7,'(',inputToOp		# push
	beq $t7,'+',equalPrecedence	# top is + -
	beq $t7,'-',equalPrecedence
	beq $t7,'*',lowerPrecedence	# top is * /
	beq $t7,'/',lowerPrecedence
	
multiplyDivide:			# Input is * /
	beq $s7,2,wrongInput		# two operators in row or (
	beq $s7,3,wrongInput
	beq $s7,0,wrongInput		# operator was 1st
	li $s7,2			# change input status to 2
	beq $t6,-1,inputToOp		# stack is empty-> push
	add $t8,$t6,$t3			# top op
	lb $t7,($t8)			# val of top operator
	beq $t7,'(',inputToOp		# if top is '(' then push
	beq $t7,'+',inputToOp		# if top is + - then push
	beq $t7,'-',inputToOp
	beq $t7,'*',equalPrecedence	# top is * /
	beq $t7,'/',equalPrecedence
openBracket:	
	beq $s7,1,wrongInput		# after number
	beq $s7,4,wrongInput		# after )
	
	li $s7,3			# Change input status to 3
	j inputToOp
closeBracket:			
	beq $s7,2,wrongInput		# after operator
	beq $s7,3,wrongInput		# after (
	li $s7,4
	add $t8,$t6,$t3			# stack top
	lb $t7,($t8)			# stack top val
	beq $t7,'(',wrongInput		# if "()"
	continueCloseBracket:
	beq $t6,-1,wrongInput		# no (
	add $t8,$t6,$t3			# stack top
	lb $t7,($t8)			# stack top val
	beq $t7,'(',matchBracket	# find (
	jal opToPostfix			# pop top
	j continueCloseBracket		# loop
			
equalPrecedence:	# if top has same precedence as recived (top is + and recived -)
	jal opToPostfix			# pop top
	j inputToOp			# push new
lowerPrecedence:	#top is */ rec is +-
	jal opToPostfix			# pop top
	j continuePlusMinus		# loop
	
inputToOp:			# Push input to Operator
	add $t6,$t6,1			
	add $t8,$t6,$t3			
	sb $t4,($t8)			# Store input in Operator
	j scanInfix
opToPostfix:			# Pop top of Operator in push into Postfix
	addi $t5,$t5,1			
	add $t8,$t5,$t2			
	addi $t7,$t7,100		# Encode operator + 100
	sb $t7,($t8)			# Store operator into Postfix
	addi $t6,$t6,-1			
	jr $ra
matchBracket:			# Discard a pair of matched brackets
	addi $t6,$t6,-1			
	j scanInfix
popAll:				# Pop all Operator to Postfix
	jal numberToPost
	beq $t6,-1,finishScan		#if operator empty them finish
	add $t8,$t6,$t3			
	lb $t7,($t8)		
	beq $t7,'(',wrongInput		# if nmatched bracket then error
	beq $t7,')',wrongInput
	jal opToPostfix
	j popAll			#loop
store1Digit:
	beq $s7,4,wrongInput		# receive number after )
	addi $s4,$t4,-48		
	add $t9,$zero,1			# change status to 1 
	li $s7,1
	j scanInfix
store2Digit:
	beq $s7,4,wrongInput		# Rreceive number after )
	
	addi $s5,$t4,-48		
	mul $s4,$s4,10
	add $s4,$s4,$s5			# stored number = first digit * 10 + second digit
	add $t9,$zero,2			# change status to 2 
	li $s7,1
	j scanInfix
numberToPost:
	beq $t9,0,endnumberToPost
	addi $t5,$t5,1
	add $t8,$t5,$t2			
	sb $s4,($t8)			# store number in Postfix
	add $t9,$zero,$zero		# change status to 0 digit
	endnumberToPost:
	jr $ra
