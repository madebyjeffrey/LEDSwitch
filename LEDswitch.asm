
.include "m168def.inc"

.cseg

.ORG 0x0000	
    jmp RESET		; reset
.ORG 0x0008 
    jmp iPCINT1 ; PCINT1 Handler 

.org 0X0040 

RESET:
	cli					; disable interrupts

	; Setup Stack
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16


	; Enable PC1 input (p74)
	cbi DDRC, 1 		; DDRC/1 <- 0
	sbi PORTC, 1		; PORTC/1 <- 1

	in r20, MCUCR       ; MCUCR/4 <- 0 (pullup enabled)
	cbr r20, 32  		
	out MCUCR, r20

	; Enable PC0 output (p74)
	sbi DDRC, 0			; DDRC/0 <- 1

	; PCINT9 enable (p70)
	

	clr r29

	; PCMSK1/PCINT9 <- 1
	ldi r28, PCMSK1
	ldi r16, PCINT9
	st Y, r16

	; PCICR/PCIE1 <- 1
	ldi r28, PCICR
	ldi r16, PCIE1
	st Y, r16



	sei					; enable interrupts



LOOP:
	rjmp LOOP 
	
	
iPCINT1:
	cli

	in r20, PINC
	in r21, PORTC
	bst r20, 1
    bld r21, 0
	out PORTC, r21

	

	sei
	reti
