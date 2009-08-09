
.include "m168def.inc"

.cseg

.ORG 0x0000	
    jmp RESET		; reset
.ORG 0x0008 
    jmp iPCINT1 ; PCINT1 Handler 
.ORG 0x0018
	jmp iWDT	; WDT Handler

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
;	ldi r28, PCMSK1
;	ldi r16, 1<<PCINT9
;	st Y, r16
    lds r16, PCMSK1
    sbr r16, 1<<PCINT9
    sts PCMSK1, r16

	; PCICR/PCIE1 <- 1
;	ldi r28, PCICR
;	ldi r16, 1<<PCIE1
;	st Y, r16
    lds r16, PCICR
    sbr r16,1<<PCIE1
    sts PCICR, r16

	; change watchdog prescaler to be ~0.5s
	
	lds r16, WDTCSR
	mov r17, r16
	sbr r16, (1 << WDCE) | (1 << WDE)	
	wdr
	sts WDTCSR, r16			; enable change, have 4 clk after this for the rest
	cbr r17, (1 << WDE) | (1 << WDP3) | (1 << WDP1)	| (1 << WDIE)
	sbr r17, (1 << WDP2) | (1 << WDP0)  				;
	sts WDTCSR, r17

	eor r20, r20
	sts $0100, r20

	sei					; enable interrupts



LOOP:
	rjmp LOOP 
	
	
iPCINT1:
	cli
	in r0, SREG

	lds r20, $0100
	com r20
	sts $0100, r20

	lds r16, WDTCSR
	mov r17, r16
	sbr r16, (1 << WDCE) | (1 << WDE)	
	wdr
	sts WDTCSR, r16			; enable change, have 4 clk after this for the rest
	cbr r17, (1 << WDE) | (1 << WDP3) | (1 << WDP1)
	sbr r17, (1 << WDP2) | (1 << WDP0) | (1 << WDIE) 				;
	sts WDTCSR, r17
	


;	in r20, PINC
;	in r21, PORTC
;	bst r20, 1
;   bld r21, 0
;	out PORTC, r21

	out SREG, r0

	sei
	reti

iWDT:
	cli
	
	in r0, SREG
	
	lds r20, $0100
	eor r21, r21
	bst r20, 0
	bld r21, 0
	out PORTC, r21

	
	out SREG, r0

	wdr

	sei
	reti
