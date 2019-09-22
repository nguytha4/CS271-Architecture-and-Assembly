TITLE Programming Assignment #3     (program3.asm)

; Author: Thanh Nguyen
; Course / Project ID : CS271-P03                Date: 2/3/18
; Description:
;		1. Display the program title and programmer’s name.
;		2. Get the user’s name, and greet the user.
;		3. Display instructions for the user.
;		4. Repeatedly prompt the user to enter a number. Validate the user input to be in [-100, -1] (inclusive). 
;			Count and accumulate the valid user numbers until a non-negative number is entered. (The non-negative number is discarded.)
;		5. Calculate the (rounded integer) average of the negative numbers.
;		6. Display:
;			i. the number of negative numbers entered (Note: if no negative numbers were entered, display a special message and skip to iv.)
;			ii. the sum of negative numbers entered
;			iii. the average, rounded to the nearest integer (e.g. -20.5 rounds to -20)
;			iv. a parting message (with the user’s name)

; -----------------------------------------------------------------------------------------------------------

INCLUDE Irvine32.inc

numCeiling = -1																										; Constant for greatest number user can enter
numFloor = -100																										; Constant for lowest number user can enter

; -----------------------------------------------------------------------------------------------------------

.data

; 1. Display the program title and programmer’s name.

progTitle	BYTE	"Welcome to the Integer Accumulator by Thanh Nguyen", 0dh, 0ah, 0								; Program Title																				; Variable for user's name

; 2. Get the user’s name, and greet the user.

askName		BYTE	"What is your name? ", 0																		; Ask for user's name
userName	BYTE	33 DUP(0)																						; Variable for user's name
hello		BYTE	"Hello, ", 0

; 3. Display instructions for the user.

instruc		BYTE	"Please enter numbers in [-100, -1].", 0dh, 0ah													; Display instructions to user
			BYTE	"Enter a non-negative number when you are finished to see results.", 0dh, 0ah, 0

; 4. Repeatedly prompt the user to enter a number. Validate the user input to be in [-100, -1] (inclusive). 
;		Count and accumulate the valid user numbers until a non-negative number is entered. (The non-negative number is discarded.)

enterNum	BYTE	"Enter number: ", 0																				; Ask user to enter number
outOfRange	BYTE	"Error. Enter a number [-100, -1].", 0dh, 0ah, 0												; Display error is user enters a number out of range
userNum		DWORD	?																								; Variable to store number that user enters
accum		DWORD	?																								; Accumulator variable
ctr			DWORD	?																								; Counter variable to store amount of integers entered

; 5. Calculate the (rounded integer) average of the negative numbers.

avg			DWORD	?																								; Variable to hold the average

; 6. Display:
;	i. the number of negative numbers entered (Note: if no negative numbers were entered, display a special message and skip to iv.)
;	ii. the sum of negative numbers entered
;	iii. the average, rounded to the nearest integer (e.g. -20.5 rounds to -20)
;	iv. a parting message (with the user’s name)

noNegMess	BYTE	"You entered no valid numbers for this program.", 0ah, 0dh, 0									; Display special message if user doesn't enter any negative numbers
enterMess	BYTE	"You entered ", 0																				; Display first half of message of how many numbers user entered
enterMess2	BYTE	" valid numbers.", 0																			; Display second half of message of how many numbers user entered
sumMess		BYTE	"The sum of your valid numbers is ", 0															; Display sum message
rAvgMess	BYTE	"The rounded average is ", 0																	; Display rounded average message
endMess		BYTE	"Thank you for playing Integer Accumulator! It's been a pleasure to meet you, ", 0				; Final message to user

; Extra Credit
; 1. Number the lines during user input.
; 3. Do something astoundingly creative.

EC1mess		BYTE	"**EC: This program numbers the lines during user input.", 0ah, 0dh, 0							; Extra credit #1 message
lineCtr		DWORD	?																								; Variable to store / display the number of lines during user input
dotSpace	BYTE	". ", 0																							; Period and space characters to display after line number

EC3mess		BYTE	"**EC: This program does something astoundingly creative.", 0ah, 0dh, 0							; Extra credit #3 message
haiku		BYTE	"I like assembly", 0ah, 0dh
			BYTE	"Because it is riveting", 0ah, 0dh
			BYTE	"Enjoy this haiku", 0																			; A haiku for extra credit

; -----------------------------------------------------------------------------------------------------------

.code
main PROC

; Extra credit #3. Do something astoundingly creative

	mov		edx, OFFSET haiku
	call	MsgBoxAsk														; Display a haiku pop-up message for the user

