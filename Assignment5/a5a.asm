/*
Ezra John Guia
30031697
Assignment 5
Assembly Source - a5a.asm
355 LEC - 02
Tutorial - T08
*/

	QUEUESIZE	=	8
	MODMASK		=	0x7
	FALSE		=	0
	TRUE		=	1

//----------Strings----------//
overS:		.string	"\nQueue overflow! Cannot enqueue into a full queue.\n"
underS:		.string	"\nQueue underflow! Cannot dequeue from an empty queue.\n"
emptyS:		.string "\nEmpty queue\n"
currentS:	.string "\nCurrent queue contents:\n"
contentS:	.string	"  %d"
headS:		.string	"<-- head of queue"
tailS:		.string	"<-- tail of queue"
newlineS:	.string	"\n"

//----------Global Varibales----------//
		.data
head:		.word	-1				//Allocates memory and initializes data
tail:		.word	-1

		.bss
queue:		.skip	QUEUESIZE * 4	//Allocates memory using the number and size of the element

		.text
define(base_r,	x28)				//Sets a register for the base address of the head/tail/queue
define(i_r,		w19)				//i index for the FOR LOOP in the display functiom
define(j_r,		w20)				//j index for the FOR LOOP in the display function
define(val_r,	w21)				//Value given
define(head_r,	w22)				//Head value
define(tail_r,	w23)				//Tail value
define(count_r,	w24)				//Count value

	fp	.req	x29			//Replaces x29/x30 with something more readable
	lr	.req	x30

		.balign	4			//Ensures alignment
		.global enqueue		//Makes all functions globally accessible
		.global dequeue
		.global queueFull
		.global queueEmpty
		.global display

//----------Start of functions----------//
//----------[enqueue]----------//
enqueue:
	stp	fp,	lr,	[sp, -16]!	//Allocates space
	mov	fp,	sp				//Moves the stack pointer to the frame pointer

	mov		val_r,	w0		//Moves argument into temp register
	bl		queueFull		//Checks if the queue is full
	cmp		w0,	TRUE		//Checks if it's true
	b.ne	notFull			//If not it skips to the next statament

	adrp	x0,	overS		//Prints the queueFull string
	add		x0,	x0,	:lo12:overS
	bl		printf
	b		enqueueEnd		//Skips to the end of the program to terminate

notFull:
	bl		queueEmpty		//Checks if the queue is empty
	cmp		w0,	TRUE
	b.ne	notEmptyElse	//If not empty skips to the next statement

	adrp	base_r,	head				//Calculates the address of the head
	add		base_r, base_r, :lo12:head	//Formats the bits
	str		xzr,	[base_r]			//Moves 0 to the head

	adrp	base_r,	tail				//Calculate tail address
	add		base_r, base_r, :lo12:tail	//Formats the bits
	str		xzr,	[base_r]			//Moves 0 to the tail
	b		skipEmptyElse				//Skips the else statement

notEmptyElse:
	adrp	base_r,	tail				//Calculate tail address
	add		base_r, base_r, :lo12:tail	//Formats the bits
	ldr		tail_r,	[base_r]			//Loads the current tail
	add		tail_r,	tail_r,	1			//Increments it
	and 	tail_r,	tail_r,	MODMASK		//Bitwise AND
	str		tail_r,	[base_r]			//Stores the result

skipEmptyElse:
	ldr		tail_r,	[base_r]					//Loads the tail
	adrp	base_r,	queue						//Calculate queue address
	add		base_r, base_r, :lo12:queue			//Formats the bits
	str		val_r,	[base_r, tail_r, SXTW 2]	//Stores the given value at the tail of the queue

enqueueEnd:
	ldp	fp,	lr,	[sp],	16	//Deallocates space
	ret						//Returns

//----------[dequeue]----------//
dequeue:
	stp	fp,	lr,	[sp, -16]!	//Allocates memory
	mov	fp,	sp				//Moves the stack pointer into the frame pointer

	bl		queueEmpty		//Branch and links to the queueEmpty function
	cmp		w0,	TRUE		//Checks if it's TRUE
	b.ne	queueNotEmpty	//If not TRUE, branches to the next statement

	adrp	x0,	underS				//Prints out the underS string
	add		x0,	x0,	:lo12:underS
	bl		printf
	mov		w0,	-1			//Passes -1 as argument
	b		dequeueEnd		//Skips to the end of the function

queueNotEmpty:
	adrp	base_r,	head					//Calculate head address
	add		base_r, base_r, :lo12:head
	ldr		head_r,	[base_r]				//Loads the head value

	adrp	base_r,	tail					//Calculate tail address
	add		base_r, base_r, :lo12:tail
	ldr		tail_r,	[base_r]				//Loads the value of the tail

	adrp	base_r,	queue						//Calculate queue address
	add		base_r, base_r, :lo12:queue
	ldr		val_r,	[base_r, head_r, SXTW 2]	//Loads the head in the queue into the saved register

	cmp		head_r,	tail_r				//Compares the head and tail
	b.ne	headTailNotEqual			//Branches over if not equal

	mov		w15,	-1					//Moves -1 to a temp register
	adrp	base_r,	head				//Calculate head address
	add		base_r, base_r, :lo12:head
	str		w15, [base_r]				//Stores -1 to the head

	adrp	base_r,	tail				//Calculate tail address
	add		base_r, base_r, :lo12:tail
	str		w15, [base_r]				//Stores -1 to the tail
	b		returnVal					//Branches to the end of the function

