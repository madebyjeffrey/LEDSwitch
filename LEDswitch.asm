
; converting from 168 to 44

; All pages are marked in 8006G-AVR-01/08 datasheet

.include "tn44def.inc"

.cseg

.ORG 0x0000	
    rjmp RESET		; reset
.ORG 0x0004 
    rjmp iPCINT1 ; PCINT1 Handler 
.ORG 0x0018
	rjmp iWDT	; WDT Handler

.org 0X0040 

.include "Timer168.asm"

RESET:
	cli					; disable interrupts

	; Setup Stack
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16


	; Enable PA0 input (p55)
	cbi DDRA, DDA0 		; DDRA/DDA0 <- 0
	sbi PORTA, PORTA0	; PORTA/PORTA0 <- 1

	in r20, MCUCR       ; MCUCR/PUD <- 0 (pullup enabled)
	cbr r20, (1 << PUD)  		
	out MCUCR, r20

	; Enable PA1 output (p55)
	sbi DDRA, DDA1		; DDRA/DDA1 <- 1

	; PCINT9 enable (p70)
	
	;; got up to here
	

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
