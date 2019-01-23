##############
# 2014105078 #
# Lee HaeJin #
##############
.data 
user_input: .space 512
.align 2   # Align data
INT: .word
INT_MAX: .word 2147483647
INT_MIN: .word -2147483648
FLOAT: .float

print_Enter: .asciiz "Enter the number : "
print_Input: .asciiz "Input string : "
print_Integer_Detected: .asciiz "Integer number detected\n"
print_Float_Detected: .asciiz "Floating point number detected\n"
print_Half: .asciiz "Half of the input number : "
print_Binary: .asciiz "Binary number : "
print_Hexa: .asciiz "Hexa number : "
print_Wrap: .asciiz "\n"
print_Space: .asciiz " "
print_Error: .asciiz "Error!"

# $s1 : 0=integer, 1=float
# $s2 : 0=positivt, 1=negative 

.text
main:
	jal getInput
	jal detectIntFloat
	jal getHalfValue
	jal toBinary
	jal toHexa
	
	li $v0, 10
	syscall
	
###########################################################

getInput:
	li $v0, 4
	la $a0, print_Enter
	syscall

	li $a1, 512 # size of input buffer
	
	li $v0, 8  # get user input 
	la $a0, user_input
	#lw $s1, user_input
	syscall
	
	li $v0, 4
	la $a0, print_Input
	syscall
	
	la $a0, user_input
	syscall
	
	jr $ra

###########################################################

detectIntFloat:
	la $t0, user_input
detectLoop:
	lb $t2, 0($t0)
	addi $t0, $t0, 1
	beq $t2, 43, positive			# if '+'
	beq $t2, 45, negative			# if '-'
	beq $t2, 46, float			# if '.'
	beq $t2, 10, integer			# if 'LF' (= line feed)
	j detectLoop
positive: 					# $s2 : 0=positivt, 1=negative 
	li $s2, 0
	j detectLoop
negative:
	li $s2, 1	
	j detectLoop
integer:
	li $s1, 0
	jr $ra
float:
	li $s1, 1
	jr $ra
	
###########################################################	
	
getHalfValue:
	la $t0, user_input
	
	beq $s1, 1, getFloatHalfValue
	li $t1, 0 				# sum
	li $t2, 10 				# 10 (for sum = sum*10)
	
	li $s3, -214748365			# negative limit
	li $s4, 0				# turn count
	li $s5, 214748365			# positive limit 
	li $s6, 11				# turn limit
	li $s7, 8				# value limit
	
	beq $s2, 1, negativeHalf
positiveHalfLoop:
	lb $t3, 0($t0)
	addi $t0, $t0, 1
	beq $t3, 43, positive_skip		# if '+'
	beq $t3, 10, halfLoop_out		# if 'LF' (= line feed)
	addi $s4, $s4, 1
	addi $t3, $t3, -48			# by ASCII
	
####################################
	slti $t5, $s4, 10
	beq $t5, $zero, checkPositive
	j keepPositive
checkPositive:
	slt $t4, $t1, $s5
	slt $t5, $s4, $s6
	slt $t6, $t3, $s7
	and $t7, $t4, $t5
	and $t7, $t7, $t6
	beq $t7, $zero, gotoFloat
####################################
	keepPositive:
	mult $t1, $t2
	mflo $t1				# store result of ($t1 * $t2) in $t1
	add $t1, $t1, $t3
	j positiveHalfLoop
positive_skip:
	j positiveHalfLoop
negativeHalf:
	addi $s7, $s7, 1
negativeHalfLoop:
	lb $t3, 0($t0)
	addi $t0, $t0, 1
	beq $t3, 45, negative_skip		# if '-'
	beq $t3, 10, halfLoop_out		# if 'LF' (= line feed)
	addi $s4, $s4, 1
	addi $t3, $t3, -48			# by ASCII
	
####################################
	slti $t5, $s4, 10
	beq $t5, $zero, checkNegative
	j keepNegative
checkNegative:
	slt $t4, $s3, $t1
	slt $t5, $s4, $s6
	slt $t6, $t3, $s7
	and $t7, $t4, $t5
	and $t7, $t7, $t6
	beq $t7, $zero, gotoFloat
####################################
	keepNegative:
	mult $t1, $t2
	mflo $t1				# store result of ($t1 * $t2) in $t1
	sub $t1, $t1, $t3
	j negativeHalfLoop
negative_skip:
	j negativeHalfLoop

gotoFloat:
	la $t0, user_input
	li $s1, 1
	j getFloatHalfValue

halfLoop_out:
	li $v0, 4
	la $a0, print_Integer_Detected
	syscall

	li $v0, 4
	la $a0, print_Half
	syscall
integerHalfPrint:
	li $t2, 2				# for divide by 2
	sw $t1, INT				# save integer number
	div $t0, $t1, $t2			# divide by 2
	li $v0, 1	
	move $a0, $t0
	syscall
	li $v0, 4
	la $a0, print_Wrap
	syscall
	jr $ra


getFloatHalfValue:
	li $t1, 0
	li $t2, 10
	mtc1 $t1, $f1				# $t1 total sum
	cvt.s.w $f1, $f1
	mtc1 $t2, $f2				# $t2 mult 10^n
	cvt.s.w $f2, $f2
	mtc1 $t2, $f3				# $t2 mult 10
	cvt.s.w $f3, $f3
	
	li $t5, 0				# for float => have point?	
	beq $s2, 1, negativeHalfLoop_float
