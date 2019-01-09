//Ezra John Guia
//30031697
//CPSC355
//unoptimized v.

values:	.string "The values: x: %d, y: %d and max: %d\n"
	.balign 4			//keeps instructions aligned to 4 columns
	.global main			//make "main" visible to OS

main:	stp	x29,	x30,	[sp, -16]!
	mov	x29,	sp
	
	mov	x19,	-6		//sets initial value of x
	mov	x28,	-5000		//sets initial max value

test:	cmp	x19,	5		//tests current iteration
	b.gt	done			//finishes loop if x >= 5

	mul	x20,	x19,	x19	//
	mul	x20,	x20,	x19	//x^3
	mul	x21,	x19,	x19	//x^2

	mov	x26,	-5		//temp reg to -5
	mul	x22,	x20,	x26	//value of -5x^3
	mov	x26,	-31 		//temp reg to -31
	mul	x23,	x21,	x26	//value of -31x^2
	mov	x26,	4		//temp reg to 4
	mul	x24,	x19,	x26	//value of 4x

	add	x25,	x22,	x23	//
	add	x25,	x25,	x24	//
	add	x25,	x25,	31	//result of y
	
	cmp	x25,	x28		//compares y val and max
	b.le	keep			//keeps current maximum value

	mov	x28,	x25		//replaces values if comparison is false
	
keep:	adrp	x0,	values
	add	x0,	x0,	:lo12:values
	mov	x1,	x19		//prints x
	mov	x2,	x25		//prints y
	mov	x3,	x28		//prints max               	
	bl	printf			//finally prints

	add	x19,	x19,	1	//increments the x value
	b	test			//returns to the loop

done:	mov	w0,	0
	ldp	x29,	x30,	[sp],	16
	ret
