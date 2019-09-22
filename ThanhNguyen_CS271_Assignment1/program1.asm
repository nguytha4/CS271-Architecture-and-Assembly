TITLE: Programming Assignment #1     (program1.asm)

; Author: Thanh Nguyen
; Course / Project ID : CS271-P01              Date: 1/19/18
; Description: Program that:
;				1) Displays name of creator and program title to the output screen. 
;				2) Displays instructions for the user.
;				3) Prompt the user to enter two numbers.
;				4) Calculate the sum, difference, product, (integer) quotient and remainder of the numbers.
;				5) Display a terminating message. 

; -----------------------------------------------------------------------------------------------------------

INCLUDE Irvine32.inc

; (insert constant definitions here)

; -----------------------------------------------------------------------------------------------------------

.data

; 1) Display the introduction (name and title of program)

intro			BYTE	"    The Four Fundamentals of Math    by Thanh Nguyen", 0								; 1a. Introduction variable (string)
EC1				BYTE	"**EC1: Program repeats until the user choose with quit (with '1' or '0' input).", 0	; 1b. EC1 description (string)
EC2				BYTE	"**EC2: Program verifies second number less than first.", 0								; 1c. EC2 description (string)
EC3				BYTE	"**EC3: Program calculates / displays quotient as a floating-point number.", 0			; 1d. EC3 description (string)

; 2) Get the data from the user

explain1		BYTE	"Enter 2 numbers, and I'll show you the sum, difference,", 0							; 2a. Explanation variable (string)
explain2		BYTE	"product, quotient, and remainder.", 0								
firNumMes		BYTE	"First number: ", 0																		; 2b. First number prompt (string)
secNumMes		BYTE	"Second number: ", 0																	; 2c. Second number prompt (string)
firNum			DWORD	?																						; 2d. First number variable (int)
secNum			DWORD	?																						; 2e. Second number variable (int)

; 2.5) Validate the second number to be less than the first

valid			BYTE	"The second number must be less that the first!", 0										; 2.5a Prompt explaination validation (string)

; 3) Calculate the required values

sum				DWORD	?																						; 3a. Sum (int)
diff			DWORD	?																						; 3b. Diff (int)
prod			DWORD	?																						; 3c. Prod (int)
quot			DWORD	?																						; 3d. Quot (int)
remain			DWORD	?																						; 3e. Remain (int)

; 4) Display the results

plusSym			BYTE	" + ", 0																				; 4a. Plus symbol (string)
minusSym		BYTE	" - ", 0																				; 4b. Minus symbol (string)
multSym			BYTE	" x ", 0																				; 4c. Mult symbol (string)
divSym			BYTE	" / ", 0																				; 4d. Divide symbol (string)
remainMes		BYTE	" remainder ", 0																		; 4e. Remainder message (string)
eqSym			BYTE	" = ", 0																				; 4f. Equals symbol (string)

; 4.5) Repeat until user chooses to quit

again			BYTE	"Again? (1 for yes / 0 for no): ", 0													; 4.5a Prompt to keep going (string)
yesComp			DWORD	1																						; 4.5b '1' character to use for compare (string)
useInp			DWORD	?																						; 4.bc Integer to be entered by user for looping (string)

; 5) Say goodbye

outro			BYTE	"Hasta la vista, baby.", 0																; 5a. Outro variable (string)

; -----------------------------------------------------------------------------------------------------------

.code
main PROC

; 1) Display the introduction and extra credit (name and title of program)
	mov		edx, OFFSET intro		
	call	WriteString					; Display the introduction
	call	CrLf
	mov		edx, OFFSET EC1
	call	WriteString					; Display the message for extra credit #1
	call	CrLf
	mov		edx, OFFSET EC2			
	call	WriteString					; Display the message for extra credit #2
	call	CrLf

; 2) Get the data from the user

