TITLE: Programming Assignment 6A   (program6.asm)

; Author: Thanh Nguyen
; Course / Project ID  : CS271-P06a               Date: 3/4/18
; Description:
;	• Implement and test your own ReadVal and WriteVal procedures for unsigned integers.
;	• Implement macros getString and displayString. The macros may use Irvine’s ReadString to get input from
;	  the user, and WriteString to display output.
;			o getString should display a prompt, then get the user’s keyboard input into a memory location
;			o displayString should print the string which is stored in a specified memory location.
;			o readVal should invoke the getString macro to get the user’s string of digits. It should then 
;			  convert thedigit string to numeric, while validating the user’s input.
;			o writeVal should convert a numeric value to a string of digits, and invoke the displayString 
;			  macro toproduce the output.
;	• Write a small test program that gets 10 valid integers from the user and stores the numeric values in an
;	  array. The program then displays the integers, their sum, and their average.

; -----------------------------------------------------------------------------------------------------------

INCLUDE Irvine32.inc

ARRAYMAX = 10																												; Constant for size of array
STRMAX = 100																												; Constant for string size that user enters

; -----------------------------------------------------------------------------------------------------------

; Macros

; ********************************************************************************************************
; This macro is used when string parameters are passed to procedures and need to be printed.
; The value passed to the macro is the distance from ebp to the activation stack to access the variable.
; Parameter(s): Distance of string variable in system stack from ebp
; Register(s) used: edx
; Precondition: Register-indirect accessing mode is used in the procedure.
; ********************************************************************************************************

displayString MACRO buffer
	push	edx

	mov		edx, buffer							; Move address of string into edx
	call	WriteString							; Print the string

	pop		edx
ENDM

; ********************************************************************************************************
; This macro displays a prompt, then gets the user's keyboard input into a memory location.
; Parameter(s): 1) Distance of string message in system stack from ebp
;               2) Distance of string variable in system stack from ebp
; Register(s) used: eax, ecx, edx
; ********************************************************************************************************

getString MACRO buffer1, buffer2
	mov		edx, buffer1						; Move address of string into edx
	call	WriteString							; Print the string

	mov		edx, buffer2						; Move address of string into edx
	mov		ecx, STRMAX							; Prepare ecx to expected string input size
	call	ReadString							; Ask user to enter string
ENDM

; -----------------------------------------------------------------------------------------------------------

.data

; 1) Introduce the program

titleAndName	BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 0ah, 0dh
				BYTE	"Written by: Thanh Nguyen", 0ah, 0dh, 0ah, 0dh, 0												; Message with title of program and name of progammer

instructions	BYTE	"Please provide 10 unsigned decimal integers.", 0ah, 0dh
				BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0ah, 0dh
				BYTE	"After you have finished inputting the raw numbers I will display a list", 0ah, 0dh
				BYTE	"of the integers, their sum, and their average value.", 0ah, 0dh, 0ah, 0dh, 0					; Message with instructions of program for user

; 2) Prompt the user for numbers and store results in array

enterNum		BYTE	"Please enter an unsigned number: ", 0															; Message prompting user to enter a number
errorMess		BYTE	"ERROR: You did not enter an unsigned number or your number was too big.", 0ah, 0dh
				BYTE	"Please try again: ", 0																			; Error message with user input

inString		BYTE	STRMAX DUP(?)																					; String that user enters
userNum			DWORD	?																								; Variable to hold numeric value of user input
array			DWORD	ARRAYMAX DUP(?)																					; Create an array of DWORDs holding up to ARRAYMAX values
ctr				DWORD	0																								; Counter to check how many valid numbers have been entered

; 3) Calculate the sum and average of the numbers

sum				DWORD	0																								; Variable to hold the sum of the numbers
avg				DWORD	0																								; Variable to hold the average of the numbers

; 4) Display the numbers, their sum, and their average

dispNum			BYTE	"You entered the following numbers:", 0ah, 0dh, 0												; Message header for numbers user entered
sumMess			BYTE	"The sum of these numbers is: ", 0																; Message header for sum of numbers
avgMess			BYTE	"The average is: ", 0																			; Message header for average of numbers