positiveHalfLoop_float:
	lb $t3, 0($t0)
	addi $t0, $t0, 1
	beq $t3, 43, positive_skip_float	# if '+'
	beq $t3, 46, point_skip			# if '.'
	beq $t3, 10, halfLoop_out_float		# if 'LF' (= line feed)
		
	addi $t3, $t3, -48			# by ASCII
	beq $t5, 1, point_count

	mul.s $f1, $f1, $f2			# store result of ($f1 * $f2) in $f1
	mtc1 $t3, $f5
	cvt.s.w $f5, $f5
	add.s $f1, $f1, $f5
	
	j positiveHalfLoop_float
positive_skip_float:
	j positiveHalfLoop_float
negativeHalfLoop_float:
	lb $t3, 0($t0)
	addi $t0, $t0, 1
		
	beq $t3, 45, negative_skip_float	# if '-'
	beq $t3, 46, point_skip			# if '.'
	beq $t3, 10, halfLoop_out_float		# if 'LF' (= line feed)
	
	addi $t3, $t3, -48			# by ASCII
	beq $t5, 1, point_count
	
	mul.s $f1, $f1, $f2			# store result of ($f1 * $f2) in $f1
	mtc1 $t3, $f5
	cvt.s.w $f5, $f5
	sub.s $f1, $f1, $f5
		
	j negativeHalfLoop_float
negative_skip_float:
	j negativeHalfLoop_float
point_skip:
	addi $t5, $t5, 1
	beq $s2, 1, negativeHalfLoop_float
	j positiveHalfLoop_float
point_count:
	mtc1 $t3, $f5
	cvt.s.w $f5, $f5	
	div.s $f5, $f5, $f2
	mul.s $f2, $f2, $f3	
	beq $s2, 1, negativePoint
	add.s $f1, $f1, $f5
	j positiveHalfLoop_float
negativePoint:
	sub.s $f1, $f1, $f5			
	j negativeHalfLoop_float
halfLoop_out_float:
	li $v0, 4
	la $a0, print_Float_Detected
	syscall
	
	swc1 $f1, FLOAT				# save float number
	
	li $v0, 4
	la $a0, print_Half
	syscall
	
	li $t4, 2				# for divide by 2
	mtc1 $t4, $f5				
	cvt.s.w $f5, $f5
		
	div.s $f4, $f1, $f5			# divide by 2
	li $v0, 2
	mov.s $f12, $f4				# print half of float number
	syscall
	
	li $v0, 4
	la $a0, print_Wrap
	syscall
	jr $ra	
		
###########################################################

toBinary:
	li $v0, 4
    	la $a0, print_Binary
	syscall    
	beq $s1, 1, floatBinaryLoad
	lw $t2, INT
	j makeBinary
floatBinaryLoad:
	lw $t2, FLOAT
makeBinary:
	li $s3, 32       			# Set up a loop counter
	li $s4, 4				# Set up a space counter
binaryLoop:
 	rol $t2, $t2, 1   			# Roll the bits left by one bit - wraps highest bit to lowest bit.
    	and $t0, $t2, 1   			# Mask bit (AND with 0000 0000 ... 0001)
   	add $t0, $t0, 48 			# for ASCII 0~9 
    	move $a0, $t0      			# Output ASCII
    	li $v0, 11
    	syscall
	subi $s4, $s4, 1
    	subi $s3, $s3, 1   			# Decrement loop counter
    	bne $s4, $zero, spaceSkip_binary
    	addi $s4, $s4, 4
    	li $v0, 4
    	la $a0, print_Space
	syscall 
spaceSkip_binary:
    	bne $s3, $zero, binaryLoop  		# Keep looping
    	li $v0, 4
	la $a0, print_Wrap
	syscall
    	jr $ra
    	
###########################################################

toHexa:
	li $v0, 4
    	la $a0, print_Hexa
	syscall 
	beq $s1, 1, floatHexaLoad
	lw $t2, INT	
	j makeHexa
floatHexaLoad:
	lw $t2, FLOAT
makeHexa:	
	li $s3, 8       			# Set up a loop counter
	li $s4, 2				# Set up a space counter
hexaLoop:
 	rol $t2, $t2, 4   			# Roll the bits left by one bit - wraps highest bit to lowest bit.
    	and $t0, $t2, 15   			# Mask bit (AND with 0000 0000 ... 1111)	
    	slti $t1, $t0, 10
    	beq $t1, $zero, hexaChar
	add $t0, $t0, 48			# for ASCII 0~9 
	j continue_hexa
hexaChar:
   	add $t0, $t0, 55 	 		# for ASCII A~F 
continue_hexa:
    	move $a0, $t0      			# Output ASCII 
    	li $v0, 11
    	syscall
	subi $s4, $s4, 1
    	subi $s3, $s3, 1   			# Decrement loop counter
    	bne $s4, $zero, spaceSkip_hexa
    	addi $s4, $s4, 2
    	li $v0, 4
    	la $a0, print_Space
	syscall    	
spaceSkip_hexa:
    	bne $s3, $zero, hexaLoop		# Keep looping
    	li $v0, 4
	la $a0, print_Wrap
	syscall
	jr $ra
