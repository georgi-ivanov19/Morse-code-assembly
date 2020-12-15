;;; This subroutine converts an inputted morse alphabet letter 
;;; to its digit representation on the 7-segment-display

;;; Input:
;;; r23: morse code length
;;; r24: morse code pattern
;;;
;;; Output:
;;; r24: 7-segment representation of the character

#include "7segment.S"

;;; Effectively a switch case with morse length as an input
	.global get_digit 
get_digit:
	push r30				; Save Z register low
	push r31				; Save Z register high

	cpi r23, 1				; If morse code length is not 1...
	brne 1f					; go to next subroutine 1

	;; Set up Z register to point at table length_1
	ldi r30, lo8(length_1)
 	ldi r31, hi8(length_1)
	rjmp 4f						

1:
	cpi r23, 2				; If morse code length is not 2...
	brne 2f					; go to next subroutine 2

	ldi r30, lo8(length_2)      	
	ldi r31, hi8(length_2)		
	rjmp 4f		

2:
	cpi r23, 3				; Similar to subroutine 1
	brne 3f
	
	ldi r30, lo8(length_3)
	ldi r31, hi8(length_3)
	rjmp 4f

3:
	cpi r23, 4 				; Similar to subroutine 1
	brne 5f

	ldi r30, lo8(length_4)
	ldi r31, hi8(length_4)

4:
	andi r24, 0x0F				; Make sure r24 is between 0 and 0x0F
											
	add r30, r24	    			; Adding bit pattern in r24 to get the position
						; of the digit in the table

	lpm r24, Z				; Load to r24 the contents pointed by Z
	rjmp 6f		

5:
	ldi r24, _ERROR				; Load 7-segment character that represents an error

6:
	pop r31					; Restore used Z registers
	pop r30

	ret					; Return from subroutine


;;; This table stores the 7-segment representations for the digits
;;; We represent every character as a binary number where 0 is a dot
;;; and 1 is a dash eg. CHAR_O = 0111
;;; The binary representation is also the position of a character in the 
;;; table eg. CHAR_O: 0111 = 7, and is the 7th index position in its table 
length_1:
	.byte CHAR_E, CHAR_T

length_2:
	.byte CHAR_I, CHAR_A, CHAR_N, CHAR_M

length_3:
	.byte CHAR_S, CHAR_U, CHAR_R, CHAR_W
	.byte CHAR_D, CHAR_K, CHAR_G, CHAR_O

length_4:
	.byte CHAR_H, CHAR_V, CHAR_F, _ERROR
	.byte CHAR_L, _ERROR, CHAR_P, CHAR_J
	.byte CHAR_B, CHAR_X, CHAR_C, CHAR_Y
	.byte CHAR_Z, CHAR_Q, _ERROR, _ERROR