outString		BYTE	STRMAX DUP(?)																					; String that holds the numbers after they are converted

; 5) Say goodbye to the user

byeMess			BYTE	"Thanks for playing!", 0ah, 0dh, 0ah, 0dh, 0													; Parting message to user

; -----------------------------------------------------------------------------------------------------------

.code
main PROC

; 1) Introduce the program

push	OFFSET titleAndName
push	OFFSET instructions
call	introduction

; 2) Prompt the user for numbers and store results in array

push	OFFSET enterNum
push	OFFSET errorMess
push	OFFSET inString
push	OFFSET userNum
push	OFFSET ctr
push	OFFSET array
call	getData

; 3) Calculate the sum and average of the numbers

push	OFFSET sum
push	OFFSET avg
push	OFFSET array
call	CalcSumAvg

; 4) Display the numbers, their sum, and their average

push	OFFSET dispNum
push	OFFSET sumMess
push	OFFSET avgMess
push	OFFSET outString
push	OFFSET userNum
push	OFFSET sum
push	OFFSET avg
push	OFFSET array
call	dispResults

; 5) Say goodbye to the user

push	OFFSET byeMess
call	ending

exit													; exit to operating system

main ENDP

; -----------------------------------------------------------------------------------------------------------

; ********************************************************************************************************
; This procedure writes strings to introduce the title of the program and the programmer's name.
; Receives: @titleAndName, @instructions 
; Returns: Message on screen
; Preconditions: None
; Registers changed: None
; ********************************************************************************************************

introduction	PROC
	push	ebp
	mov		ebp, esp

	displayString	[ebp+12]				; Display the title of the program and name of the programmer
	displayString	[ebp+8]					; Display the instructions to the user					

	pop		ebp
	ret		8
introduction	ENDP

; ********************************************************************************************************
; This procedure prompts the users for valid integers and stores them in an array.
; Receives: 1) @enterNum 2) @errorMess 3) @inString 4) @userNum 5) @ctr 6) @array
; Returns: A filled array
; Preconditions: None
; Registers changed: None
; ********************************************************************************************************

getData		PROC

	; Set up ebp
		push	ebp
		mov		ebp, esp

	; Save registers
		push	eax
		push	ebx
		push	ecx
		push	edx

	Beginning:
		mov		ebx, [ebp+12]				; Put @ctr into ebx
		mov		eax, [ebx]					; Get value of ctr into eax [eax = ctr]
		cmp		eax, 10	
		je		Done						; Check to see if ctr is equal to 10. It means we have obtained 10 valid numbers and are done.

	; Call ReadString (needs enter message, error message, inString, userNum) (returns userNum with the converted number)
		push	[ebp+28]					; @enterNum
		push	[ebp+24]					; @errorMess
		push	[ebp+20]					; @inString
		push	[ebp+16]					; @userNum
		call	ReadVal						; @userNum = converted number

	Store:
		mov		ebx, 4						; To multiply counter by since we are working with DWORDs
		mul		ebx							; (ctr * 4)
		
		mov		esi, [ebp+8]				; Get the address of array into esi
		add		esi, eax					; @array + (ctr * 4)

		mov		ecx, [ebp+16]				; ecx = @userNum
		mov		ebx, [ecx]					; ebx = userNum

		mov		[esi], ebx					; Store the number into the array

		mov		eax, 1						; To increase ctr
		mov		ebx, [ebp+12]				; ebx = @ctr
		add		[ebx], eax					; Increment the value the ctr variable

		jmp		Beginning					; Jump to the top of the loop. It exits at the top when ctr has reached 10

	Done:
		call	CrLf

		pop		edx
		pop		ecx
		pop		ebx
		pop		eax

		pop		ebp
		ret		24

getData		ENDP

; ********************************************************************************************************
; This procedure prompts the user for numbers using the getString macro to do so.
; It then converts the digit string to numeric, while validating the user's input.
; Receives: 1) @enterNum 2) @errorMess 3) @inString 4) @userNum
; Returns: A converted string converted a  number in the userNum variable
; Preconditions: None
; Registers changed: None
; ********************************************************************************************************

