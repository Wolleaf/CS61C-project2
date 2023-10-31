.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    # check
	li t0, 5
	bne a0, t0, argc_exit
    # Prologue
    addi sp, sp, -52
	sw s0, 0(sp) # m0 filename
	sw s1, 4(sp) # m1 filename
	sw s2, 8(sp) # inptu matrix filename
	sw s3, 12(sp) # output matrix filename
	sw s4, 16(sp) # a2
	sw s5, 20(sp) # row of m0
	sw s6, 24(sp) # column of m0
	sw s7, 28(sp) # row of m1
	sw s8, 32(sp) # column of m1
	sw s9, 36(sp) # row of input
	sw s10, 40(sp) # column of input
	sw s11, 44(sp) # h matrix
	sw ra, 48(sp)
	lw s0, 4(a1) # pointer to the filepath string of m0
	lw s1, 8(a1) # pointer to the filepath string of m1
	lw s2, 12(a1) # pointer to the filepath string of input matrix
	lw s3, 16(a1) # pointer to the filepath string of output file
	add s4, a2, x0 # a2
	
	# Read pretrained m0
	li a0, 4
	jal ra, malloc
	beq a0, x0, malloc_exit
	add s5, a0, x0 # address of row
	li a0, 4
	jal ra, malloc
	beq a0, x0, malloc_exit
	add s6, a0, x0 # address of column
	add a0, s0, x0
	add a1, s5, x0
	add a2, s6, x0
	jal ra, read_matrix
	add s0, a0, x0 # m0 matrix

	# Read pretrained m1
	li a0, 4
	jal ra, malloc
	beq a0, x0, malloc_exit
	add s7, a0, x0 # address of row
	li a0, 4
	jal ra, malloc
	beq a0, x0, malloc_exit
	add s8, a0, x0 # address of column
	add a0, s1, x0
	add a1, s7, x0
	add a2, s8, x0
	jal ra, read_matrix
	add s1, a0, x0 # m1 matrix

	# Read input matrix
	li a0, 4
	jal ra, malloc
	beq a0, x0, malloc_exit
	add s9, a0, x0 # address of row
	li a0, 4
	jal ra, malloc
	beq a0, x0, malloc_exit
	add s10, a0, x0 # address of column
	add a0, s2, x0
	add a1, s9, x0
	add a2, s10, x0
	jal ra, read_matrix
	add s2, a0, x0 # input matrix

	# Compute h = matmul(m0, input)
	lw a0, 0(s5) # row of h
	lw a1, 0(s10) # column of h
	mul a0, a0, a1 # number of h
	slli a0, a0, 2
	jal ra, malloc
	beq a0, x0, malloc_exit
	add s11, a0, x0 # address of h
	add a6, s11, x0
    add a0, s0, x0
	lw a1, 0(s5)
	lw a2, 0(s6)
    add a3, s2, x0
	lw a4, 0(s9)
	lw a5, 0(s10)
	jal ra, matmul

	# Compute h = relu(h)
	lw a0, 0(s5)
	lw a1, 0(s10)
	mul a1, a0, a1
	add a0, s11, x0
	jal ra, relu

	# Compute o = matmul(m1, h)
	lw a0, 0(s7) # row of o
	lw a1, 0(s10) # column of o
	mul a0, a0, a1 # number of o
	slli a0, a0, 2
	jal ra, malloc
	beq a0, x0, malloc_exit
	add t0, a0, x0 # address of o
	add a6, t0, x0
    add a0, s1, x0
	lw a1, 0(s7)
	lw a2, 0(s8)
    add a3, s11, x0
	lw a4, 0(s5)
	lw a5, 0(s10)
	addi sp, sp, -4
	sw t0, 0(sp)
	jal ra, matmul
	lw t0, 0(sp)
    addi sp, sp, 4

	# Write output matrix o
	add a0, s3, x0
	add a1, t0, x0
	lw a2, 0(s7)
	lw a3, 0(s10)
	addi sp, sp, -4
	sw t0, 0(sp)
	jal ra, write_matrix
	lw t0, 0(sp)
	addi sp, sp, 4

	# Compute and return argmax(o)
	lw a0, 0(s7) # row of o
	lw a1, 0(s10) # column of o
	mul a1, a0, a1 # number of o
	add a0, t0, x0
	addi sp, sp, -4
	sw t0, 0(sp)
	jal ra, argmax
	lw t0, 0(sp)
	addi sp, sp, 4
	add t1, a0, x0 # the argmax of o: the classification

	# If enabled, print argmax(o) and newline
    bnez s4, end
    add a0, t1, x0
	addi sp, sp, -8
	sw t0, 0(sp)
	sw t1, 4(sp)
	jal ra, print_int
	li a0, '\n'
	jal ra, print_char
	lw t0, 0(sp)
	lw t1, 4(sp)
	addi sp, sp, 8
end:
    add s0, t0, x0 # use s0 to save t0(the address of o)
    add s1, t1, x0 # use s1 to save t1(the classification)
	# free allocated memory
	add a0, s5, x0
	jal ra, free
	add a0, s6, x0
	jal ra, free
	add a0, s7, x0
	jal ra, free
	add a0, s8, x0
	jal ra, free
	add a0, s9, x0
	jal ra, free
	add a0, s10, x0
	jal ra, free
	add a0, s11, x0
	jal ra, free
	add a0, s0, x0
	jal ra, free
	add a0, s1, x0 # the retval

	# Prologue
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	lw s3, 12(sp)
	lw s4, 16(sp)
	lw s5, 20(sp)
	lw s6, 24(sp)
	lw s7, 28(sp)
	lw s8, 32(sp)
	lw s9, 36(sp)
	lw s10, 40(sp)
	lw s11, 44(sp)
	lw ra, 48(sp)
    addi sp, sp, 52
	ret

argc_exit:
    li a0, 31
	jal exit

malloc_exit:
    li a0, 26
	jal exit