; 1. Display the program title and programmer’s name.

	mov		edx, OFFSET progTitle
	call	WriteString														; Display the title / programmer's name
	mov		edx, OFFSET	EC1mess
	call	WriteString														; Display the message for extra credit #1
	mov		edx, OFFSET EC3mess
	call	WriteString														; Display the message for extra credit #3
	call	CrLf

; 2. Get the user’s name, and greet the user.

	mov		edx, OFFSET askName
	call	WriteString														; Ask for the user's name
	mov		edx, OFFSET userName
	mov		ecx, 32
	call	ReadString														; Store user's name
	mov		edx, OFFSET hello
	call	WriteString														; Greet the user
	mov		edx, OFFSET userName
	call	WriteString														; Address the user after greeting
	call	CrLf
	call	CrLf

; 3. Display instructions for the user.

	mov		edx, OFFSET instruc
	call	WriteString														; Display instructions to user

; 4. Repeatedly prompt the user to enter a number. Validate the user input to be in [-100, -1] (inclusive). 
;		Count and accumulate the valid user numbers until a non-negative number is entered. (The non-negative number is discarded.)

	mov		accum, 0														; Initialize accumulator variable to 0
	mov		ctr, -1															; Initialize number of entered numbers to -1 (it gets incremented at start of GetNumAgain loop)
	mov		lineCtr, 0														; Initialize the number of lines to display during user input to 0
	jmp		GetNumAgain														; Jump to loop to obtain user input

BelowRange:																	; Only jump into here if user enters a number below the specified limit. Decrement the counter so average stays correct
	mov		edx, OFFSET outOfRange
	call	WriteString														; Display a message letting the user know they entered a number out of range
	dec		ctr																; Decrement the number of numbers entered
	dec		lineCtr															; Decrement the line number counter

GetNumAgain:																; Loop to continually ask for negative numbers from user
	inc		ctr																; Increment the number of entered numbers to 0
	inc		lineCtr															; Increment the number of lines that user has entered
	mov		eax, lineCtr
	call	WriteDec														; Display the line number
	mov		edx, OFFSET dotSpace
	call	WriteString														; Display a period and space after the number
	mov		edx, OFFSET enterNum
	call	WriteString														; Ask user to enter number
	call	ReadInt															; Store user's number

	cmp		eax, numCeiling													; Check user input to highest number program allows
	jg		CalcAvg															; Jump out to calculate avg. if number is above upper limit
	cmp		eax, numFloor													; Check user input to lowest number program allows
	jl		BelowRange														; Jump to front of loop to decrement counter if number is below range

	add		accum, eax														; Add to the accumulator to keep track of running total
	jmp		GetNumAgain														; Jump to the beginning of the loop to obtain more user input

; 5. Calculate the (rounded integer) average of the negative numbers.

CalcAvg:																	; Loop to calculate the average of the numbers that the user entered
	cmp		ctr, 0															; Check to see if the number of entered terms is 0
	je		NoNeg															; Jump to special message if user entered no valid terms
	mov		edx, 0															; Set edx to 0 for remainder purposes before division
	mov		eax, accum
	neg		eax																; Take the complement of the accumulator
	div		ctr																; Divide the sum by the number of terms
	mov		avg, eax

; 6. Display:
;	i. the number of negative numbers entered (Note: if no negative numbers were entered, display a special message and skip to iv.)
;	ii. the sum of negative numbers entered
;	iii. the average, rounded to the nearest integer (e.g. -20.5 rounds to -20)
;	iv. a parting message (with the user’s name)

	mov		edx, OFFSET enterMess
	call	WriteString														; Display that the user entered an amount of numbers
	mov		eax, ctr
	call	WriteDec														; Display the amount of numbers that the user entered
	mov		edx, OFFSET enterMess2
	call	WriteString														; Display the second half of the message

	call	CrLf

	mov		edx, OFFSET sumMess	
	call	WriteString														; Display the message that shows the sum of the user's numbers
	mov		al, '-'
	call	WriteChar														; Make sure to add a negative sign
	mov		eax, accum
	neg		eax																; Take complement of the sum
	call	WriteDec														; Display the sum

	call	CrLf

	mov		edx, OFFSET	rAvgMess
	call	WriteString														; Display the message that shows the average of the user's numbers
	mov		al, '-'															; Make sure to add a negative sign
	call	WriteChar
	mov		eax, avg
	call	WriteDec														; Display the average


	call	CrLf
	jmp		Finale															; Jump to the parting message and skip the special message

NoNeg:
	mov		edx, OFFSET noNegMess
	call	WriteString														; Tell the user that they entered no valid numbers

Finale:
	mov		edx, OFFSET endMess
	call	WriteString														; Display the parting message to the user
	mov		edx, OFFSET userName
	call	WriteString														; Display the user's name
	call	CrLf
	call	CrLf

; -----------------------------------------------------------------------------------------------------------

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
