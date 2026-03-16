
###########################
# Nagham Maali - 1212312
# section 2
###########################
#################################################################################
# Clique Detection Program #
# brute-force approach to find maximum clique set of 5x5 adjacency graph_matrix
#################################################################################

.data  #section to store all variables , strings and buffers
filenameMSG : .asciiz "Enter input file path (.txt): "  #prompt user to enter file path (like:C:\Users\User\Desktop\Arch\Project1\input.txt)
file_error : .asciiz "\nError: Cannot open file or file not found!\n"  #error message if file not found
invalid_error : .asciiz "\nError: Invalid adjacency matrix! only 0 or 1 allowed.\n"  #error message if matrix contains invalid characters(not 0 or 1)
size_error : .asciiz "\nError: Invalid size! graph must be 5x5 (5 rows , 5 columns).\n"  #error message if matrix size != 5x5
filecontentMSG : .asciiz "\nFile contents:\n"  #message for printing the graph_matrix
buffer : .space 1024  #buffer for file data: temporary storage for file data
filename : .space 128  #storage for user-entered filename 
newline : .asciiz "\n"  #newline character for printing
finish : .asciiz "\nThank you for using the program!\n"  #exit message
output_file_name : .asciiz "output.txt"  #name of output file
output_buffer : .space 256  #buffer to store output text before writing to file
max_clique_size_msg : .asciiz "Maximum clique size: "  #message for printing max clique size
vertices_msg : .asciiz "Vertices in maximum clique: "  #message for printing clique vertecies
ResultsOnTheFile : .asciiz "\nThe results are Printed to the output file\n"  #confirmation message
graph_matrix : .byte 0:25  # 5x5 matrix as bytes: 5x5 graph stored as 25 bytes (all initialized to 0)

# Maximum clique results:
max_clique_size : .word 0  #store maximum clique size
max_clique_mask : .word 0  #store subset mask of vertices forming max clique

#.asciiz defines a null-terminated ASCII string in memory, used so MIPS syscalls like print_string know where the string ends.#

.text  #instructions section
.globl main

main :
    # ----------------------
    #      File Input
    # ----------------------
    la $a0 , filenameMSG  #load address of prompt string into register $a0
    li $v0 , 4  #syscall code = 4 : print string
    syscall  #execute print
    la $a0 , filename  #load address of filename buffer into $a0
    li $a1 , 128  #set max number of characters to read
    li $v0 , 8 #syscall code = 8 : read string
    syscall #execute read string from user input

    jal cleanString  #call function to remove newline from filename

    la $a0 , filename  #load filename into $a0 for opening
    li $a1 , 0  #mode 0 : read only
    li $v0 , 13  #syscall code = 13 : open file
    syscall  #execut open file
    bltz $v0 , file_not_found  #if file descriptor < 0, jump to error
    move $s0 , $v0  #save file descriptor in $s0(file descriptor is a number the operating system gives a program to identify and access an open file)
    move $a0 , $s0  #file descriptor as argument
    la $a1 , buffer  #buffer to store file contents
    li $a2 , 1024  #maximum bytes to read
    li $v0 , 14  #syscall code = 14 : read file
    syscall  #read from file
    blez $v0 , file_not_found  #if file is empty(no bytes read) , jump to error
    move $s2 , $v0  #save number of bytes read
    la $t0 , buffer  #load buffer address
    add $t0 , $t0 , $s2  #move to end of read data
    sb $zero , 0($t0)  #append null terminator at end of buffer
    move $a0 , $s0  #close file descriptor
    li $v0 , 16  #syscall code = 16 : close file
    syscall  #close input file

    # -----------------------
    #    Validate Contents   
    # -----------------------
    la $t0 , buffer  #pointer to buffer start
    move $t3 , $s2  #bytes left to validate : counter

validate_loop :
    beqz $t3 , validate_done  #if counter = 0(if no bytes left) , done validation
    lb $t1 , 0($t0)  #load one byte from buffer
    
    #if '0', valid:
    li $t2 , '0' 
    beq $t1 , $t2 , valid_char 
    
     #if '1', valid
    li $t2 , '1'
    beq $t1 , $t2 , valid_char
    
     #if space ' ', valid
    li $t2 , ' '
    beq $t1 , $t2 , valid_char
    
     #if newline'\n', valid
    li $t2 , 10
    beq $t1 , $t2 , valid_char
    
    #if carriage '\r' return , valid
    li $t2 , 13
    beq $t1 , $t2 , valid_char
    
    j invalid_matrix  #otherwise , invalid

