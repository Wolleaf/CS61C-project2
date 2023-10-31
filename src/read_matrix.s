.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

	# Prologue
    addi sp, sp, -20
	sw s0, 0(sp) # file descriptor
	sw s1, 4(sp) # row
	sw s2, 8(sp) # column
	sw s3, 12(sp) # pointer of matrix
	sw ra, 16(sp)
	add s0, a0, x0
	add s1, a1, x0
	add s2, a2, x0
    
	# fopen
	addi a1, x0, 0
    jal ra, fopen
	addi a1, x0, -1
	beq a0, a1, fopen_exit
	add s0, a0, x0

    # read row and column
	add a0, s0, x0
	add a1, s1, x0
	addi a2, x0, 4
	jal ra, fread
	addi a2, x0, 4
	bne a0, a2, fread_exit
	add a0, s0, x0
	add a1, s2, x0
	addi a2, x0, 4
	jal ra, fread
	addi a2, x0, 4
	bne a0, a2, fread_exit

    # malloc matrix
	lw a1, 0(s1)
	lw a2, 0(s2)
	mul a0, a1, a2
	slli a0, a0, 2
	jal ra, malloc
	beq a0, x0, malloc_exit
	add s3, a0, x0

    # read values
	add a0, s0, x0
	lw a1, 0(s1)
	lw a2, 0(s2)
	mul a2, a1, a2
    slli a2, a2, 2
	add a1, s3, x0
	addi sp, sp, -4
	sw a2, 0(sp)
	jal ra, fread
	lw a2, 0(sp)
	addi sp, sp, 4
	bne a0, a2, fread_exit

    # fclose
    add a0, s0, x0
	jal ra, fclose
	bne a0, x0, fclose_exit
	add a0, s3, x0

	# Epilogue
	lw s0, 0(sp) # file descriptor
	lw s1, 4(sp) # row
	lw s2, 8(sp) # column
	lw s3, 12(sp) # pointer of matrix
	lw ra, 16(sp)
    addi sp, sp, 20
	ret

fopen_exit:
    li a0, 27
	j exit

malloc_exit:
    li a0, 26
	j exit

fread_exit:
    li a0, 29
	j exit

fclose_exit:
    li a0, 28
	j exit