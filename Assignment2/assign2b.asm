/*
Ezra John Guia
30031697
Assignment 2
355 LEC - 02
Tutorial - T08
Version 2
*/

initVal:.string "multiplier = 0x%08x (%d) multiplicand = 0x%08x (%d)\n\n"
prodRes:.string	"product = 0x%08x  multiplier = 0x%08x\n"
results:.string	"64-bit result = 0x%016lx (%ld)\n"

	.balign	4			//Keeps instructions aligned to 4 columns
	.global	main			//Make "main" visible to OS

	//Int macros
	define(mer_r,	w19)		//Sets the register x19 to be the multiplier
	define(mnd_r,	w20)		//Sets the reg to be the multiplicand
	define(prd_r,	w21)		//Sets the reg to be the product
	define(i_r,	w22)		//Sets the reg to be i
	define(neg_r,	w23)		//Sets the reg to be negative

	//Long int macros
	define(res_r,	x24)		//Sets the reg to be the result
	define(tmp1_r,x25)		//Sets the reg to be temp1
	define(tmp2_r,x26)		//Sets the reg to be temp2

	//Start of program
main:	stp	x29,	x30,	[sp, -16]!
	mov	x29,	sp

	//Give values to registers
	mov	mnd_r,	522133279	//Sets multiplicand value
	mov	mer_r,	200		//Sets multiplier value
	mov	prd_r,	0		//Sets product value

	//Prints out initial values of variables
	adrp	x0,	initVal
	add	x0,	x0,	:lo12:initVal
	mov	w1,	mer_r		//Adds the multiplier
	mov	w2,	mer_r		//Adds the multiplier
	mov	w3,	mnd_r		//Adds the multiplicand
	mov	w4,	mnd_r		//Adds the multiplicand
	bl	printf			//Prints the values

	//Determine if multiplier if negative
	cmp	mer_r,	wzr		//Compares multiplier to zero register
	b.ge	pos			//Branches to positive if greater than 0
	mov	neg_r,	1		//Negative value is now true
	b	next1

pos:	mov	neg_r,	0		//Negative value is now false

	//Do repeated add and shift
next1:	mov	i_r,	0		//Sets the i register to 0
	b	test1			//Branches to the test

loop:	and	w27,	mer_r,	0x1	//Completes and operation
	cmp	w27,	0		//Compares the result to 0
	b.eq	next2			//Branches if 0
	add	prd_r,	prd_r,	mnd_r	//Adds the product and multiplicand

next2:	asr	mer_r,	mer_r,	1	//Arithmetic shift right
	and	w27,	prd_r,	0x1	//and operation with the result in w27
	cmp	w27,	0		//Compares the value with 0
	b.eq	next3			//Branches to skip if false
	orr	mer_r,	mer_r,	0x80000000	//orr operation with the result in multiplier
	b	next4			//Branches to label next4

next3:	and	mer_r,	mer_r,	0x7FFFFFFF	//and operation with the result in multiplier

next4:	asr	prd_r,	prd_r,	1	//Arithmetic shift right
	add	i_r,	i_r,	1	//Increments i

test1:	cmp	i_r,	32		//Checks loop count
	b.lt	loop			//If less than 32, goes back through the loop

	//Adjust product register if multiplier is negative
	cmp	neg_r,	0		//Checks if mutliplier is negative
	b.eq	skip			//Skips the next operation if it not equal
	sub	prd_r,	prd_r,	mnd_r	//Difference is added to the product register

skip:
	//Print out product and multiplier
	adrp	x0,	prodRes
	add	x0,	x0,	:lo12:prodRes
	mov	w1,	prd_r		//Adds the product
	mov	w2,	mer_r		//Adds the multiplier
	bl	printf			//Prints the values

	//Combine product and multiplier together
	sxtw	tmp1_r,	prd_r			//Type casts product to 64-bit
	and	tmp1_r,	tmp1_r,	0xFFFFFFFF	//"Masks out" bits
	lsl	tmp1_r,	tmp1_r,	32		//Arithmetic shift right by 32
	sxtw	tmp2_r,	mer_r			//Type casts multiplier to 64-bit
	and	tmp2_r,	tmp2_r,	0xFFFFFFFF	//"Masks out? bits
	add	res_r,	tmp1_r,	tmp2_r		//Adds the 2 temp registers to 64-bit reg
	
	//Print out 64-bit result
	adrp	x0,	results
	add	x0,	x0,	:lo12:results
	mov	x1,	res_r		//Adds the result
	mov	x2,	res_r		//Adds the result
	bl	printf			//Prints the values

	//End of program
done:	mov	w0,	0
	ldp	x29,	x30,	[sp],	16
	ret
