/*
Ezra John Guia
30031697
Assignment 4
355 LEC -02
Tutorial - T08
*/

box:	.string "Box %s origin = (%d, %d) width = %d height = %d area = %d\n"
init:	.string "Initial box values\n"
new:	.string "\nChanged Box values:\n"
firstS:	.string "first"
secondS:.string "second"

	define(first_base_r,	x19)	//Setting up the base address for the first box
	define(second_base_r,	x20)	//Base address of the second box

	FALSE			=	0		//Setting FALSE to 0
	TRUE			=	1		//Setting TRUE to 1

	point_x			=	0		//4 bytes
	point_y			=	4		//4 bytes
	point_size		=	8		//Total size

	dim_width		=	0		//4 bytes
	dim_height		=	4		//4 bytes
	dim_size		=	8		//Total size

	box_Porigin		=	0
	box_Dsize		=	8		//Origin has 2 INTS, 8 bytes long
	box_area		=	16		//Dimension has 2 INTS, 8 bytes long

	box_fsize		=	point_size + dim_size + 4	//Total size allocating, 4 being the area as an INT
	first			=	box_fsize					//Sets the size of the first box to the full size
	second			=	box_fsize					//Sets the size of the second box to the full size

	alloc			=	-(16 + first + second) & -16	//Allocates space for the frame record, first and second box
	dealloc			=	-alloc							//Deallocates the same space

	first_s			=	16							//Offset from the frame rec
	second_s		=	first_s + first				//Offset from the frame rec, then first

	fp .req	x29
	lr .req x30

	.balign	4
	.global	main

//---------------------------START OF MAIN---------------------------//
main:
	stp	fp,	lr,	[sp, alloc]!
	mov	fp,	sp

	add	first_base_r,	fp,	first_s		//Calculates the base address of the first box
	add	second_base_r,	fp,	second_s	//Calculates the base of the second box

	//Initialisation of boxes
	mov 	x8,		first_base_r		//Moves the first address to the argument register
	bl		newBox						//Makes a box for the first box

	mov		x8,		second_base_r		//Moves the first address to the argument register
	bl		newBox						//Makes a box for the first box

	//Printing of box values
	adrp	x0,		init				//Prints out the heading for the starting values
	add		w0,		w0,		:lo12:init
	bl		printf

	mov		x0,		first_base_r		//Prints out the values for the first box
	adrp	x1,		firstS
	add		w1,		w1,		:lo12:firstS
	bl		printBox

	mov		x0,		second_base_r		//Prints out the values for the second box
	adrp	x1,		secondS
	add		w1,		w1,		:lo12:secondS
	bl		printBox

	//Checking if boxes are the same. Changing them if they are
	mov		x0,		first_base_r		//Moves the address of the first box to the argument register
	mov		x1,		second_base_r		//Moves the second address to the following register
	bl		equal						//Calls the subroutine equal using the first and second box as arguments
	cmp		w0,		TRUE				//If the returning value is not true
	b.ne	skip						//	skip the if statement

	mov		x0,		first_base_r		//Moves the address of the first box
	mov		w1,		-5					//Adds an x value
	mov		w2,		7					//Adds the y value
	bl		move						//Calls out the subroutine MOVE

	mov		x0,		second_base_r		//Moves the address of teh second box
	mov		w1,		3					//Adds the factor to extend it by
	bl		expand						//Calls out the subroutine EXPAND

skip:

	//Printing of new box values
	adrp	x0,		new					//Prints out the heading for the new values
	add		x0,		x0,		:lo12:new
	bl		printf

	mov		x0,		first_base_r		//Prints out the new first box values
	adrp	x1,		firstS
	add		w1,		w1,		:lo12:firstS
	bl		printBox

	mov		x0,		second_base_r		//Prints out the new second box values
	adrp	x1,		secondS
	add		w1,		w1,		:lo12:secondS
	bl		printBox

	mov	w0,	0
	ldp	fp,	lr,	[sp],	dealloc
	ret

//---------------------------END OF MAIN---------------------------//

	//struct box newBox
	define(b_base_r,	x9)		//Defines the x9 reg as the base address of the local variable

	b_size		=	box_fsize				//Sets the size of the local variable to the box size
	b_alloc		=	-(16 + b_size) & -16	//Allocates space for the local var
	b_dealloc	=	-b_alloc				//Deallocate the same space.
	b_s			=	16						//Sets the offset of the local var from the frame record

