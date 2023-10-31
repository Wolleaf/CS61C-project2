.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

	# Prologue
    addi sp, sp, -20
	sw s0, 0(sp) # file descriptor
	sw s1, 4(sp) # pointer of matrix
	sw s2, 8(sp) # row
	sw s3, 12(sp) # column
	sw ra, 16(sp)
	add s0, a0, x0
	add s1, a1, x0
	add s2, a2, x0
	add s3, a3, x0

	# fopen
    addi a1, x0, 1
	jal ra, fopen
	addi a1, x0, -1
	beq a0, a1, fopen_exit
	add s0, a0, x0

	# write row and column
	add a0, s0, x0
    addi sp, sp, -4
	sw s2, 0(sp)
	add a1, sp, x0
	addi a2, x0, 1
	addi a3, x0, 4
	jal ra, fwrite
	addi a2, x0, 1
	bne a0, a2, fwrite_end
	add a0, s0, x0
	sw s3, 0(sp)
	add a1, sp, x0
	addi a2, x0, 1
	addi a3, x0, 4
	jal ra, fwrite
	addi a2, x0, 1
	bne a0, a2, fwrite_end
	addi sp, sp, 4

    # write matrix
	add a0, s0, x0
	add a1, s1, x0
	mul a2, s2, s3
	addi a3, x0, 4
	jal ra, fwrite
	mul a2, s2, s3
	bne a0, a2, fwrite_end

    # fclose
    add a0, s0, x0
	jal ra, fclose
	bne a0, x0, fclose_exit

	# Epilogue
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	lw s3, 12(sp)
	lw ra, 16(sp)
    addi sp, sp, 20
	ret


fopen_exit:
    li a0, 27
	j exit

fwrite_end:
    li a0, 30
	j exit

fclose_exit:
    li a0, 28
	j exit
