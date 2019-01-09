//Ezra John Guia
//30031697
//CPSC355
//optimized v.

values:	.string "The values: x: %d, y: %d and max: %d\n"
	.balign 4			//keeps instructions aligned to 4 columns
	.global main			//make "main" visible to OS

			//register for x value
			//reg for y val
			//reg for max val
			//reg for temporary placeholder

main:	stp	x29,	x30,	[sp, -16]!
	mov	x29,	sp
	
	mov	x19,	-6		//sets initial value of x
	mov	x28,	-5000		//sets initial max value
	b	test			//tests for x iteration

top:	mul	x20,	x19,	x19	//
	mul	x20,	x20,	x19	//x^3
	mul	x21,	x19,	x19	//x^2

	mov	x25,	31			//+31 to y value
	mov	x26,	4			//temp reg to 4
	madd	x25,	x26,	x19,	x25	//adds 4x to y
	mov	x26,	-31 			//temp reg to -31	
	madd	x25,	x26, x21,	x25	//adds -31x^2 to y
	mov	x26,	-5			//temp reg to -5
	madd	x25,	x26,	x20,	x25	//result of y

	cmp	x25,	x28
	b.le	keep			//keeps current maximum value

	mov	x28,	x25		//replaces values if comparison is false
	
keep:	adrp	x0,	values
	add	x0,	x0,	:lo12:values
	mov	x1,	x19		//prints x
	mov	x2,	x25		//prints y
	mov	x3,	x28		//prints max	                                 	
	bl	printf			//finally prints

	add	x19,	x19,	1	//increments the x value

test:	cmp	x19,	5		//checks if x range has reached
	b.le	top			//returns to the loop if x <= 5

done:	mov	w0,	0
	ldp	x29,	x30,	[sp],	16
	ret
