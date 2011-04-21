	.data
Newline: .asciiz "\n"
Enter: .asciiz "Please enter an integer: "
global_y: .word 0

	.text

####################################
# Function: sub starts here
####################################
sub_fn:

	.text
sw $a0, 56($sp)		# Save the parameters on the stack
sw $a1, 60($sp)		# Save the parameters on the stack
sw $zero, 64($sp)	# Save the local vars on the stack
sw $ra, 0($sp)		# Save the return address of the caller
sw $a0, 40($sp)
sw $a1, 44($sp)
sw $a2, 48($sp)
sw $a3, 52($sp)

lw $t0, 56($sp)
li $v0, 1
move $a0, $t0
syscall			# Prints output

li $v0, 4
la $a0, Newline
syscall			# Simply prints out a newline 
lw $t0, 64($sp)
lw $t0, 56($sp)
li $t1, 1
sub $t0, $t0, $t1
sw $t0, 64($sp)
lw $t0, 64($sp)
move $v0, $t0		# Move the return value to the return register
lw $ra, 0($sp)		# Load the return value of the calling function
jr $ra			# Jump to the return address of the caller

	.text

####################################
# Function: add starts here
####################################
add_fn:

	.text
sw $a0, 56($sp)		# Save the parameters on the stack
sw $zero, 60($sp)	# Save the local vars on the stack
sw $zero, 64($sp)	# Save the local vars on the stack
sw $zero, 68($sp)	# Save the local vars on the stack
sw $ra, 0($sp)		# Save the return address of the caller
sw $a0, 40($sp)
sw $a1, 44($sp)
sw $a2, 48($sp)
sw $a3, 52($sp)

lw $t1, 64($sp)
li $v0, 4
la $a0, Enter
syscall			# Prints out prompt
li $v0, 5
syscall
move $t1, $v0		# Gathers input from user
sw $t1, 64($sp)
lw $t1, 68($sp)
li $t1, 4
sw $t1, 68($sp)
lw $t1, 60($sp)
lw $t1, 64($sp)
lw $t2, 64($sp)
mul $t1, $t1, $t2
lw $t2, 68($sp)
neg $t2, $t2
add $t1, $t1, $t2
sw $t1, 60($sp)
lw $t1, 60($sp)
li $v0, 1
move $a0, $t1
syscall			# Prints output

li $v0, 4
la $a0, Newline
syscall			# Simply prints out a newline 
lw $t1, 64($sp)

#########################################
# Stack maintenance for a function call #
#########################################
sw $t0, 8($sp)
sw $t1, 12($sp)
sw $t2, 16($sp)
sw $t3, 20($sp)
sw $t4, 24($sp)
sw $t5, 28($sp)
sw $t6, 32($sp)
sw $t7, 36($sp)
sw $a0, 40($sp)
sw $a1, 44($sp)
sw $a2, 48($sp)
sw $a3, 52($sp)
sw $fp, 4($sp)		# Saves the frame pointer of the caller
lw $t1, 60($sp)
move $a0, $t1		# Loads arguments for the callee function
addi $sp, $sp, -104	# Allocates a new frame for the callee
addi $fp, $sp, 100	# Sets the frame of the callee
jal sub_fn		# Jump to the callee function
addi $sp, $sp, 104	# Restores the stack pointer for the caller
lw $fp, 4($sp)		# Restores the frame pointer of the caller
lw $a0, 40($sp)
lw $a1, 44($sp)
lw $a2, 48($sp)
lw $a3, 52($sp)
lw $t0, 8($sp)
lw $t1, 12($sp)
lw $t2, 16($sp)
lw $t3, 20($sp)
lw $t4, 24($sp)
lw $t5, 28($sp)
lw $t6, 32($sp)
lw $t7, 36($sp)
move $t2, $v0		# Move the return variable to an available temp register
sw $t2, 64($sp)
lw $t2, 60($sp)
lw $t2, 64($sp)
lw $t3, 68($sp)
sub $t2, $t2, $t3
sw $t2, 60($sp)
lw $t2, 60($sp)
li $v0, 1
move $a0, $t2
syscall			# Prints output

li $v0, 4
la $a0, Newline
syscall			# Simply prints out a newline 
lw $ra, 0($sp)		# Load the return value of the calling function
jr $ra			# Jump to the return address of the caller

	.text

####################################
# Function: main starts here
####################################
main:

	.text
sw $ra, 0($sp)		# Save the return address of the caller
sw $a0, 40($sp)
sw $a1, 44($sp)
sw $a2, 48($sp)
sw $a3, 52($sp)


#########################################
# Stack maintenance for a function call #
#########################################
sw $t0, 8($sp)
sw $t1, 12($sp)
sw $t2, 16($sp)
sw $t3, 20($sp)
sw $t4, 24($sp)
sw $t5, 28($sp)
sw $t6, 32($sp)
sw $t7, 36($sp)
sw $a0, 40($sp)
sw $a1, 44($sp)
sw $a2, 48($sp)
sw $a3, 52($sp)
sw $fp, 4($sp)		# Saves the frame pointer of the caller
addi $sp, $sp, -104	# Allocates a new frame for the callee
addi $fp, $sp, 100	# Sets the frame of the callee

jal add_fn		# Jump to the callee function
addi $sp, $sp, 104	# Restores the stack pointer for the caller
lw $fp, 4($sp)		# Restores the frame pointer of the caller
lw $a0, 40($sp)
lw $a1, 44($sp)
lw $a2, 48($sp)
lw $a3, 52($sp)
lw $t0, 8($sp)
lw $t1, 12($sp)
lw $t2, 16($sp)
lw $t3, 20($sp)
lw $t4, 24($sp)
lw $t5, 28($sp)
lw $t6, 32($sp)
lw $t7, 36($sp)
move $t2, $v0		# Move the return variable to an available temp register
# main should break through to exit the program

li $v0, 4
la $a0, Newline
syscall			# Simply prints out a newline for aesthetics 
li $v0, 10
syscall			 # Exit the program
