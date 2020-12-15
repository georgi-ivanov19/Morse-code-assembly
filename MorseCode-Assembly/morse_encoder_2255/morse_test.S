#define __SFR_OFFSET 0
#include <avr/io.h>
	
	CPU_FREQ = 16000000				; Frequency of the CPU in Hz
	TICKS_PER_SEC = CPU_FREQ / (256 * 1024)		; 1 second

	DOT =  TICKS_PER_SEC / 10   		        ; 100ms, duration of a dot
	DASH = DOT * 4					; 400ms, durantion of a dash

	SIGNAL_GAP = DOT                                ; 100ms,  gap between inputs that belong to the
                                			; same letter
                                         
	LETTER_GAP = (10 * DOT)                         ; 1s, gap before inputs for new letters
	
	.global main
	.section .text
main:
	ldi r19, _BV(5)
	out DDRB, r19		                        ; Making PIN13 an output


infinite_loop:
    rcall parse_message
    rjmp infinite_loop

parse_message:
    push r22
    push r23
    push r24
    push r25
    push r30
    push r31	
 
    ldi r30, lo8(message)                               ; Set up Z registers to point at message 
    ldi r31, hi8(message)                               

char2morse:
    lpm r22, Z+						; Load ASCII value of letter to r22					

    cpi r22, 0x0					; If last value loaded is end of string..
    breq end_parse_message				; parse message from the  beginning
	
    subi r22, 0x41					; Subtracting the value of A (in ASCII) to loaded
							; letter to get offset for the morse_table pointer
    rcall output_letter
    rjmp char2morse

end_parse_message:
    pop r31						; Restoring used registers
    pop r30
    pop r25
    pop r24
    pop r23
    pop r22
	
    ret

output_letter:
    push r24
    push r30
    push r31

    ldi r30, lo8(morse_table)                           ; Set up Z registers to point at morse_tabl
    ldi r31, hi8(morse_table)
	
    lsl r22                                             ; Multiplying by 2, as every letter has 2 values
							; in the table this is needed to point where we want
	
    add r30, r22                                        ; Offset pointer to desired letter
    brcc 1f						
    inc r31
1:
    lpm r23, Z                                          ; Load letter length to r23
	
    inc r30						
    lpm r25, Z                                          ; Load letter sequence to r25

 
send_pattern:
    sbi PORTB, 5       					; Signal start, turn on port
    dec r23						; Letter lenght acting as the flag for the loop
	
    lsr r25						; If right shifted a 1 send dash signal, otherwise
    brcs dash						; send a dot signal
	
    ldi  r24, DOT
    rcall delay_cs
    rjmp 1f
	
dash:	
    ldi  r24, DASH
    rcall delay_cs

1:	
    cbi PORTB, 5                                        ; Signal end, switch off port 
 
    ldi r24, SIGNAL_GAP                                 ; Wait 100ms to simulate gaps between 
    rcall delay_cs                                      ; input for the same letter

    cpi r23, 0						
    breq exit
    rjmp send_pattern                                  

exit:

    ldi r24, LETTER_GAP 	                        ; Wait 1s to indicate new letter is 
    rcall delay_cs					; beginning

    pop r31
    pop r30
    pop r24
	
    ret
	
.align 2
message:
	.string "MARCOGEORGIALEXAMAANBILL"   

;;; The letter encoding is in two bytes: the first gives the
;;; length of the morse code and the second byte contains the sequence
;;; of dots and dashes as a bit pattern, where 1 is a dash and 0 a dot.
;;; The sequence is reversed so that we can determine a dash or a dot using
;;; the carry created by logical shifting to the right. 
morse_table:
    .byte  2, 0x2       ; A                             
    .byte  4, 0x1       ; B
    .byte  4, 0x5       ; C
    .byte  3, 0x1       ; D        
    .byte  1, 0x0       ; E
    .byte  4, 0x4       ; F
    .byte  3, 0x3       ; G
    .byte  4, 0x0       ; H             
    .byte  2, 0x0       ; I
    .byte  4, 0xE       ; J 
    .byte  3, 0x5       ; K
    .byte  4, 0x2       ; L             
    .byte  2, 0x3       ; M
    .byte  2, 0x1       ; N
    .byte  3, 0x7       ; O
    .byte  4, 0x6       ; P               
    .byte  4, 0xB       ; Q
    .byte  3, 0x2       ; R
    .byte  3, 0x0       ; S
    .byte  1, 0x1       ; T             
    .byte  3, 0x4       ; U
    .byte  4, 0x8       ; V
    .byte  3, 0x6       ; W
    .byte  4, 0x9       ; X          
    .byte  4, 0xD       ; Y
    .byte  4, 0x3       ; Z                      

