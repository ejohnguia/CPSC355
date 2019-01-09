/*
Ezra John Guia
30031697
Assignment 3
355 LEC - 02
Tutorial - T08
*/

title:	.string "\nSorted array:\n"	//prints out the title
array:	.string "v[%d]: %d\n"		//prints out the array
	
	//Integer macros
			//index of i
			//index of j
		//reg with the base of the array
			//temporary register

	indexSize=	4		//Size of the element in the array
	size	=	50		//Array size
	iaSize	=	size	*	indexSize	//Allocation size
	alloc	=	-(16 + 16 + size) & -16		//Pre-increment value
	dealloc	=	-alloc				//Post-increment value

	i_s	=	16	//Offset i to 16
	j_s	=	20	//Offset j to 20
	temp_s	=	24	//Offset min to 24
	ia_s	=	28	//Offset base to 28

	fp	.req	x29
	lr	.req	x30

	.balign	4
	.global main

main:	stp	x29,	x30,	[sp,	alloc]!	//Save FP and LR to stack allocating from alloc
	mov	fp,	sp			//Update frame pointer

	mov	x23,	fp		//Base address
	add	x23,	x23,	ia_s	//Location of base of array

	//Initialize array to random positive integers, mod 256
	mov	w19,	0			//Index to 0
	str	w19,	[fp,	i_s]		//Index to stack
	b	testI				//Branch to test

initPI:	ldr	w19,	[fp,i_s]		//Load from memory

	bl	rand				//Random number
	and	w0,	w0,	0xFF		//NUmber btw 0-255
	str	w0,	[x23,	w19,	SXTW 2]	//Store from w0

	ldr	w24,	[x23,	w19,	SXTW 2]	//Read from v[i]

	adrp	x0,	array			//Prints out
	add	x0,	x0,	:lo12:array
	mov	w1,	w19
	mov	w2,	w24	
	bl	printf

	ldr	w19,	[fp,	i_s]		//Get index i value
	add	w19,	w19,	1		//Increment
	str	w19,	[fp,	i_s]		//Store new i

testI:	cmp	w19,	size			//Checks for loop
	b.lt	initPI

	adrp	x0,	title			//Prints out title
	add	w0,	w0,	:lo12:title
	bl	printf

	//Sort the array using an insertion sort
	mov	w19,	0			//Set to 0
	str	w19,	[fp,	i_s]		//Store value of i to stack
	b	testOT				//Branch

sortOT:	mov	w24,	w19			//Set w24 to i
	str	w24,	[fp,	temp_s]		//Store min to stack

	ldr	w19,	[fp,	i_s]		//Load val to reg
	mov	w21,	w19			//Set j=i
	add	w21,	w21,	1		//increment
	str	w21,	[fp,	j_s]		//store value of j into stack
	
	b	testIN

sortIN:	ldr	w21,	[fp,	j_s]
	ldr	w19,	[fp,	temp_s]		//Load value of min
	ldr	w24,	[x23,	w19,	SXTW 2]	//Load  into w24
	ldr	w21,	[x23,	w21,	SXTW 2]	//Load into w21
	
	cmp	w24,	w21		
	b.lt	next
	
	str	w21,	[fp,	temp_s]		//Store new min

next:	add	w21,	w21,	1		//increment
	str	w21,	[fp,	j_s]		//store value of j to mem

testIN:	cmp	w21,	size
	b.lt	sortIN

	ldr	w19,	[fp,	temp_s]		//load min to w19
	ldr	w24,	[x23,	w19,	SXTW 2]	//load to w24
	ldr	w19,	[fp,	i_s]		//load from i to stack
	ldr	w21,	[x23,	w19,	SXTW 2]

	mov	w22,	w21			//temp_s = v[i]
	mov	w21,	w24			//v[i] = v[min]
	mov	w24,	w22			//v[min] = temp_s

	str	w24,	[x23,	w19,	SXTW 2]	//store v[i]
	str	w21,	[x23,	w19,	SXTW 2]	//store v[min]

	adrp	x0,	array			//Prints out the array
	add	w0,	w0,	:lo12:array
	mov	w1,	w19
	ldr	w24,	[x23,	w19,	SXTW 2]
	mov	w2,	w24
	bl	printf

	ldr	w19,	[fp,	i_s]		//loads i
	add	w19,	w19,	1		//increments
	str	w19,	[fp,	i_s]		//stores the value

testOT:	cmp	w19,	size			//checks
	b.lt	sortOT				//reiterate

	//End of program
done:	mov	w0,	0			//return 0 to OS
	ldp	fp,	lr,	[sp],	dealloc	//deallocate
	ret					//returns to calling code
