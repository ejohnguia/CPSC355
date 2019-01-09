/*
Ezra John Guia
30031697
Assignment 6
355 LEC - 02
Tutorial - T08
*/

//----------Strings----------//
header_str:     .string "|   Input Values   |   Cube Root:   |\n"      //Heading
values_str:     .string "   %.10f      %.10f   \n"       //Output of values
error_str:      .string "Error opening file.\nAborting.\n"  //Error massage

//----------Global Varibales----------//
	.data
e_m:        .double     0r1.0e-10
three_m:    .double     0r3.0


    .text
define(fd_r,        w19)
define(nread_r,     x20)
define(buf_base_r,  x21)
define(base_r,      x22)
define(argc_r,      w23)
define(argv_r,      x24)

define(x_r,     d8)
define(y_r,     d9)
define(dy_r,    d10)
define(dyx_r,   d11)
define(inp_r,   d12)
define(svdIn_r, d13)
define(rslt_r,  d14)
define(temp_r,  d15)

buf_size    =   8                       //Size of buffer
alloc       =   -(16 + buf_size) & -16  //Space to allocate
dealloc     =   -alloc                  //Deallocation size
buf_s       =   16                      //Buffer offset
AT_FDCWD    =   -100

fp	.req	x29			//Replaces x29/x30 with something more readable
lr	.req	x30

	.balign	4			//Ensures alignment
    .global main

//----------Main----------//
main:
	stp	fp,	lr,	[sp, alloc]!	//Allocates space
	mov	fp,	sp				    //Moves the stack pointer to the frame pointer

    mov     argc_r, w0      //Moves the number of args given
    mov     argv_r, x1      //Argumment array

    cmp     argc_r, 2       //Checks if the number of arguments given is 2
    b.eq    arg_okay        //Skips over if okay

//----------Error handling
error_handling:                         //Prints the error handling
    adrp	x0, error_str
    add     x0, x0, :lo12:error_str
    bl      printf
    b       end                         //Branches over to the end

//----------open file
arg_okay:
    mov     x0,     AT_FDCWD                    //Reading input from file
    ldr     x1,     [argv_r,    8]              //Place input string into x1
    mov     w2,     0                           //Read-only
    mov     w3,     0                           //Not used
    mov     x8,     56                          //Openat I\O request
    svc     0                                   //Call sys function
    mov     fd_r,   w0                          //Moves result into fd

    cmp     fd_r,   0           //If unsuccesful
    b.lt    error_handling      //branch to error handling

//----------read file
    adrp    x0,     header_str                  //Prints out the header
    add     x0,     x0,     :lo12:header_str
    bl      printf

    add     buf_base_r, x29,    buf_s           //Set base address of buffer

top:
    mov     w0,     fd_r        // 1st arg (fd)
    mov     x1,     buf_base_r  // 2nd arg (buf)
    mov     w2,     buf_size    // 3rd arg (n)
    mov     x8,     63          // read I/O request
    svc     0                   // call system function
	mov 	nread_r, x0 		// record # of bytes actually read

    cmp     nread_r, buf_size   //Checks if it matches the size of the buffer
    b.ne    close               //Moves on if okay

//----------Newton's Method call
    ldr     svdIn_r,    [buf_base_r]    //Loads the content of the buffer
    fmov    d0,         svdIn_r         //Transfer the content to an argument
    bl      newt_method                 //Branch links to Newton's method
    fmov    rslt_r,     d0              //Moves the result into a reg

//----------print result
    adrp    x0, values_str              //Prints out the value string
    add     x0, x0, :lo12:values_str    //Formats the bits
    fmov    d0, svdIn_r                 //Input placed in first
    fmov    d1, rslt_r                  //Cube root placed next
    bl      printf                      //Prints out

    b   top     //Restarts the loop

//----------close file
close:
    mov     w0, fd_r        //Closes the file
    mov     x8, 57
    svc     0