valid_char :
    addi $t0 , $t0 , 1  #move to next char in the file buffer
    addi $t3 , $t3 , -1  #decrement counter
    j validate_loop  #Jump back to the start of the validation loop to process the next character
    #$t0 points to the next byte and $t3 is a counter tracks how many characters are left to check#

validate_done :
    # ------------------------
    #     Check Size = 5x5
    # ------------------------
    la $t0 , buffer  #load address of the input file buffer (start of the matrix data)
    li $t4 , 0     #row counter
    li $t5 , 0     #column counter
    
count_rows_cols :
    lb $t1 , 0($t0)  #load current character (byte) from buffer into $t1
    beqz $t1 , check_last_row  #if character = 0 (end of file/string), jump to final check

    li $t2 , '0'  #load ASCII value of '0' into $t2
    beq $t1 , $t2 , count_entry  #if current char is '0', count it as a matrix entry

    li $t2 , '1'  #load ASCII value of '1' into $t2
    beq $t1 , $t2 , count_entry  #if current char is '1', count it as a matrix entry

    li $t2 , 10  #load ASCII 10 = newline ('\n') into $t2
    beq $t1 , $t2 , new_row  #if newline, a new row starts

    li $t2 , 13  #load ASCII 13 = carriage return ('\r') into $t2
    beq $t1 , $t2 , skip_char  #if carriage return, skip it

    addi $t0 , $t0 , 1  #move to next character if it's none of the above
    j count_rows_cols  #jump back and continue scanning

count_entry :
    addi $t5 , $t5 , 1  #increment column counter 
    addi $t0 , $t0 , 1  #move to next character in buffer
    j count_rows_cols  #continue reading

new_row :
    li $t6 , 5   #load expected number of columns (5)
    bne $t5 , $t6 , invalid_size  #if current row doesn't have exactly 5 columns , invalid matrix
    addi $t4 , $t4 , 1  #increment row counter (finished one row)
    li $t5 , 0  #reset column counter for next row
    addi $t0 , $t0 , 1  #move to next character after newline
    j count_rows_cols  #continue reading next row

skip_char :
    addi $t0 , $t0 , 1  #skip carriage return character and move on
    j count_rows_cols  #go back to keep reading

check_last_row :
    beqz $t5 , after_size_check  #if last row is empty, skip final validation
    li $t6 , 5  #expected columns = 5
    bne $t5 , $t6 , invalid_size  #if last row doesn't have 5 entries , invalid matrix
    addi $t4 , $t4 , 1  #count the final row as valid

after_size_check :
    li $t6 , 5  #expected total rows = 5
    bne $t4 , $t6 , invalid_size  #if number of rows ? 5 ? invalid matrix

    # --------------------------
    #     Print File Contents
    # --------------------------
    la $a0 , filecontentMSG  #load the address of the message "File contents:" into $a0
    li $v0 , 4  #syscall code = 4 : print string
    syscall  #print "File contents:"

    la $a0 , buffer  #load the address of the file buffer (contains the matrix text)
    li $v0 , 4  #syscall code = 4 : print string 
    syscall  #execute print (print the actual contents of the file)

    # ----------------------------
    #    Build graph_matrix 0/1
    # ----------------------------
    la $t0 , buffer  #load the address of the buffer (start reading characters)
    la $t7 , graph_matrix  #load address of graph_matrix (where to store 0/1 values)
    li $t8 , 0  #initialize counter (counts how many values we've stored, 0..24)

parse_loop :
    li $t9 , 25  #expected total entries = 5x5 = 25
    bge $t8 , $t9 , parse_done  #if counter >= 25, we're done parsing
    lb $t1 , 0($t0)  #load current character from buffer into $t1
    beqz $t1 , parse_done  #if null terminator (end of file), stop parsing
    li $t2 , '0'  #load ASCII code for '0'
    beq $t1 , $t2 , store_zero   #if current char = '0', go store a zero
    li $t2 , '1'  #load ASCII code for '1'
    beq $t1 , $t2 , store_one  #if current char = '1', go store a one
    addi $t0 , $t0 , 1  #otherwise skip this character (like space or newline)
    j parse_loop  #continue looping

