.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
	# Prologue
	addi t0, x0, 1 # set t0 = 1
	blt a2, t0, end_36
	blt a3, t0, end_37
	blt a4, t0, end_37
	addi a5, x0, 0 # the first index
	addi a6, x0, 0 # the second index
	addi a7, x0, 0 # times
	addi t0, x0, 0 # sum

loop_start:
    bge a7, a2, loop_end
	slli t1, a5, 2
	slli t2, a6, 2
	add t1, t1, a0
	add t2, t2, a1
	lw t1, 0(t1)
	lw t2, 0(t2)
	mul t1, t1, t2
	add t0, t0, t1
	add a5, a5, a3
	add a6, a6, a4
	addi a7, a7, 1
	jal x0, loop_start
loop_end:

	# Epilogue
	add a0, t0, x0
	ret

end_36:
    li a0, 36
	j exit
end_37:
    li a0, 37
	j exit
