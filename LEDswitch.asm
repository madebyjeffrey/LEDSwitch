
.include "m168def.inc"

	jmp RESET		; reset
	reti nop		; int0
	reti nop		; int1
	reti nop		; pcint0
	jmp iPCINT1		; pcint1
	reti nop		; pcint2
	reti nop		; wdt
	reti nop		; timer2 compa
	reti nop		; timer2 compb
	reti nop		; timer2 ovf
	reti nop		; timer1 capt
	reti nop		; timer1 compa
	reti nop		; timer1 compb
	reti nop		; timer1 ovf
	reti nop		; timer0 compa
	reti nop		; timer0 compb
	reti nop		; timer0 ovf
	reti nop		; spi, stc
	reti nop		; usart, rx
	reti nop		; usart, udre
	reti nop		; usart, tx
	reti nop		; adc
	reti nop		; ee ready
	reti nop		; analog comp
	reti nop		; twi/i2c
	reti nop		; spm ready


RESET:
	cli					// disable interrupts

	// Setup Stack
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16


	// Enable PC1 input (p74)
	cbi DDRC, 1 		// DDRC/1 <- 0
	sbi PORTC, 1		// PORTC/1 <- 1

	in r20, MCUCR       // MCUCR/4 <- 0 (pullup enabled)
	cbr r20, 32  		
	out MCUCR, r20

	// Enable PC0 output (p74)
	sbi DDRC, 0			// DDRC/0 <- 1

	// PCINT8 enable (p70)
	
	// PCICR/PCIE1 <- 1
	clr r29
	ldi r28, PCICR
	ldi r16, 2
	st Y, r16
	// PCMSK1/0 <- 1
	ldi r28, PCMSK1
	ldi r16, 1
	st Y, r16


	sei					// enable interrupts



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