ReadVal		PROC

	; Set up ebp
		push	ebp
		mov		ebp, esp

	; Save registers
		push	eax
		push	ebx
		push	ecx
		push	edx

	GetNum:
		getString [ebp+20], [ebp+12]		; Display a prompt for user to enter number then ReadString. [eax = length, ecx = STRMAX, edx = OFFSET inString]

	AfterGetNum:
		mov		ecx, eax					; Store length of string into ecx
		mov		esi, [ebp+12]				; Store string address in source register
		cld									; Clear direction flag
		mov		ebx, 0						; ebx = x

	Conversion:
		push	ecx							; Save ecx for loop

		lodsb								; Moves byte at [esi] into AL register.
		cmp		al, 48
		jl		NotValid					; Check to see if character is an ascii value less than '0'
		cmp		al, 57
		jg		NotValid					; Check to see if character is an ascii value greather than '9'

		movzx	ecx, al						; str[k] into ecx
		sub		ecx, 48						; (str[k] - 48)
		
		push	ecx							; Save (str[k] - 48)
		mov		ecx, 10						; For multiplying (x * 10)
		mov		eax, ebx					; Put x into eax to multiply
		mul		ecx							; eax = (x * 10)
		jc		NotValidMul					; If the number is larger than unsigned 32-bit, then mark as not valid
		pop		ecx							; Restore (str[k] - 48)

		add		eax, ecx					; (x * 10) + (str[k] - 48)
		jc		NotValid					; If the number is larger than unsigned 32-bit, then mark as not valid
		mov		ebx, eax					; ebx = (x * 10) + (str[k] - 48)

		pop		ecx							; Restore ecx for loop counter
		loop	Conversion					; Keep converting string into number as long as there are digits to process

	StoreUserNum:
		mov		eax, [ebp+8]				; eax = @userNum
		mov		[eax], ebx					; Put converted number into userNum
		jmp		Done

	NotValidMul:							; Captures carry flag when multiplying eax above as part of equation
		pop		ecx							; Restore (str[k] - 48)

	NotValid:								; Captures negatives and non-numbers
		pop		ecx							; Restore ecx for loop counter
		getString [ebp+16], [ebp+12]		; User input was invald. Display error message and prompt 
		jmp		AfterGetNum					; Jump up to the top of the loop after the second getString macro

	Done:

		pop		edx
		pop		ecx
		pop		ebx
		pop		eax

		pop		ebp
		ret		16
ReadVal		ENDP

; ********************************************************************************************************
; This procedure displays the user's numbers, the sum, and their average.
; Receives: 1) dispNum 2) sumMess 3) avgMess 4) outString 5) userNum 6) sum 7) avg 8) array
; Returns: User's numbers to the screen and calculated numbers as well
; Preconditions: None
; Registers changed: None
; ********************************************************************************************************

dispResults	PROC
	
	; Prep ebp
		push	ebp
		mov		ebp, esp

	; Save registers
		push	eax
		push	ebx
		push	ecx
		push	edx

	PrintUserNum:
		displayString [ebp+36]					; Display header before listing out user's numbers
		mov		esi, [ebp+8]					; Get address of array into esi
		mov		ecx, 10							; To use to loop through array to get all numbers

	PrintArrayNum:
		mov		eax, [esi]					; Get the element of the array into eax
		mov		ebx, [ebp+20]				; ebx = @userNum
		mov		[ebx], eax					; userNum = Element of array

		push	[ebp+20]					; @userNum
		push	[ebp+24]					; @outString
		call	WriteVal					; Convert the number into a string and print it

		cmp		ecx, 1						; If this is the last value to print in the array
		je		NoCommaAndSpace				; Don't print a comma and space

	CommaAndSpace:
		mov		al, 44
		call	WriteChar					; Display a comma
		mov		al, 32
		call	WriteChar					; Display a space

	NoCommaAndSpace:
		add		esi, 4						; Increment esi to get the next value of array
		loop	PrintArrayNum				; Get the next number to print

	PrintSumNum:
		call	CrLf
		displayString [ebp+32]				; Display sum header
		push	[ebp+16]					; @sum
		push	[ebp+24]					; @outString
		call	WriteVal					; Display the sum
		call	CrLf

	PrintAvgNum:
		displayString [ebp+28]				; Display avg header
		push	[ebp+12]					; @svg
		push	[ebp+24]					; @outString
		call	WriteVal					; Display the average
		call	CrLf
		call	CrLf

	pop		edx
	pop		ecx
	pop		ebx
	pop		eax

	pop		ebp
	ret		32
