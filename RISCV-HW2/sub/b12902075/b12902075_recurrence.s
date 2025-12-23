# I/O part is copied and modified from last hw
	.globl __start

	.text
recurrence:
# allocate stack
	addi   sp, sp, -16
	sw     ra, 12(sp)
	sw     s0, 8(sp)      # can be omitted
	sw     a0, 4(sp)
	sw     x0, 0(sp)

# base case
	li     t0, 1
	beq    t0, a0, base1
	beq    x0, a0, base0

# recurrence
# +2T(n-1)
	lw     a0, 4(sp)
	addi   a0, a0, -1
	jal    ra, recurrence
	lw     t0, 0(sp)
	slli   t1, a1, 1
	add    t0, t0, t1
	sw     t0, 0(sp)
# +T(n-2)
	lw     a0, 4(sp)
	addi   a0, a0, -2
	jal    ra, recurrence
	lw     t0, 0(sp)
	add    t0, t0, a1
	sw     t0, 0(sp)
	j      epilogue

base1:
	li     t0, 1
	sw     t0, 0(sp)
	j      epilogue

base0:
	li     t0, 0
	sw     t0, 0(sp)
	j      epilogue

epilogue:
# free stack
	lw     ra, 12(sp)
	lw     s0, 8(sp)      # can be omitted
	lw     a0, 4(sp)
	lw     a1, 0(sp)
	addi   sp, sp, 16
	jalr   x0, 0(ra)


__start:
# Read first operand
	li     a0, 5
	ecall
# a0 is the parameter and input
# a1 is the return value
	jal    ra, recurrence

output:
# Output the result
	li     a0, 1
	ecall

exit:
# Exit program(necessary)
	li     a0, 10
	ecall



