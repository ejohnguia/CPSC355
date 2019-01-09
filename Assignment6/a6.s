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

    mov     w23, w0      //Moves the number of args given
    mov     x24, x1      //Argumment array

    cmp     w23, 2       //Checks if the number of arguments given is 2
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
    ldr     x1,     [x24,    8]              //Place input string into x1
    mov     w2,     0                           //Read-only
    mov     w3,     0                           //Not used
    mov     x8,     56                          //Openat I\O request
    svc     0                                   //Call sys function
    mov     w19,   w0                          //Moves result into fd

    cmp     w19,   0           //If unsuccesful
    b.lt    error_handling      //branch to error handling

//----------read file
    adrp    x0,     header_str                  //Prints out the header
    add     x0,     x0,     :lo12:header_str
    bl      printf

    add     x21, x29,    buf_s           //Set base address of buffer

top:
    mov     w0,     w19        // 1st arg (fd)
    mov     x1,     x21  // 2nd arg (buf)
    mov     w2,     buf_size    // 3rd arg (n)
    mov     x8,     63          // read I/O request
    svc     0                   // call system function
	mov 	x20, x0 		// record # of bytes actually read

    cmp     x20, buf_size   //Checks if it matches the size of the buffer
    b.ne    close               //Moves on if okay

//----------Newton's Method call
    ldr     d13,    [x21]    //Loads the content of the buffer
    fmov    d0,         d13         //Transfer the content to an argument
    bl      newt_method                 //Branch links to Newton's method
    fmov    d14,     d0              //Moves the result into a reg

//----------print result
    adrp    x0, values_str              //Prints out the value string
    add     x0, x0, :lo12:values_str    //Formats the bits
    fmov    d0, d13                 //Input placed in first
    fmov    d1, d14                  //Cube root placed next
    bl      printf                      //Prints out

    b   top     //Restarts the loop

//----------close file
close:
    mov     w0, w19        //Closes the file
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

    fmov    d12,      d0      //Saves the input

    adrp    x22,     three_m                     //Access the variable 3
    add     x22,     x22,     :lo12:three_m
    ldr     d15,     [x22]                    //Place 3 in the temp reg

    //initial guess
    fdiv    d8,    d12,      d15      // x = input / 3

    //calc x
    fmov    d0,     d8     //Moves the x into an arg
    fmov    d1,     d12   //Moves the input into an arg
    bl      dy_function     //Call the dy function
    fmov    d10,    d0     //Moves the result into dy

    fmov    d0,     d8     //Moves the x into an arg
    bl      dyx_function    //Call the dyx function
    fmov    d11,   d0     //Moves the result into dy/dx

    fdiv    d15, d10,   d11   // temp = dy / (dy/dx)
    fsub    d8,    d8,    d15  // x = x - temp

    b       newt_method_test    //First test the loop condition

newt_method_top:
    fmov    d0,     d8     //Moves the x into an arg
    fmov    d1,     d12   //Moves the input into an arg
    bl      dy_function     //Call the dy function
    fmov    d10,    d0     //Moves the result into dy

    fmov    d0,     d8     //Moves the x into an arg
    bl      dyx_function    //Calls the dyx function
    fmov    d11,   d0     //Moves the result into dyx

    fdiv    d15, d10,   d11       // temp = dy / (dy/dx)
    fsub    d8,    d8,    d15      // x = x - temp

newt_method_test:
    fmov    d0,     d8     //Moves the x into an arg
    fmov    d1,     d12   //Moves the input into an arg
    bl      dy_function     //Call the dy function
    fmov    d10,   d0      //Moves the result into dy
    fabs    d10,   d10    //abs(dy)

    adrp    x22,     e_m                     //Access the e variable
    add     x22,     x22,     :lo12:e_m
    ldr     d15,     [x22]                //Place e into temp

    fmul    d15,     d12,      d15      // temp = input * e

    fcmp    d10,   d15      //Compares the abd(dy) to input*e
    b.gt    newt_method_top     //If dy > (input * e) loop again

    fmov d0, d8                //Returns the result
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
    adrp    x22,     three_m     //Grabs the 3
    add     x22,     x22,     :lo12:three_m
    ldr     d15,     [x22]    // temp = 3

    fmul    d16,    d15,     d31 //d16 = 3 * x
    fmul    d0,     d16,        d31 //d0 = 3 * x * x

    ldp fp, lr, [sp], 16   //Deallocates space used
	ret                         //Returns