	area start, code
	export StartHere
StartHere
	MRC p15, 0, r0, c1, c1, 2

	ORR r0, r0, #2_11<<10 ; enable fpu

	MCR p15, 0, r0, c1, c1, 2

	LDR r0, =(0xF << 20)

	MCR p15, 0, r0, c1, c0, 2

	MOV r3, #0x40000000

	VMSR FPEXC, r3

	import __main
	b __main

	end
