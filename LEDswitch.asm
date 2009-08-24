

; All pages are marked in 8006G-AVR-01/08 datasheet

.include "tn44def.inc"

.cseg

.ORG 0x0000	
    rjmp RESET		; reset
.ORG 0x0004 
    rjmp iPCINT0 ; PCINT1 Handler 

.org 0x0022 


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

	
	; GIMSK/PCIE0 enable PCINT0..7
	ldi r16, 1<<PCIE0
	out GIMSK, r16


	; PCINT0	 enable (p50)	
	ldi r16, 1<<PCINT0
	out PCMSK0, r16

	

	sei					; enable interrupts



LOOP:
	sleep
	rjmp LOOP 
	
	
iPCINT0:
	cli
	in r0, SREG

	in r20, PORTA
	ldi r21, 1 << PORTA1 
	eor r20, r21

;	ldi r20, 1 << PORTA1
	out PORTA, r20


	out SREG, r0

	sei
	reti
