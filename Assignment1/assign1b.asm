//Ezra John Guia
//30031697
//CPSC355
//optimized v.

values:	.string "The values: x: %d, y: %d and max: %d\n"
	.balign 4			//keeps instructions aligned to 4 columns
	.global main			//make "main" visible to OS

	define(x_r,	x19)		//register for x value
	define(y_r,	x25)		//reg for y val
	define(max_r,	x28)		//reg for max val
	define(temp_r,	x26)		//reg for temporary placeholder

main:	stp	x29,	x30,	[sp, -16]!
	mov	x29,	sp
	
	mov	x_r,	-6		//sets initial value of x
	mov	max_r,	-5000		//sets initial max value
	b	test			//tests for x iteration

top:	mul	x20,	x_r,	x_r	//
	mul	x20,	x20,	x_r	//x^3
	mul	x21,	x_r,	x_r	//x^2

	mov	y_r,	31			//+31 to y value
	mov	temp_r,	4			//temp reg to 4
	madd	y_r,	temp_r,	x_r,	y_r	//adds 4x to y
	mov	temp_r,	-31 			//temp reg to -31	
	madd	y_r,	temp_r, x21,	y_r	//adds -31x^2 to y
	mov	temp_r,	-5			//temp reg to -5
	madd	y_r,	temp_r,	x20,	y_r	//result of y

	cmp	y_r,	max_r
	b.le	keep			//keeps current maximum value

	mov	max_r,	y_r		//replaces values if comparison is false
	
keep:	adrp	x0,	values
	add	x0,	x0,	:lo12:values
	mov	x1,	x_r		//prints x
	mov	x2,	y_r		//prints y
	mov	x3,	max_r		//prints max	                                 	
	bl	printf			//finally prints

	add	x_r,	x_r,	1	//increments the x value

test:	cmp	x_r,	5		//checks if x range has reached
	b.le	top			//returns to the loop if x <= 5

done:	mov	w0,	0
	ldp	x29,	x30,	[sp],	16
	ret
