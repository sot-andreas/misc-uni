    # 3212018215
    .data
sum:    .word 0     # The sum of every term
array:  .word 0:19  # Declare an array of 3 integers
init_msg:   .asciiz "Enter the initial term of the arithmetic progression: "
diff_msg:   .asciiz "Enter the common difference of the terms: "
sum_msg:    .asciiz "\nThe sum of the 20 first terms of the sequence is "
    .text
main:    
    # Ask the user for the first term of the arithmetic progression and save it
    # in the register $s0
    li $v0, 4                   # set $v0 to 4: print_string syscall code
    la $a0, init_msg            # set $a0 to the address of the string
    syscall                     # perform the system call
    li $v0, 5                   # set $v0 to 5: read_int syscall code
    syscall                     # perform the system call
    move $s0, $v0               # set $s0 to the int read by the system call

    # Ask the user for the common difference of the terms and save it in the
    # register $s1
    li $v0, 4                   # set $v0 to 4: print_string syscall code
    la $a0, diff_msg            # set $a0 to the address of the string
    syscall                     # perform the system call
    li $v0, 5                   # set $v0 to 5: read_int syscall code
    syscall                     # perform the system call
    move $s1, $v0               # set $s0 to the int read by the system call

    move $s2, $zero             # Use the register $s2 to save the sum. Set to 0
    move $t0, $zero             # Use $t0 as a pointer register. Init value: 0
    li $t1, 80                  # Save the array's size limit in $t1
loop_calc:
    add $s2, $s2, $s0           # Add the term to the sum.
    sw $s0, array + 0($t0)      # Put the term of the progression in the array
    add $s0, $s0, $s1           # Calculate the next term of the progression
    addi $t0, $t0, 4            # Increase the pointer $t0 by 1 pos: 1 word = 4
    bne $t0, $t1, loop_calc     # While the pointer $t0 is not equal to the
                                # arrays size limit $t1 branch to loop_calc

    sw $s2, sum                 # Store the sum in memory (in the sum variable)
    
    # The following uses the array's size limit saved in $t1 to traverse the
    # array backwards and print it's elements. $t1 now becomes the pointer to
    # current position of the array with 0 being the lower limit.
loop_prnt:
    addi $t1, $t1, -4       # Each element is 4 bytes long. $t1 points to
                            # the last byte of the current element, so we
                            # subtrack 4 to make it point to the start.
    lw $t0, array + 0($t1)  # Load the item from the array in $t0
    li $v0, 1               # set $v0 to 1: print_int syscall code
    move $a0, $t0           # set $a0 to the int in $t0 that we want printed
    syscall                 # perform the system call
    li $v0, 11              # set $v0 to 11: print_char syscall code
    li $a0, ' '             # set $a0 to the char ' ' that we want printed.
                            # in other words we print a space character.
    syscall                 # perform the system call
    bgtz $t1, loop_prnt     # While $t1 is great than 0 branch to loop_prnt

    li $v0, 4               # set $v0 to 4: print_string syscall code
    la $a0, sum_msg         # set $a0 to the address of the string
    syscall                 # perform the system call
    li $v0, 1               # set $v0 to 4: print_int syscall code
    lw $a0, sum             # set $a0 to the address of the sum
    syscall                 # perform the system call
    
    li $v0, 10              # set $v0 to 10: exit syscall code
    syscall                 # perform the system call