store_zero :
    sb $zero , 0($t7)  #store 0 (in binary) into graph_matrix
    addi $t7 , $t7 , 1  #move to next byte in graph_matrix
    addi $t0 , $t0 , 1  #move to next character in buffer
    addi $t8 , $t8 , 1  #increment counter (stored one entry)
    j parse_loop  #go back to continue parsing

store_one :
    li $t3 , 1  #load the integer 1 into $t3
    sb $t3 , 0($t7)  #store 1 into graph_matrix
    addi $t7 , $t7 , 1  #move to next byte in graph_matrix
    addi $t0 , $t0 , 1  #move to next character in buffer
    addi $t8 , $t8 , 1  #increment counter (stored one entry)
    j parse_loop  #go back and continue reading the buffer

parse_done :
    # ---------------------------------------------------
    #    Find Maximum Clique using Brute-Force (1..31)
    # ---------------------------------------------------

    li $t0 , 1  #initialize subset mask = 1 (start from subset 00001)
    li $t1 , 31  #maximum subset mask = 31 (11111b) for 5 vertices
    li $t2 , 0  #store current maximum clique size
    li $t3 , 0  #store mask (combination) of the best clique found

subset_loop :
    bgt $t0 , $t1 , subset_done  #if subset mask > 31, all subsets checked , then done

    #-------- Count number of bits in subset (number of vertices selected) --------
    move $t4 , $t0  #copy current subset mask into $t4 for counting
    li $t5 , 0  #initialize bit counter = 0

count_bits :
    beqz $t4 , bits_done  #if no bits left (t4 == 0), done counting
    andi $t6 , $t4 , 1  #extract least significant bit (LSB)
    beqz $t6 , skip_inc  #if bit = 0, skip increment
    addi $t5 , $t5 , 1  #if bit = 1, increment bit counter

skip_inc :
    srl $t4 , $t4 , 1  #shift right by 1(move to next bit)
    j count_bits  #repeat until all bits are counted

bits_done :
    #-------- Check if current subset forms a valid clique --------
    move $t7 , $t0  #copy subset mask into $t7 (vertices included in subset)
    li $t8 , 0  #i = 0 (outer loop over all vertices)

clique_outer :
    bge $t8 , 5 , clique_ok  #if i >= 5 , checked all vertices , then subset is valid so far
    li $t9 , 1  #load bit mask 00001
    sllv $t9 , $t9 , $t8  #shift it left by i (now bit position i = 1)
    and $t9 , $t7 , $t9  #check if vertex i is included in subset
    beqz $t9 , next_i  #if vertex i not in subset , skip to next vertex
    li $s1 , 0  #j = 0 (inner loop for pair checking)

clique_inner :
    bge $s1 , 5 , next_i  #if j >= 5 , done checking all pairs for vertex i
    beq $s1 , $t8 , skip_j  #skip checking vertex with itself (i == j)
    li $s2 , 1  #load bit mask 00001
    sllv $s2 , $s2 , $s1  #shift left by j (bit position j = 1)
    and $s2 , $s2 , $t7  #check if vertex j is in subset
    beqz $s2 , skip_j  #if vertex j not in subset , skip

    #-------- Check if i and j are connected in graph_matrix --------
    mul $s3 , $t8 , 5  #compute index = i * 5
    add $s3 , $s3 , $s1  #index = i * 5 + j
    la $s4 , graph_matrix  #load address of adjacency matrix
    add $s4 , $s4 , $s3  #move to graph_matrix[i][j]
    lb $s5 , 0($s4)  #load value (0 or 1) from matrix
    beqz $s5 , not_clique  #if graph_matrix[i][j] == 0 , not connected , then not clique

skip_j :
    addi $s1 , $s1 , 1  #j++
    j clique_inner  #continue inner loop

next_i :
    addi $t8 , $t8 , 1  #i++
    j clique_outer  #continue outer loop

clique_ok :
    bge $t5 , $t2 , update_best  #if current clique size ? max size, update best result
    j next_subset  #otherwise, continue with next subset

update_best :
    move $t2 , $t5  #update max size = current size
    move $t3 , $t0  #save subset mask as best clique

next_subset :
    addi $t0 , $t0 , 1  #move to next subset mask
    j subset_loop  #repeat for next subset

not_clique :
    addi $t0 , $t0 , 1  #if not a clique ? move to next subset
    j subset_loop  #continue brute-force search

