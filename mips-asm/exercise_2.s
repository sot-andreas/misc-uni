    .data
msg:    .asciiz "Enter the number of Fibonacci sequence terms to print: "

    .text
main:   
    li $v0, 4               # set $v0 to 4: print_string syscall code
    la $a0, msg             # set $a0 to the address of the string
    syscall                 # perform the system call

    li $v0, 5               # set $v0 to 5: read_int syscall code
    syscall                 # perform the system call
    add $s3, $v0, $zero     # set $s3 to the int read by the system call
                            # this is the amount of fibonacci terms to print
    
    li $s0, 0               # set $s0 to 0
    li $s1, 1               # set $s1 to 1

fib:
    li $v0, 1               # set $v0 to 1: print_int syscall code
    add $a0, $s0, $zero     # set $a0 to the int in $s0 that we want printed
    syscall                 # perform the system call
    li $v0, 11              # set $v0 to 11: print_char syscall code
    li $a0, ' '             # set $a0 to the char ' ' that we want printed.
                            # in other words we print a space character.
    syscall                 # perform the system call
    add $s2, $s0, $s1       # set $s2 to the sum of $s0 and $s1
    add $s0, $s1, $zero     # set $s0 to the value of $s1
    add $s1, $s2, $zero     # set $s1 to the value of $s2
    addi $s3, $s3, -1       # set $s3 to $s3 - 1. Since $s3 is the amount of
                            # terms to print it will be used to control how many
                            # time we will loop.
    bgtz $s3, fib           # If $s3 > 0 branch to 'fib'

    li $v0, 10              # set $v0 to 10: exit syscall code
    syscall                 # perform the system call