dispResults	ENDP

; ********************************************************************************************************
; This procedure takes a number, converts it to the string, and prints the string.
; It uses the displayString macro to produce the output.
; Receives: 1) Numeric variable 2) @outString
; Returns: A printed string-number onto the screen.
; Preconditions: None
; Registers changed: None
; ********************************************************************************************************

WriteVal	PROC
	; Set up ebp
		push	ebp
		mov		ebp, esp

	; Save registers
		push	eax
		push	ebx
		push	ecx
		push	edx

	PreConvert:
		cld									; Sets df = 0. Causes esi and edi to be inc by lodsb and stosb. Move forward through array.

	ConvertNumStart:
		mov		ebx, [ebp+12]				; ebx = @userNum
		mov		eax, [ebx]					; Get the number into eax
		mov		edi, [ebp+8]				; Get the address of the string variable to place converted numbers into
		mov		ecx, 0						; Start of number of digits counter

	ConvertNumParse:
		mov		edx, 0						; For division. Remainder
		mov		ebx, 10						; To use for division by 10
		div		ebx							; Divide quotient and get remainder

		add		edx, 48						; Convert number to ascii
		push	edx							; Push digit onto stack to get back in reverse order
		inc		ecx							; Increment digit counter

		cmp		eax, 0						; Check to see if quotient is 0
		jne		ConvertNumParse				; If the quotient isn't 0, continue dividing the number and parsing the remainder
		
	ConvertNumStore:
		pop		eax							; Pop digits in reverse order so string is printed correctly
		stosb								; stosb for al into edi
		loop	ConvertNumStore				; Repeat for how many digits were counted

		mov		al, 0						; Add 0 character so program knows where to stop printing string
		stosb								; stosb for al into edi

	ConvertNumParseDone:
		displayString [ebp+8]				; Print the result

	pop		edx
	pop		ecx
	pop		ebx
	pop		eax

	pop		ebp
	ret		8
WriteVal	ENDP

; ********************************************************************************************************
; This procedure takes an array of integers and calculates the sum and average of the integers.
; Receives: 1) @sum 2) @avg 3) @array
; Returns: Calculated values into sum and avg variables
; Preconditions: None
; Registers changed: None
; ********************************************************************************************************

CalcSumAvg	PROC
	push	ebp
	mov		ebp, esp

	push	eax
	push	ebx
	push	ecx
	push	edx

	mov		esi, [ebp+8]					; Get the address of array into esi

	mov		ecx, 10							; Prepare ecx to loop through 10 values in array
	mov		eax, 0							; Initialize eax to 0, the accumulator

	CalcSum:
		mov		ebx, [esi]					; Get the current value of the array into ebx
		add		eax, ebx					; Add to the accumulator
		add		esi, 4						; Increment to next number in area
		loop	CalcSum						; Repeat for all 10 numbers in array

		mov		ebx, [ebp+16]				; Get address of sum variable into ebx
		mov		[ebx], eax					; Store sum in sum variable

	CalcAvg:
		mov		edx, 0						; Prep edx for division
		mov		ecx, 10						; To divide by 10
		div		ecx							; Divide the sum by 10
		mov		ebx, [ebp+12]				; Get the average variable into ebx
		mov		[ebx], eax					; Store the average into the average variable

	pop		edx
	pop		ecx
	pop		ebx
	pop		eax

	pop		ebp
	ret		12
CalcSumAvg	ENDP

; ********************************************************************************************************
; This procedure writes strings to introduce the title of the program and the programmer's name.
; Receives: @byeMess
; Returns: Message on screen
; Preconditions: None
; Registers changed: None
; ********************************************************************************************************

ending			PROC
	push	ebp
	mov		ebp, esp

	displayString	[ebp+8]					; Display a parting message to the user	

	pop		ebp
	ret		4
ending			ENDP

END main