subset_done :
    sw $t2 , max_clique_size  #store the largest clique size found into memory
    sw $t3 , max_clique_mask  #store the bitmask representing vertices of max clique

    # --------------------------------------------
    #     Print Max Clique Results To Terminal
    # --------------------------------------------

    #print newline:
    la $a0 , newline  #load address of newline string
    li $v0 , 4   #syscall code = 4 : print string 
    syscall  #execute print

    #print "Maximum clique size: ":
    la $a0 , max_clique_size_msg  #load message text
    li $v0 , 4  #syscall code = 4 : print string 
    syscall  #execute print

    #print the size value:
    lw $a0 , max_clique_size  #load the integer size into $a0
    li $v0 , 1  #syscall code = 1 : print integer                    
    syscall  #execute print

    #print newline:
    la $a0 , newline  #load address of newline string
    li $v0 , 4  #syscall code = 4 : print string
    syscall  #execute print

    #print "Vertices in maximum clique: ":
    la $a0 , vertices_msg  #load message text
    li $v0 , 4  #syscall code = 4 : print string
    syscall  #execute print

    #print vertex numbers (the vertices forming the maximum clique):
    lw $t0 , max_clique_mask  #load clique bitmask
    li $t1 , 0  #vertex index = 0

print_vertices_loop_term :
    bge $t1 , 5 , print_vertices_done_term  #if vertex index >= 5, stop loop
    li $t2 , 1  #load 1 into $t2
    sllv $t2 , $t2 , $t1  #shift left (1 << vertex index)
    and $t3 , $t0 , $t2  #check if this vertex is part of clique
    beqz $t3 , skip_vertex_term  #if bit = 0, skip printing
    move $a0 , $t1  #move vertex number into $a0
    li $v0 , 1  #syscall code = 1 : print integer                    
    syscall  #execute print
    li $a0 , 32  #space (' ')
    li $v0 , 11  #syscall code = 11 : print character
    syscall  #execute print

skip_vertex_term :
    addi $t1 , $t1 , 1  #move to next vertex index
    j print_vertices_loop_term  #repeat

print_vertices_done_term :
    la $a0 , newline  #print newline after vertex list
    li $v0 , 4  #syscall code = 4 : print string
    syscall  #execute print

    # ------------------------------------
    #     Write Results To Output File 
    # ------------------------------------

    #-------- open (create if not created) output file for writing(in the same folder where the excusable jar file Mars4-5 exists) --------
    la $a0 , output_file_name  #load file name
    li $a1 , 1  #mode 1 : write only
    li $a2 , 438  #permissions = 0o666 in octal and 438 in decimal (set the file's permissions bits = rw-rw-rw- so everyone can read and write to it)
    li $v0 , 13  #syscall code = 13 : open file
    syscall  #execut open file
    bltz $v0 , exit_program  #if return value < 0, error opening file
    move $s6 , $v0  #save file descriptor to $s6

    #build output buffer:
    la $t0 , output_buffer  #$t0 points to buffer start

    #write "Maximum clique size: " message into buffer:
    la $t1 , max_clique_size_msg  #load message

write_size_msg :
    lb $t2 , 0($t1)  #load byte from message
    beqz $t2 , write_size_done  #stop when null terminator found
    sb $t2 , 0($t0)  #store byte into output buffer
    addi $t0 , $t0 , 1  #move buffer pointer
    addi $t1 , $t1 , 1  #move message pointer
    j write_size_msg  #continue copying

write_size_done :
    #write size as ASCII (single digit)#
    lw $t2 , max_clique_size  #load clique size (integer)
    addi $t2 , $t2 , 48  #convert to ASCII ('0' = 48)
    sb $t2 , 0($t0)  #store ASCII digit into buffer
    addi $t0 , $t0 , 1  #move buffer pointer
    li $t3 , 10  #load the ASCII code for newline ('\n') into register $t3  
    sb $t3 , 0($t0)  #store that newline character at the current memory address pointed to by $t0  
    addi $t0 , $t0 , 1  #move the pointer $t0 ahead by one byte to prepare for the next character
    la $t1 , vertices_msg  #write "Vertices in maximum clique: " message

