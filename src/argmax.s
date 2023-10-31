.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
	# Prologue
	addi t0, x0, 1 # set t0 = 1
	blt a1, t0, end
	add t0, a0, x0
	add t1, a1, x0
	addi sp, sp, -12
	sw s2, 8(sp) # temp register
	sw s1, 4(sp) # the max number
	sw s0, 0(sp) # argmax
	addi s0, x0, 0
	addi s1, x0, 0
	addi s2, x0, 0
	addi t2, x0, 0

loop_start:
    beq t2, t1, loop_end
	slli s2, t2, 2
	add s2, s2, t0
	lw s2, 0(s2)
	bge s1, s2, loop_continue
	add s0, t2, x0
	add s1, s2, x0
loop_continue:
    addi, t2, t2, 1
	jal x0, loop_start
loop_end:
	# Epilogue

	add a0, s0, x0
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
	addi sp, sp, 12
	ret

end:
    li a0, 36
	j exit
