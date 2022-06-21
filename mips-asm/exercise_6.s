    # 3212018215
    .data
array:    .word 0:9  # Declare an array of 10 integers
ask_temp_msg:    .asciiz "Enter temperature "
ask_sum_msg:    .asciiz "Enter sum: "
ret_msg1:    .asciiz "Average temperature per "
ret_msg2:    .asciiz " years: "

    .text
main:
    # Ask the user to insert the numbers of the array that should be sorted.
    move $s0, $zero             # Use $s0 as a pointer register. Init value: 0
    li $s1, 40                  # Save the array's size limit in $s1
    addi $s2, $zero, 1          # Array position counter, used for user output
loop_ins:
    # Print the "Give temperature " string stored in ask_msg
    li $v0, 4                   # set $v0 to 4: print_string syscall code
    la $a0, ask_temp_msg             # set $a0 to the address of the string
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
                                # arrays size limit $s1 branch to loop_in

    # Ask the user to enter the temperature sum number k
    li $v0, 4                   # set $v0 to 4: print_string syscall code
    la $a0, ask_sum_msg         # set $a0 to the address of the string
    syscall
    # Read an integer from the user and save it to the register $s2
    li $v0, 5                   # set $v0 to 5: read_int syscall code
    syscall                     # perform the system call
    move $s2, $v0               # set $s0 to the int read by the system call

    # Display the return message
    li $v0, 4                   # set $v0 to 4: print_string syscall code
    la $a0, ret_msg1            # set $a0 to the address of the string
    syscall                     # perform the system call
    li $v0, 1                   # set $v0 to 1: print_int syscall code
    move $a0, $s2               # set $a0 to the value of $s2
    syscall                     # perform the system call
    li $v0, 4                   # set $v0 to 4: print_string syscall code
    la $a0, ret_msg2            # set $a0 to the address of the string
    syscall                     # perform the system call

    # Calculate the average temperatures per k years.
    move $s0, $zero             # Use $s0 as a pointer register. Init value: 0
    move $s3, $zero             # Use $s3 as a counter
    li $s4, 11                  # Set $s4 to 9. Total array positions (from 0)
    sub $s4, $s4, $s2           # Set $s4 to the max number of iterations
loop_avg:
    move $a0, $s0               # Set the first arg to the current array pointer
    move $a1, $s2               # Set the second arg to the avg temp sum number
    jal calc                    # Call the subroutine calc
    # Print the average
    li $v0, 2                   # set $v0 to 2: print_float syscall code

    syscall                     # perform the system call
    # Print the " " character
    li $v0, 11                  # set $v0 to 11: print_char syscall code
    addi $a0, $zero, ' '        # set $a0 to ' '
    syscall                     # perform the system call
    # Move pointer to the next position of the array and branch if needed
    addi $s0, $s0, 4            # Increase the pointer $s0 by 1 pos: 1 word = 4
    addi $s3, $s3, 1            # Increment the counter $s3 by 1
    bne $s3, $s4, loop_avg      # While the counter $s3 is not equal to the
                                # max iterations number $s4, branch to loop_avg

    # Exit the program
    li $v0, 10                  # set $v0 to 10: exit syscall code
    syscall                     # perform the system call


calc:
    move $t0, $zero             # Set the sum register $t0 to 0
    move $t2, $zero             # Use $t2 as a pointer register. Init value: 0
calc_loop:
    lw $t1, array + 0($a0)      # Load the item from the array in $t1
    add $t0, $t0, $t1           # Add the value in $t1 to the sum $t0
    addi $a0, $a0, 4            # Increment the array pointer #a0 by 4
    addi $t2, $t2, 1            # Increment the array counter #t2 by 1
    bne $t2, $a1, calc_loop     # While $t2 != $a1 branch to calc_loop

    mtc1 $t0, $f0               # Move the value of $t0 in $f0
    cvt.s.w $f0, $f0            # Make the number in $f0 a float
    mtc1 $a1, $f1               # Move the value of $t1 in $f1
    cvt.s.w $f1, $f1            # Make the number in $f1 a float

    div.s $f12, $f0, $f1        # Divide $f0 by $f1 and save the result in $f12
    jr $ra                      # return
