.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  

    li t0, 0
    li t1, 0
    addi sp, sp, -4
    sw s0, 0(sp)

loop_start:
    bge t1, a2, loop_end

    slli t2, t1, 2
    add t2, t2, a0
    lw t2, 0(t2)

    

    beqz t1, mul_done2
    slli t3, a4, 2
    add s0, t3, s0
    lw t3, 0(s0)
    j mul_t3
mul_done2:
    lw t3, 0(a1)
    mv s0, a1
mul_t3:

    

    li t4, 0
    li t5, 0
    bltz t2, t2_neg
    j t2_checked
t2_neg:
    sub t2, x0, t2
    xori t5, t5, 1
t2_checked:

    bltz t3, t3_neg
    j t3_checked
t3_neg:
    sub t3, x0, t3
    xori t5, t5, 1
t3_checked:

    li t6, 0
mul_t2_t3_loop:
    beq t6, t3, mul_done3
    add t4, t4, t2
    addi t6, t6, 1
    j mul_t2_t3_loop
mul_done3:
    beq t5, x0, mul_end
    sub t4, x0, t4
mul_end:
    add t0, t0, t4
    addi t1, t1, 1
    j loop_start

loop_end:
    mv a0, t0
    lw s0, 0(sp)
    addi sp, sp, 4
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
