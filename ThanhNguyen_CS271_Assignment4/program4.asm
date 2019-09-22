TITLE Programming Assignment #4     (program4.asm)

; Author: Thanh Nguyen
; Course / Project ID : CS271-P04                Date: 2/13/18
; Description:
;		1. Display the program title and the programmer's name
;		2. Display the instructions for the user.
;		3. Repeatedly prompt the user to enter a number. Validate the user input to be in [1, 400] (inclusive).
;		4. Calculate the display the composite numbers, showing 10 per line.
;		5. Display a parting message to the user.

; -----------------------------------------------------------------------------------------------------------


INCLUDE Irvine32.inc

numCeiling = 400																								; Constant for greatest number user can enter
numFloor = 1																									; Constant for lowest number user can enter

; -----------------------------------------------------------------------------------------------------------


.data

; 1. Display the program title and the programmer's name
; 2. Display the instructions for the user.

progTitle	BYTE	"Composite Numbers       Programmed by Thanh Nguyen", 0ah, 0dh, 0							; Program title and programmer's name variable
instruc		BYTE	"Enter the number of composite numbers you would like to see.", 0ah, 0dh
			BYTE	"I'll accept orders for up to 400 composites.", 0ah, 0dh, 0									; Instruction message variable

; 3. Repeatedly prompt the user to enter a number. Validate the user input to be in [1, 400] (inclusive).

enterNum	BYTE	"Enter the number of composites to display [1 .. 400] : ", 0								; Message asking user to enter a number
outRange	BYTE	"Out of range.  Try again.", 0ah, 0dh, 0													; Message user know that their number is out of range
userNum		DWORD	?

; 4. Calculate the display the composite numbers, showing 10 per line.

compTest	DWORD	1																							; Variable to use to test if number is composite
spaces		BYTE	"   ", 0																					; Three spaces to separate composite numbers
newLineChk	DWORD	0																							; Variable to hold number of terms on line to track when to add new line
twoNum		DWORD	2																							; Variable to hold the number 2 to use in calculations
threeNum	DWORD	3																							; Variable to hold the number 3 to use in calculations
forI		DWORD	?																							; Represents the for-loop counter (e.g. int i) used in high-level languages
forISqua	DWORD	?																							; Represents the for-loop counter squared
forIPlusTwo	DWORD	?																							; Represents the for-loop counter plus two


; 5. Display a parting message to the user.

goodbye		BYTE	"Results certified by Thanh Nguyen.    Goodbye.", 0ah, 0dh, 0								; Parting message variable

; Extra Credit

EC1			BYTE	"**EC: This program aligns the output columns.", 0dh, 0ah, 0								; Extra credit #1 message

; -----------------------------------------------------------------------------------------------------------


.code
main PROC

call	introduction							; Display the title of the program and instructions for user
call	getUserData								; Ask user to enter number
call	showComposites							; Display the list of composite numbers up to the number that the user input
call	farewell								; Display parting message to user
exit											; exit to operating system

main ENDP

; -----------------------------------------------------------------------------------------------------------

introduction PROC
	mov		edx, OFFSET progTitle
	call	WriteString							; Display the title of the program and the programmer's name
	mov		edx, OFFSET EC1
	call	WriteString							; Display the extra credit #1 message
	call	CrLf
	mov		edx, OFFSET instruc
	call	WriteString							; Display instructions for the user
	call	CrLf
	ret
introduction ENDP

; --------------------------------------

getUserData PROC
	mov		edx, OFFSET enterNum
	call	WriteString							; Display message asking user to enter number
	call	ReadInt								; Take user input
	call	validate							; Call sub-procedure to check if user input is valid
	mov		userNum, eax						; If validate sub-procedure deems user input is valid, store it in userNum
	ret
getUserData	ENDP

; --------------------------------------

validate PROC
	cmp		eax, numCeiling
	jg		Invalid								; Jump to the invalid label of this sub-procedure if user input is greater than the specified ceiling
	cmp		eax, numFloor
	jl		Invalid								; Jump to the invalid label of this sub-procedure if user input is less than the specified floor
	jmp		Valid								; Jump to the valid label of this sub-procedure if user input is valid

	Invalid:
		mov		edx, OFFSET outRange
		call	WriteString						; Display message to user letting them know their number is out of range
		call	getUserData						; Call getUserData procedure to get user input again

	Valid:
		ret
