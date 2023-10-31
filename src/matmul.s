.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

	# Error checks
	addi a7, x0, 1
	blt a1, a7, end_38
	blt a2, a7, end_38
	blt a4, a7, end_38
	blt a5, a7, end_38
	bne a2, a4, end_38

	# Prologue
	addi sp, sp, -44
	sw ra, 40(sp) # save ra
	sw s9, 36(sp) # use saved regs
	sw s8, 32(sp)
	sw s7, 28(sp)
	sw s6, 24(sp) # save Arguments
	sw s5, 20(sp)
	sw s4, 16(sp)
	sw s3, 12(sp)
	sw s2, 8(sp)
	sw s1, 4(sp)
	sw s0, 0(sp)
	add s0, a0, x0
	add s1, a1, x0
	add s2, a2, x0
	add s3, a3, x0
	add s4, a4, x0
	add s5, a5, x0
	add s6, a6, x0
	addi a0, x0, 0 #  the address of row A
	addi a1, x0, 0 #  the address of column B
	addi s7, x0, 0 #  number of row of A
	addi s8, x0, 0 #  number of column of B
	addi s9, x0, 0 #  the offset of C


outer_loop_start:
    beq s7, s1, outer_loop_end # row end?

inner_loop_start:
    beq s8, s5, inner_loop_end # column end?
	mul a0, s7, s2
    slli a0, a0, 2
	add a0, a0, s0 # compute address of row A
	slli a1, s8, 2
	add a1, a1, s3 # the address of column B
	add a2, s2, x0 # total elements: A's column or B's row
	addi a3, x0, 1 # the stride of A:1
	add a4, s5, x0 # the stride of B:B's column
	jal ra, dot # dot product
	mul s9, s7, s5
	add s9, s9, s8
	slli s9, s9, 2 # compute the offset
	add s9, s9, s6 # get C's address
	sw a0, 0(s9)
	addi s8, s8, 1
	jal x0, inner_loop_start

inner_loop_end:
    addi s8, x0, 0
    addi s7, s7, 1
	jal x0, outer_loop_start

outer_loop_end:


	# Epilogue
	lw ra, 40(sp)
	lw s9, 36(sp)
	lw s8, 32(sp)
	lw s7, 28(sp)
	lw s6, 24(sp)
	lw s5, 20(sp)
	lw s4, 16(sp)
	lw s3, 12(sp)
	lw s2, 8(sp)
	lw s1, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 44

	ret

end_38:
    li a0, 38
	j exit