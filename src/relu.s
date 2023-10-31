.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
	# Prologue
	addi t0, x0, 1 # set t0 = 1
	blt a1, t0, end
	add t0, a0, x0
	add t1, a1, x0
	addi sp, sp, -8
	sw s1, 4(sp)
	sw s0, 0(sp)
	addi s0, x0, 0
	addi t2, x0, 0

loop_start:
    beq t2, t1, loop_end
	slli s0, t2, 2
	add s0, s0, t0
	lw s1, 0(s0)
	bge s1, x0, loop_continue
	sw x0, 0(s0)
loop_continue:
    addi, t2, t2, 1
	jal x0, loop_start
loop_end:

	# Epilogue

    lw s1, 4(sp)
    lw s0, 0(sp)
	addi sp, sp, 8
	ret
end:
    li a0, 36
	j exit