validate ENDP

; --------------------------------------

showComposites PROC
	
	mov		ecx, userNum						; Initialize ecx to the number of terms user input for LOOP instruction

	PrintComposite:
		call	isComposite						; Call isComposite sub-procedure to return ebx 1 or 0 to see if current number is composite
		cmp		ebx, 1
		je		Print							; If ebx was set to 1, jump to the Print label to proceed to print the current composite number
		jmp		AfterPrint						; Else, the number is not composite. Jump to the AfterPrint label

	Print:
		mov		eax, compTest
		call	WriteDec						; Display compTest's current value. Note that compTest is a value that starts at 1 and increments to userNum
		mov		al, 9
		call	WriteChar						; Display a tab
		inc		newLineChk						; Increment the variable holding the number of terms displayed
		cmp		newLineChk, 10
		je		NewLine							; Jump to the NewLine label if the number of terms on a line has reacheed 10
		jmp		AfterPrint						; Else, continue to the AfterPrint label

	NewLine:
		call	CrLf							; Display a newline
		mov		newLineChk, 0					; Reinitialize the number of terms on a line to 0

	AfterPrint:
		inc		compTest						; Increment the current composite number to check by 1
		loop	PrintComposite					; Loop to the top of PrintComposite as long as we haven't reached userNum
		ret
showComposites ENDP

; --------------------------------------

isComposite PROC

	cmp		compTest, 1	
	jle		CompositeFalse						; If the number being checked is less than or equal to 1, jump to the CompositeFalse label
	cmp		compTest, 3
	jle		CompositeFalse						; If the number being checked is less than or equal to 3, jump to the CompositeFalse label

	mov		edx, 0								; Move 0 into edx to prepare for division/modulus

	mov		eax, compTest
	div		twoNum								; Divide the number being checked by 2 for purposes of modulus
	cmp		edx, 0
	je		CompositeTrue						; If there is no remainder, jump to the CompositeTrue label

	mov		edx, 0								; Move 0 into edx to prepare for division/modulus

	mov		eax, compTest
	div		threeNum							; Divide the number being checked by 3 for purposes of modulus
	cmp		edx, 0
	je		CompositeTrue						; If there is no remainder, jump to the CompositeTrue label

	mov		forI, 5								; Set the for-loop counter (i) variable to 5

	CompositeLoop:
		mov		eax, forI
		mul		forI
		mov		forISqua, eax					; Initialize the forISqua (i * i) variable to the square of the for-loop variable for for-loop boundary checking
		cmp		eax, compTest
		jg		CompositeFalse					; If (i * i) > n, jump out of this loop and deem the number not a composite number

		mov		edx, 0							; Move 0 into edx to prepare for division/modulus

		mov		eax, compTest
		div		forI							; Divide the number being checked by i
		cmp		edx, 0
		je		CompositeTrue					; If there is no remainder, jump to the CompositeTrue label

		mov		edx, 0							; Move 0 into edx to prepare for division/modulus
		
		mov		eax, compTest
		mov		ebx, forI
		mov		forIPlusTwo, ebx
		add		forIPlusTwo, 2					; Initialize forIPlusTwo (i + 2) by adding 2 to i
		div		forIPlusTwo						; Divide the number being checked by (i + 2)
		cmp		edx, 0
		je		CompositeTrue					; If there is no remainder, jump to the CompositeTrue label

		add		forI, 6							; Add 6 to i
		jmp		CompositeLoop					; Jump to the beginning of the CompositeLoop check label

	jmp		CompositeFalse						; Else, once the "for-loop" finishes and exits, jump to the CompositeFalse label
	
	CompositeTrue:
		mov		ebx, 1							; Set ebx to 1 to denote that the number is composite
		jmp		Done							; Jump to the end of this sub-procedure to return
	
	CompositeFalse:
		mov		ebx, 0							; Set ebx to 0 to denote that the number is not composite
	
	Done:
		ret
isComposite ENDP

; --------------------------------------

farewell PROC
	call	CrLf
	call	CrLf
	mov		edx, OFFSET goodbye
	call	WriteString						; Display parting message to user
	call	CrLf
	ret
farewell ENDP

END main