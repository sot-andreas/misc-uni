    # 3212018215
    .data
intro_msg:  .asciiz "Calculation of the Greatest Common Divisor of two integers using Euclid's algorithm"
int1_msg:   .asciiz "\nEnter the first integer: "
int2_msg:   .asciiz "Enter the second integer: "
res_msg:    .asciiz "The Greatest Common Divisor is: "
zeros_msg:  .asciiz "Both numbers are 0s!!!"

    .text
main:
    li $v0, 4                   # set $v0 to 4: print_string syscall code
    la $a0, intro_msg           # set $a0 to the address of the string
    syscall                     # perform the system call
    
start:
    li $v0, 4                   # set $v0 to 4: print_string syscall code
    la $a0, int1_msg            # set $a0 to the address of the string
    syscall                     # perform the system call
    li $v0, 5                   # set $v0 to 5: read_int syscall code
    syscall                     # perform the system call
    add $s0, $v0, $zero         # set $s0 to the int read by the system call

    li $v0, 4                   # set $v0 to 4: print_string syscall code
    la $a0, int2_msg            # set $a0 to the address of the string
    syscall                     # perform the system call
    li $v0, 5                   # set $v0 to 5: read_int syscall code
    syscall                     # perform the system call
    add $s1, $v0, $zero         # set $s1 to the int read by the system call

    bgez $s0, skip1             # if $s0 >= 0 branch to skip1
    sub $s0, $zero, $s0         # $s0 = 0 - $s0. Subtract $s0 from 0.
skip1:

    bgez $s1, skip2             # if $s1 >= 0   branch to skip2
    sub $s1, $zero, $s1         # $s1 = 0 - $s1. Subtract $s1 from 0.
skip2:

    beqz $s0, first_is_zero     # if $s0 = 0 branch to first_is_zero 
    beqz $s1, result            # if $s1 = 0 branch to result
    j euclid                    # jump to euclid

first_is_zero:
    beqz $s1, both_are_zero     # if $s1 = 0 branch to both_are_zero
    add $s0, $s1, $zero         # set $s0 to the value of $s1 
    j result                    # jump to result
    
both_are_zero:
    li $v0, 4                   # set $v0 to 4: print_string syscall code
    la $a0, zeros_msg           # set $a0 to the address of the string
    syscall                     # perform the system call
    j start                     # jump to start
    
euclid:
    div $s0, $s1                # divide the value of $s0 by the value of $s1
    add $s0, $s1, $zero         # set $s0 to the value of $s1
    mfhi $s1                    # set $s1 to the remainder of the division
    bnez $s1, euclid            # if $s1 is not 0 branch to euclid

result:
    li $v0, 4                   # set $v0 to 4: print_string syscall code
    la $a0, res_msg             # set $a0 to the address of the string
    syscall                     # perform the system call
    li $v0, 1                   # set $v0 to 1: print_int syscall code
    add $a0, $s0, $zero         # set $a0 to the value of $s0
    syscall                     # perform the system call

    j start                     # jump to start
    
    # li $v0, 10
    # syscall
