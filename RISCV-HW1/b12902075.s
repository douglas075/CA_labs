.globl __start

.rodata
    division_by_zero: .string "division by zero"

.text
__start:
    # Read first operand
    li a0, 5
    ecall
    mv s0, a0
    # Read operation
    li a0, 5
    ecall
    mv s1, a0
    # Read second operand
    li a0, 5
    ecall
    mv s2, a0

###################################
#  TODO: Develop your calculator  #

switch:
    li t0 0
    beq s1 t0 add_op
    li t0 1
    beq s1 t0 sub_op
    li t0 2
    beq s1 t0 mul_op
    li t0 3
    beq s1 t0 div_op
    li t0 4
    beq s1 t0 min_op
    li t0 5
    beq s1 t0 pow_op
    li t0 6
    beq s1 t0 fac_op
    jal x0 exit
    
add_op:
    add s3 s0 s2
    jal x0 output

sub_op:
    sub s3 s0 s2
    jal x0 output

mul_op:
    mul s3 s0 s2
    jal x0 output

div_op:
    beq s2 x0 division_by_zero_except
    div s3 s0 s2
    jal x0 output

min_op:
    sub t0 s0 s2 
    blt t0 x0 first_smaller # if s0 - s2 < 0 
    mv s3 s2
    jal x0 output

first_smaller:
    mv s3 s0
    jal x0 output

pow_op:
    mv t0 s2
    li s3 1

pow_for:
    beq t0 x0 output
    mul s3 s0 s3
    addi t0 t0 -1
    jal x0 pow_for

fac_op:
    mv t0 s0
    li s3 1

fac_for:
    beq t0 x0 output
    mul s3 t0 s3
    addi t0 t0 -1
    jal x0 fac_for

#                                 #
###################################

output:
    # Output the result
    li a0, 1
    mv a1, s3
    ecall

exit:
    # Exit program(necessary)
    li a0, 10
    ecall

division_by_zero_except:
    li a0, 4
    la a1, division_by_zero
    ecall
    jal zero, exit