headTailNotEqual:
	add		head_r,	head_r,	1			//Increments the head
	and		head_r,	head_r,	MODMASK		//Bitwise AND
	adrp	base_r,	head				//Calculate head address
	add		base_r, base_r, :lo12:head
	str		head_r, [base_r]			//Stores the new head value

returnVal:
	mov		w0,	val_r		//Moves the value to the argument

dequeueEnd:
	ldp	fp,	lr,	[sp],	16	//Deallocates memory
	ret						//Returns

//----------[queueFull]----------//
queueFull:
	stp	fp,	lr,	[sp, -16]!	//Allocates memory
	mov	fp,	sp				//Moves the stack pointer to the frame pointer

	adrp	base_r,	tail			//Calculate tail address
	add		base_r, base_r, :lo12:tail
	ldr		tail_r,	[base_r]		//Loads the current tail to a temp reg
	add		tail_r,	tail_r,	1		//Increments it
	and 	tail_r,	tail_r,	MODMASK	//Bitwise AND

	adrp	base_r,	head		//Calculate head address
	add		base_r, base_r, :lo12:head
	ldr		head_r,	[base_r]	//Loads the head to a temp reg
	
	mov		w0,	TRUE		//Initializes the argument to TRUE
	cmp		tail_r,	head_r	//Compares the head and tail
	b.eq	queueFullEnd	//If they are equal go to the end of the function
	mov		w0,	FALSE		//If the statement was false, FALSE is passed as the argument

queueFullEnd:
	ldp	fp,	lr,	[sp],	16	//Deallocates memory
	ret						//Returns

//----------[queueEmpty]----------//
queueEmpty:
	stp	fp,	lr,	[sp, -16]!	//Allocates memory
	mov	fp,	sp				//Moves the stack pointer to the frame pointer

	adrp	base_r,	head		//Calculate head address
	add		base_r, base_r, :lo12:head
	ldr		head_r,	[base_r]	//Loads the head into a temp reg
	
	mov		w0,	TRUE			//TRUE is initially the argument
	cmp		head_r,	-1			//Compares the head to -1
	b.eq	queueEmptyEnd		//Goes to the end of the program if equal
	mov		w0,	FALSE			//If false, FALSE overwrites the argument

queueEmptyEnd:
	ldp	fp,	lr,	[sp],	16	//Deallocates memory
	ret						//Returns

//----------[display]----------//
display:
	stp	fp,	lr,	[sp, -16]!	//Allocates memory
	mov	fp,	sp				//Moves the stack pointer to the frame pointer

	bl		queueEmpty	//Branches to check if the queue is empty
	cmp		w0,	TRUE	//Checks if it is TRUE
	b.ne	notEmpty	//Skips the next block if FALSE

	adrp	x0,	emptyS				//Prints the emptyS string
	add		x0,	x0,	:lo12:emptyS	//Formats the bits
	bl		printf
	b		displayEnd				//Branches to the end of the program

notEmpty:
	adrp	base_r,	head			//Calculate head address
	add		base_r, base_r, :lo12:head
	ldr		head_r,	[base_r]		//Loads the head

	adrp	base_r,	tail		//Calculate tail address
	add		base_r, base_r, :lo12:tail
	ldr		tail_r,	[base_r]	//Loads the tail

	sub		count_r,	tail_r,	head_r	//count = tail - head
	add		count_r,	count_r,	1	//count++

	cmp		count_r,	wzr						//Compares count to 0
	b.gt	skipCount							//If count > 0, skip
	add		count_r,	count_r,	QUEUESIZE	//Adds QUEUESIZE to the current count

skipCount:
	adrp	x0,	currentS			//Prints the header string
	add		x0,	x0,	:lo12:currentS
	bl		printf

	mov		i_r,	head_r	//Move the head value to the i index
	mov		j_r,	wzr		//Initializes j to 0		
	b		loopTest		//Branch to the bottom loop test

topLoop:
	adrp	x0,	contentS				//Prints the content of the queue
	add		x0,	x0,	:lo12:contentS
	adrp	base_r,	queue				//Calculate queue address
	add		base_r, base_r, :lo12:queue
	ldr		w1,	[base_r, i_r, SXTW 2]	//Loads the content at the index i
	bl		printf

	cmp		i_r,	head_r		//Compares the head to i
	b.ne	skipHead			//Skips if it's not the head	

	adrp	x0,	headS			//Prints the head label
	add		x0,	x0,	:lo12:headS
	bl		printf

skipHead:
	cmp		i_r,	tail_r		//Compares i to the tail
	b.ne	skipTail			//Skips if it's not the tail

	adrp	x0,	tailS			//Prints the tail footer
	add		x0,	x0,	:lo12:tailS
	bl		printf

skipTail:
	adrp	x0,	newlineS			//Prints the newline
	add		x0,	x0,	:lo12:newlineS
	bl		printf

	add		i_r,	i_r,	1		//Increments i
	and		i_r,	i_r,	MODMASK	//Bitwise AND with the MODMASK

	add		j_r,	j_r,	1		//Increments j

loopTest:
	cmp		j_r,	count_r	//Compares the j index to count
	b.lt	topLoop			//If j < count loop back

displayEnd:
	ldp	fp,	lr,	[sp],	16	//Deallocates memory
	ret						//Returns