/*
Ezra John Guia
30031697
Assignment 2
355 LEC - 02
Tutorial - T08
Version 1
*/

initVal:.string "multiplier = 0x%08x (%d) multiplicand = 0x%08x (%d)\n\n"
prodRes:.string	"product = 0x%08x  multiplier = 0x%08x\n"
results:.string	"64-bit result = 0x%016lx (%ld)\n"

	.balign	4			//Keeps instructions aligned to 4 columns
	.global	main			//Make "main" visible to OS

	//Int macros
			//Sets the register x19 to be the multiplier
			//Sets the reg to be the multiplicand
			//Sets the reg to be the product
			//Sets the reg to be i
			//Sets the reg to be negative

	//Long int macros
			//Sets the reg to be the result
			//Sets the reg to be temp1
			//Sets the reg to be temp2

	//Start of program
main:	stp	x29,	x30,	[sp, -16]!
	mov	x29,	sp

	//Give values to registers
	mov	w20,	-16843010	//Sets multiplicand value
	mov	w19,	70		//Sets multiplier value
	mov	w21,	0		//Sets product value

	//Prints out initial values of variables
	adrp	x0,	initVal
	add	x0,	x0,	:lo12:initVal
	mov	w1,	w19		//Adds the multiplier
	mov	w2,	w19		//Adds the multiplier
	mov	w3,	w20		//Adds the multiplicand
	mov	w4,	w20		//Adds the multiplicand
	bl	printf			//Prints the values

	//Determine if multiplier if negative
	cmp	w19,	wzr		//Compares multiplier to zero register
	b.ge	pos			//Branches to positive if greater than 0
	mov	w23,	1		//Negative value is now true
	b	next1

pos:	mov	w23,	0		//Negative value is now false

	//Do repeated add and shift
next1:	mov	w22,	0		//Sets the i register to 0
	b	test1			//Branches to the test

loop:	and	w27,	w19,	0x1	//Completes and operation
	cmp	w27,	0		//Compares the result to 0
	b.eq	next2			//Branches if 0
	add	w21,	w21,	w20	//Adds the product and multiplicand

next2:	asr	w19,	w19,	1	//Arithmetic shift right
	and	w27,	w21,	0x1	//and operation with the result in w27
	cmp	w27,	0		//Compares the value with 0
	b.eq	next3			//Branches to skip if false
	orr	w19,	w19,	0x80000000	//orr operation with the result in multiplier
	b	next4			//Branches to label next4

next3:	and	w19,	w19,	0x7FFFFFFF	//and operation with the result in multiplier

next4:	asr	w21,	w21,	1	//Arithmetic shift right
	add	w22,	w22,	1	//Increments i

test1:	cmp	w22,	32		//Checks loop count
	b.lt	loop			//If less than 32, goes back through the loop

	//Adjust product register if multiplier is negative
	cmp	w23,	0		//Checks if multiplier is negative
	b.eq	skip			//Skips the next operation if it not equal
	sub	w21,	w21,	w20	//Difference is added to the product register

skip:
	//Print out product and multiplier
	adrp	x0,	prodRes
	add	x0,	x0,	:lo12:prodRes
	mov	w1,	w21		//Adds the product
	mov	w2,	w19		//Adds the multiplier
	bl	printf			//Prints the values

	//Combine product and multiplier together
	sxtw	x25,	w21			//Type casts product to 64-bit
	and	x25,	x25,	0xFFFFFFFF	//"Masks out" bits
	lsl	x25,	x25,	32		//Arithmetic shift right by 32
	sxtw	x26,	w19			//Type casts multiplier to 64-bit
	and	x26,	x26,	0xFFFFFFFF	//"Masks out? bits
	add	x24,	x25,	x26		//Adds the 2 temp registers to 64-bit reg
	
	//Print out 64-bit result
	adrp	x0,	results
	add	x0,	x0,	:lo12:results
	mov	x1,	x24		//Adds the result
	mov	x2,	x24		//Adds the result
	bl	printf			//Prints the values

	//End of program
done:	mov	w0,	0
	ldp	x29,	x30,	[sp],	16
	ret
