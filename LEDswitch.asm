
.include "m168def.inc"

rjmp SETUP


SETUP:
	sbi DDRC, 0
	cbi DDRC, 1 

	sbi PORTC, 1

	in r20, MCUCR
	cbr r20, 32  // PUD <- 0
	out MCUCR, r20

LOOP:
	in r20, PINC
	in r21, PORTC
	bst r20, 1
    bld r21, 0
	out PORTC, r21
	rjmp LOOP 
	
	