write_vertices_msg :
    lb $t2 , 0($t1)  #load one byte (character) from the message string into $t2
    beqz $t2 , write_vertices_done  #if it's zero (end of string), jump to write_vertices_done
    sb $t2 , 0($t0)  #otherwise, store that character into the output buffer
    addi $t0 , $t0 , 1  #move buffer pointer forward by one byte
    addi $t1 , $t1 , 1  #move to next character in the message string
    j write_vertices_msg  #repeat until the full string is copied

write_vertices_done :
    #write vertex numbers separated by spaces#
    lw $t4 , max_clique_mask  #load the bitmask that represents which vertices are in the max clique
    li $t5 , 0  #initialize vertex index (0�4)

write_vertex_loop :
    bge $t5 , 5 , write_end  #if all 5 vertices checked, jump to write_end
    li $t6 , 1  #load 1 for masking
    sllv $t6 , $t6 , $t5  #shift left to create mask for current vertex (1 << vertex index)
    and $t7 , $t4 , $t6  #check if that vertex bit is set in the clique mask
    beqz $t7 , skip_vertex_file  #if bit = 0 (not part of clique), skip writing it
    addi $t8 , $t5 , 0  #copy vertex index number to $t8
    addi $t8 , $t8 , 48  #convert number to ASCII (0 : '0', 1 : '1', etc.)
    sb $t8 , 0($t0)  #store that ASCII character in the output buffer
    addi $t0 , $t0 , 1  #move to next byte in buffer
    li $t8 , 32  #load ASCII value for space (' ')
    sb $t8 , 0($t0)  #add a space after the vertex number
    addi $t0 , $t0 , 1  #move buffer pointer ahead again

skip_vertex_file :
    addi $t5 , $t5 , 1  #go to next vertex index
    j write_vertex_loop  #repeat for all vertices

write_end :
    #add newline character at end of file:
    li $t8 , 10  #load ASCII code for newline ('\n')
    sb $t8 , 0($t0)  #store newline into the buffer
    addi $t0 , $t0 , 1  #move buffer pointer to next byte

    #compute number of bytes to write: 
    la $a1 , output_buffer  #load address of buffer into $a1
    sub $a2 , $t0 , $a1  #a2 = length of data 
    move $a0 , $s6  #a0 = file descriptor 
    li $v0 , 15  #syscall code = 15 : write to file
    syscall  #write buffer to output file

    #close the output file:
    move $a0 , $s6  #a0 = file descriptor
    li $v0 , 16  #syscall code = 16 : close file
    syscall  #close the file properly

    #print confirmation message on terminal:
    la $a0 , ResultsOnTheFile  #load message string ("Results saved to file")
    li $v0 , 4  #syscall code = 4 : print string
    syscall  #display the message on screen

    j exit_program  #jump to exit section to end program

# -------------------------------------
#     Clean String (remove newline)
# -------------------------------------
cleanString :
    la $t0 , filename  #load the address of the filename string into $t0

clean_loop :
    lb $t1 , 0($t0)  #load one character (byte) from filename into $t1
    beqz $t1 , clean_done  #if the character is zero (end of string), stop cleaning
    li $t2 , 10  #load ASCII code 10 = newline ('\n')
    beq $t1 , $t2 , replace  #if current char is newline, jump to replace it
    addi $t0 , $t0 , 1  #otherwise move to next character in the string
    j clean_loop  #repeat for all characters

replace :
    sb $zero , 0($t0)  #replace the newline with null terminator (end of string)

clean_done :
    jr $ra  #return to caller (end of cleanString function)

# ----------------------
#     ERROR HANDLING    
# ----------------------
file_not_found :
    la $a0 , file_error  #load address of "file not found" error message
    li $v0 , 4  #syscall code = 4 : print string
    syscall  #print the error message
    j exit_program  #jump to program exit

invalid_matrix :
    la $a0 , invalid_error  #load address of "invalid matrix" error message
    li $v0 , 4  #syscall code = 4 : print string
    syscall  #print the message
    j exit_program  #jump to program exit

invalid_size :
    la $a0 , size_error  #load address of "invalid size" error message
    li $v0 , 4  #syscall code = 4 : print string
    syscall  #print the message
    j exit_program  #jump to program exit

# --------------------
#     EXIT PROGRAM    
# --------------------
exit_program :
    la $a0 , finish  #load address of the "program finished" message
    li $v0 , 4  #syscall code = 4 : print string
    syscall  #print the finish message
    li $v0 , 10  #syscall code = 10 : exit
    syscall  #end the program