newBox:
	stp	fp,	lr,	[sp, b_alloc]!
	mov	fp,	sp

	add	b_base_r,	fp,	b_s			//Calculates the base address of the local variable
	mov	w10,	1					//Moves 1 to a register

	str	xzr,	[b_base_r,	box_Porigin + point_x]	//Stores zero in x
	str xzr,	[b_base_r,	box_Porigin + point_y]	//Stores zero in y
	str w10,	[b_base_r,	box_Dsize + dim_width]	//Stores 1 in width
	str w10,	[b_base_r,	box_Dsize + dim_height]	//Stores 1 in height
	str w10,	[b_base_r,	box_area]				//Stores 1 in area

	ldr	w10,	[b_base_r,	box_Porigin + point_x]
	str	w10,	[x8,		box_Porigin + point_x]	//Stores the local x to the main x

	ldr w10,	[b_base_r,	box_Porigin + point_y]
	str	w10,	[x8,		box_Porigin + point_y]	//Stores the local y to the main y

	ldr w10,	[b_base_r,	box_Dsize + dim_width]
	str	w10,	[x8,		box_Dsize + dim_width]	//Stores the local width to the main width

	ldr w10,	[b_base_r,	box_Dsize + dim_height]
	str	w10,	[x8,		box_Dsize + dim_height]	//Stores the local height to the main height

	ldr w10,	[b_base_r,	box_area]
	str	w10,	[x8,		box_area]	//Stores the local area to the main area

	ldp	fp,	lr,	[sp],	b_dealloc	//Deallocate the used space for the subroutine
	ret

	//move function
move:
	stp	fp,	lr,	[sp, -16]!
	mov	fp,	sp

	mov	x21,	x0		//Moving address of current box
	mov	w22,	w1		//Moving delata x
	mov	w23,	w2		//Moving delta y

	ldr	w9,		[x21,	box_Porigin + point_x]	//Load x val of current box
	add	w9,		w22,	w9						//Add the delta x
	str	w9,		[x21,	box_Porigin + point_x]	//Store the new x

	ldr	w9,		[x21,	box_Porigin + point_y]	//Load y val of current box
	add	w9,		w23,	w9						//Add the delta y
	str	w9,		[x21,	box_Porigin + point_y]	//Store the new y

	ldp	fp,	lr,	[sp],	16
	ret
	
	//expand function
expand:
	stp	fp,	lr,	[sp, -16]!
	mov	fp,	sp

	mov	x21,	x0		//Moving address of current box
	mov	w22,	w1		//Moving the factor

	ldr	w23,	[x21,	box_Dsize + dim_width]	//Load width of box
	mul	w23,	w23,	w22						//Multiply width by factor
	str	w23,	[x21,	box_Dsize + dim_width]	//Store new width

	ldr	w24,	[x21,	box_Dsize + dim_height]	//Load height of box
	mul	w24,	w24,	w22						//Multiply height by factor
	str	w24,	[x21,	box_Dsize + dim_height]	//Store new height

	mul	w25,	w23,	w24			//Multiply new width and height 
	str	w25,	[x21,	box_area]	//Store the area

	ldp	fp,	lr,	[sp],	16
	ret

	//printBox function
printBox:
	stp	fp,	lr,	[sp, -16]!
	mov	fp,	sp

	mov	x21,	x0	//Address of box
	mov	x22,	x1	//Address of string

	adrp	x0,	box	
	add		w0,	w0,	:lo12:box

	ldr	w2,	[x21,	box_Porigin + point_x]	//Loads x
	ldr	w3,	[x21,	box_Porigin + point_x]	//Loads y
	ldr	w4,	[x21,	box_Dsize + dim_width]	//Loads width
	ldr	w5,	[x21,	box_Dsize + dim_height]	//Loads height
	ldr	w6,	[x21,	box_area]	//Loads area
	bl	printf

	ldp	fp,	lr,	[sp],	16
	ret

	//int equal function
equal:
	stp	fp,	lr,	[sp, -16]!
	mov	fp,	sp

	mov	x21,	x0	//Moving address of box 1
	mov	x22,	x1	//Moving address of box 2

	ldr	w23,	[x21,	box_Porigin + point_x]	//Load x of box 1
	ldr	w24,	[x22,	box_Porigin + point_x]	//Load x of box 2
	cmp	w23,	w24								//Check if equal
	b.ne	false								//	branch if not

	ldr	w23,	[x21,	box_Porigin + point_y]	//Load y of box 1
	ldr	w24,	[x22,	box_Porigin + point_y]	//Load y of box 2
	cmp	w23,	w24								//Check if equal
	b.ne	false								//	branch if not

	ldr	w23,	[x21,	box_Dsize + dim_width]	//Load width of box 1
	ldr	w24,	[x22,	box_Dsize + dim_width]	//Load width of box 2
	cmp	w23,	w24								//Check if equal
	b.ne	false								//	branch if not

	ldr	w23,	[x21,	box_Dsize + dim_height]	//Load height of box 1
	ldr	w24,	[x22,	box_Dsize + dim_height]	//Load height of box 2
	cmp	w23,	w24								//Check if equal
	b.ne	false								//	branch if not
	
	mov	w0,		TRUE	//Decides all parameters are the same
	b	pass			//Skips False statement

false:
	mov	w0,		FALSE	//Sets to false if a parameter if not equal

pass:
	ldp	fp,	lr,	[sp],	16
	ret