beginning:								; Label to mark start of program for jump to for looping
	call	CrLf
	mov		edx, OFFSET explain1
	call	WriteString					; Display the explanation of the program to the user
	call	CrLf
	mov		edx, OFFSET explain2		
	call	WriteString					; Display the explanation of the program to the user
	call	CrLf
	call	CrLf
	mov		edx, OFFSET firNumMes
	call	WriteString					; Display the prompt for the first number
	call	ReadInt						; Take user input for the first number
	mov		firNum, eax
	mov		edx, OFFSET secNumMes
	call	WriteString					; Display the prompt for the second number
	call	ReadInt						; Take user input for the second number
	mov		secNum, eax
	call	CrLf
	cmp		eax, firNum					; Check to see if the second number is greater than the first
	jg		validate					; Jump to the validation portion below to inform user that second number is larger than first
	jmp		operations					; Jump to operations portion (past validation) to run arithmetic operations

; 2.5) Validate the second number to be less than the first

validate:								; Label to jump to when user enters second number larger than first
	mov		edx, OFFSET valid
	call	WriteString					; Let user know that second number must be greater than the first
	call	CrLf
	call	CrLf
	jmp		finale						; Jump past the operations portion to looping portion

; 3) Calculate the required values

operations:								; Label to jump to start arithmetic operations
;	3a) Calculate sum
	mov		eax, firNum
	add		eax, secNum					; Add the first and second numbers
	mov		sum, eax

;	3b) Calculate difference
	mov		eax, firNum
	sub		eax, secNum					; Subtract the first and second numbers
	mov		diff, eax

;	3c) Calculate product
	mov		eax, firNum
	mov		ebx, secNum
	mul		ebx							; Multiply the first and second numbers
	mov		prod, eax

;	3d) Calculate quotient and remainder
	mov		edx, 0						; Initialize edx to 0 to prevent problems with division
	mov		eax, firNum
	mov		ebx, secNum
	div		ebx							; Divide the first and second numbers
	mov		quot, eax
	mov		remain, edx					; Make sure to grab remainder	

; 4) Display the results

;	4a) Display sum
	mov		eax, firNum
	call	WriteDec					
	mov		edx, OFFSET plusSym
	call	WriteString
	mov		eax, secNum
	call	WriteDec
	mov		edx, OFFSET eqSym
	call	WriteString
	mov		eax, sum
	Call	WriteDec					; Display numbers and their sum
	call	CrLf

;	4b) Display difference
	mov		eax, firNum
	call	WriteDec
	mov		edx, OFFSET minusSym
	call	WriteString
	mov		eax, secNum
	call	WriteDec
	mov		edx, OFFSET eqSym
	call	WriteString
	mov		eax, diff
	Call	WriteDec					; Display numbers and their difference
	call	CrLf

;	4c) Display product
	mov		eax, firNum
	call	WriteDec
	mov		edx, OFFSET multSym
	call	WriteString
	mov		eax, secNum
	call	WriteDec
	mov		edx, OFFSET eqSym
	call	WriteString
	mov		eax, prod
	Call	WriteDec					; Display numbers and their product
	call	CrLf

;	4d)	Display quotient
	mov		eax, firNum
	call	WriteDec
	mov		edx, OFFSET divSym
	call	WriteString
	mov		eax, secNum
	call	WriteDec
	mov		edx, OFFSET eqSym
	call	WriteString
	mov		eax, quot
	Call	WriteDec
	mov		edx, OFFSET remainMes
	call	WriteString
	mov		eax, remain
	call	WriteDec					; Display numbers, their quotient, and remainder
	call	CrLf
	call	CrLf

; 4.5) Repeat until user chooses to quit
finale:									; Label to jump to for looping the program based on user input
	mov		edx, OFFSET again
	call	WriteString					; Display message asking user if they want to loop
	call	ReadInt						; Take user input for looping
	mov		useInp, eax
	cmp		eax, yesComp				; Compare to see if user input matches '1' to indicate yes
	je		beginning					; Jump back to the beginning of the the program if user indicated yes

; 5) Say goodbye
	call	CrLf
	mov		edx, OFFSET outro
	call	WriteString					; Display the goodbye message to the user
	call	CrLf
	call	CrLf

; -----------------------------------------------------------------------------------------------------------

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