end:
    mov w0, 0
    ldp fp, lr, [sp], dealloc   //Deallocates space used
	ret                         //Returns

///////////////////////////////////////
//----------Newton's Method----------//
newt_method:
	stp	fp,	lr,	[sp, -16]!	//Allocates space
	mov	fp,	sp			    //Moves the stack pointer to the frame pointer

    fmov    inp_r,      d0      //Saves the input

    adrp    base_r,     three_m                     //Access the variable 3
    add     base_r,     base_r,     :lo12:three_m
    ldr     temp_r,     [base_r]                    //Place 3 in the temp reg

    //initial guess
    fdiv    x_r,    inp_r,      temp_r      // x = input / 3

    //calc x
    fmov    d0,     x_r     //Moves the x into an arg
    fmov    d1,     inp_r   //Moves the input into an arg
    bl      dy_function     //Call the dy function
    fmov    dy_r,    d0     //Moves the result into dy

    fmov    d0,     x_r     //Moves the x into an arg
    bl      dyx_function    //Call the dyx function
    fmov    dyx_r,   d0     //Moves the result into dy/dx

    fdiv    temp_r, dy_r,   dyx_r   // temp = dy / (dy/dx)
    fsub    x_r,    x_r,    temp_r  // x = x - temp

    b       newt_method_test    //First test the loop condition

newt_method_top:
    fmov    d0,     x_r     //Moves the x into an arg
    fmov    d1,     inp_r   //Moves the input into an arg
    bl      dy_function     //Call the dy function
    fmov    dy_r,    d0     //Moves the result into dy

    fmov    d0,     x_r     //Moves the x into an arg
    bl      dyx_function    //Calls the dyx function
    fmov    dyx_r,   d0     //Moves the result into dyx

    fdiv    temp_r, dy_r,   dyx_r       // temp = dy / (dy/dx)
    fsub    x_r,    x_r,    temp_r      // x = x - temp

newt_method_test:
    fmov    d0,     x_r     //Moves the x into an arg
    fmov    d1,     inp_r   //Moves the input into an arg
    bl      dy_function     //Call the dy function
    fmov    dy_r,   d0      //Moves the result into dy
    fabs    dy_r,   dy_r    //abs(dy)

    adrp    base_r,     e_m                     //Access the e variable
    add     base_r,     base_r,     :lo12:e_m
    ldr     temp_r,     [base_r]                //Place e into temp

    fmul    temp_r,     inp_r,      temp_r      // temp = input * e

    fcmp    dy_r,   temp_r      //Compares the abd(dy) to input*e
    b.gt    newt_method_top     //If dy > (input * e) loop again

    fmov d0, x_r                //Returns the result
    ldp fp, lr, [sp], 16   //Deallocates space used
	ret                         //Returns

//----------dy function----------//
dy_function:
	stp	fp,	lr,	[sp, -16]!	//Allocates space
	mov	fp,	sp			    //Moves the stack pointer to the frame pointer

    fmov    d30,    d0      //Grabs x
    fmov    d31,    d1      //Grabs input

    fmul    d16,    d30,    d30     // d16 = x * x
    fmul    d16,    d16,    d30     // d16 = x * x * x
    fsub    d0,    d16,    d31      // d0 = x * x * x - input

    ldp fp, lr, [sp], 16   //Deallocates space used
	ret                         //Returns

//----------dyx function----------//
dyx_function:
	stp	fp,	lr,	[sp, -16]!	//Allocates space
	mov	fp,	sp			    //Moves the stack pointer to the frame pointer

    fmov    d31,    d0              //Grabs the x
    adrp    base_r,     three_m     //Grabs the 3
    add     base_r,     base_r,     :lo12:three_m
    ldr     temp_r,     [base_r]    // temp = 3

    fmul    d16,    temp_r,     d31 //d16 = 3 * x
    fmul    d0,     d16,        d31 //d0 = 3 * x * x

    ldp fp, lr, [sp], 16   //Deallocates space used
	ret                         //Returns