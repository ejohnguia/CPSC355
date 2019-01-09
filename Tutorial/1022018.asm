string:	.string	"The output is: %d\n"
	.balign	4
	.global	main

main:	stp	x29,	x30,	[sp,-16]!
	mov	x29,	sp

	define	(a_r,	x19)
	define	(b_r,	x20)
	define	(res_r,	x21)

	mov	a_r,	7
	mov	b_r,	28
test:	tst	a_r,	0x4
r

	
	b.ne	next
	add	a_r,	a_r,	1
	
next:	eor	x1,	a_r,	b_
	and	x1,	a_r,	x1
	adrp	x0,	string
	add	x0,	x0	:lo12:string
	mov	x1,	res_r
	bl	printf


done:	mov	w0,	0
	ldp	x29,	x30,	[sp],	16
	ret
