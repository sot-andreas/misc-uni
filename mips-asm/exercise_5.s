    # 3212018215
    .data
array:  .word 0:9  # Declare an array of 10 integers
ask_msg:    .asciiz "Give integer "
usort_msg:  .asciiz "Unsorted array\n"
sort_msg:   .asciiz "Sorted array\n"

    .text
main:
    # Ask the user to insert the numbers of the array that should be sorted.
    move $s0, $zero             # Use $s0 as a pointer register. Init value: 0
    li $s1, 40                  # Save the array's size limit in $s1
    addi $s2, $zero, 1          # Array position counter, used for user output
loop_ins:
    # Print the "Give integer " string stored in ask_msg
    li $v0, 4                   # set $v0 to 4: print_string syscall code
    la $a0, ask_msg             # set $a0 to the address of the string
    syscall                     # perform the system call
    # Print the position of the array (starts from 1)
    li $v0, 1                   # set $v0 to 1: print_int syscall code
    move $a0, $s2               # set $a0 to the value of $s2
    syscall                     # perform the system call
    # Print the ": " characters
    li $v0, 11                  # set $v0 to 11: print_char syscall code
    addi $a0, $zero, ':'        # set $a0 to ':'
    syscall                     # perform the system call
    li $v0, 11                  # set $v0 to 11: print_char syscall code
    addi $a0, $zero, ' '        # set $a0 to ' '
    syscall                     # perform the system call
    # Read an integer from the user
    li $v0, 5                   # set $v0 to 5: read_int syscall code
    syscall                     # perform the system call
    sw $v0, array + 0($s0)      # Put the int read by the system in the array
    # Move pointers to the next position of the array and branch if needed
    addi $s0, $s0, 4            # Increase the pointer $s0 by 1 pos: 1 word = 4
    addi $s2, $s2, 1            # Increase the counter in $s2 by 1
    bne $s0, $s1, loop_ins      # While the pointer $s0 is not equal to the
                                # arrays size limit $s1 branch to loop_ins

    # Print the unsorted array
    li $v0, 4                   # set $v0 to 4: print_string syscall code
    la $a0, usort_msg           # set $a0 to the address of the string
    syscall                     # perform the system call
    la $a0, array               # load the address of the array in $a0
    move $a1, $s1               # load the array's size from #s1 in $a1
    jal print_int_array         # call the subrootine to print the array

    # Bubblesort
    addi $s3, $zero, $s1        # $s3 : loop limiter. Init value: The array size
bubblesort_1:
    addi $s4, $zero, $zero      # $s4 : next loop limiter. Init value: 0
    addi $s0, $zero, 1          # $s0 : loop counter. Init value: 1

    

    addi $t0, $zero, 1
    bgt $s3, $t0, bubblesort_1

    # Exit the program
    li $v0, 10                  # set $v0 to 10: exit syscall code
    syscall                     # perform the system call


# Xerw oti apla tha borousa na xrisimopoihsw to onoma array

# BEGIN print_int_array - Subrootine to print an array of integers
# arguments $a0 : address of the array
#           $a1 : the array's size limit
print_int_array:
    addiu $sp, $sp, -16         # allocate 4 words on the stack
    sw $ra, 12($sp)             # save $ra in the stack (3)
    sw $a0, 8($sp)              # save the array address in the stack (2)
    sw $a1, 4($sp)              # save the size in the stack (1)
    sw $zero, ($sp)             # use the last position of the stack as an
                                # array pointer. Init value: 0 (0)
print_int_array_loop:
    # Calculate the address of the next item in the array
    lw $t0, 8($sp)              # load the address of the array in $t0
    lw $t1, ($sp)               # load the array pointer in $t1
    addu $t0, $t1, $t0          # save the address of the next item in $t0
    # Load the item from the array and print it
    lw $a0, 0($t0)              # load the item from the array in $a0
    li $v0, 1                   # set $v0 to 1: print_int syscall code
    syscall                     # perform the system call
    # print a space character
    li $v0, 11                  # set $v0 to 11: print_char syscall code
    addi $a0, $zero, ' '        # set $a0 to ' '
    syscall                     # perform the system call
    # Move pointers to the next position of the array
    lw $t1, ($sp)               # load the array pointer in $t1
    addi $t1, $t1, 4            # increase the pointer by 1 pos: 1 word = 4
    sw $t1, ($sp)               # save the new pointer value back in the stack
    # If the array pointer is not equal to the array size then try to loop.
    lw $t0, 4($sp)              # load the array size in $t0
    bne $t0, $t1, print_int_array_loop

    lw $ra, 12($sp)             # reload $ra so we can return to caller
    addiu $sp, $sp, 16          # restore $sp, freeing the allocated space
    jr $ra                      # return to the caller
# END print_int_array
