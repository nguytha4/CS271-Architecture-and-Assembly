TITLE Programming Assignment #2     (program2.asm)

; Author: Thanh Nguyen
; Course / Project ID : CS271-P02                Date: 1/25/18
; Description: 
;		• Display the program title and programmer’s name. Then get the user’s name, and greet the user.
;		• Prompt the user to enter the number of Fibonacci terms to be displayed. 
;				Advise the user to enter an integer in the range [1 .. 46].
;		• Get and validate the user input (n).
;		• Calculate and display all of the Fibonacci numbers up to and including the nth term. 
;				The results should be displayed 5 terms per line with at least 5 spaces between terms.
;		• Display a parting message that includes the user’s name, and terminate the program.

; -----------------------------------------------------------------------------------------------------------

INCLUDE Irvine32.inc

termsFloor = 1																								; Constant for lowest value user can enter for Fibo. term
termsCeiling = 46																							; Constant for greatest value user can enter for Fibo. term
newLineLimit = 5																							; Constant for when to create a newline after a certain amount of terms.

; -----------------------------------------------------------------------------------------------------------

.data

; 1) Display the program title and the programmer's name

titleAndName	BYTE	"Fibonacci Numbers", 0dh, 0ah														; Program title and programmer's name
				BYTE	"Programmed by Thanh Nguyen", 0dh, 0ah, 0

; 2) Get the user's name and greet the user

askName			BYTE	"What's your name? ", 0																; Prompt asking user for name
userName		BYTE	33 DUP(0)																			; Variable to hold user's name
greeting		BYTE	"Hello, ", 0																		; Greeting to greet user

; 3) Provide instruction prompt asking user for number of Fibonacci terms in range of 1-46. 
;		Get and validate user input.

instruction		BYTE	"Enter the number of Fibonacci terms to be displayed", 0dh, 0ah						; Instruction Prompt asking for Fibo. terms and
				BYTE	"Give the number as an integer in the range [1 .. 46].", 0dh, 0ah, 0dh, 0ah, 0		;	specifying acceptable range for input
termsPrompt		BYTE	"How many Fibonacci terms do you want? ", 0											; Prompt asking user to enter value 
terms			DWORD	?																					; Variable to hold terms value that user enters

; 4) Calculate and display Fibonacci numbers. Display 5 terms per line with at least 5 spaces in between.

newLineChk		DWORD	?																					; Variable to keep track of how many terms on a line. Create newline when 5 terms are on a line
preTerm			DWORD	?																					; Previous Fibo. number
currTerm		DWORD	?																					; Current Fibo. number

spaces			BYTE	"     ", 0																			; 5 spaces for separating terms

; 5) Display a parting message that includes the user’s name, and terminate the program.

exitMess		BYTE	"Results certified by Thanh Nguyen.", 0dh, 0ah, 0									; Exit message, say goodbye to user and add period
exitMess2		BYTE	"Goodbye, ", 0
period			BYTE	".", 0dh, 0ah, 0

; EC1: Display the numbers in aligned columns

EC1mess			BYTE	"**EC1: This program displays the Fibonacci number results in aligned columns", 0	; Message to grader informing them that EC1 has been completed
rowCt			DWORD	?																					; Variable to hold number of rows to add correct number of tabs for Extra Credit
tabVerif		DWORD	?																					; Boolean to check label jumping for adding tab for Extra Credit

; EC2: Prompt user for a number and inform them if it is a Fibonacci number

EC2mess			BYTE	"**EC2: This program can check to see if a user's number is a Fibonacci number", 0	; Message to grader informing them that EC2 has been completed
chkFibMess		BYTE	"Want to see something incredible? (enter 1 for yes and 0 for no) : ", 0			; Message to user optionally giving them to the choice to check a number if it is a Fibo. number
inputYes		DWORD	1																					; Variable to use to as TRUE for boolean check
chkNumMess		BYTE	"Enter a number to check if it is a Fibonacci number: ", 0							; Message to check which number user wants to check if it is a Fibo. number
chkFibNum		DWORD	?																					; Number to check if it is a Fibo. number
yesFibMess		BYTE	"Yes! This number is a Fibonacci number!", 0										; Message telling user that number is a Fibo. number
noFibMess		BYTE	"No. This number is not a Fibonacci number.", 0										; Message telling user that number is not a Fibo. number
EC2againMess	BYTE	"Would you like to check another number? (enter 1 for yes and 0 for no) : ", 0		; Prompt user if they want to check another number

; -----------------------------------------------------------------------------------------------------------

.code
main PROC

; 1) Display the program title and the programmer's name

	mov		edx, OFFSET titleAndName			
	call	WriteString							; Display the title of the program and programmer's name
	call	CrLf
	mov		edx, OFFSET EC1mess
	call	WriteString							; Display the Extra Credit 1 message
	call	CrLf
	mov		edx, OFFSET EC2mess
	call	WriteString							; Display the Extra Credit 2 message
	call	CrLf
	call	CrLf

; 2) Get the user's name and greet the user

	mov		edx, OFFSET askName
	call	WriteString							; Display prompt asking for user's name
	mov		edx, OFFSET userName
	mov		ecx, 32
	call	ReadString							; Take string that user inputs for their name
	mov		edx, OFFSET greeting
	call	WriteString							; Display a greeting message to user
	mov		edx, OFFSET userName
	call	WriteString							; Display the user's name after the greeting
	call	CrLf
	call	CrLf

; 2.5) EC2: Ask the user if they want to check if their number is a Fibonacci number

	mov		edx, OFFSET chkFibMess
	call	WriteString							; Provide user option to try Extra Credit 2 option
	call	ReadInt								; Take user input
	call	CrLf
	cmp		eax, inputYes
	jne		Usual								; If no, proceed with program as normal (display Fibo. numbers)

EC2:											; Label to mark beginning of loop if user wants to check a number again
	mov		edx, OFFSET chkNumMess
	call	WriteString							; Ask user which number they want to check
	call	ReadInt								; Take user input
	mov		chkFibNum, eax						; Store user input in variable

	mov		terms, 46							; Check all 46 Fibonacci terms
	mov		preTerm, 0							; Initialize preTerm to 0
	mov		currTerm, 1							; Initialize currTerm to 1
	dec		terms								; Decrement the number of terms by 1 (the first Fibo. number is always 1 so no need to calc)
	mov		ecx, terms							; Set ecx to the number of terms for the loop instruction

FibonacciCalc:
	mov		eax, preTerm
	mov		ebx, currTerm
	add		eax, ebx							; Add preTerm to currTerm
	cmp		chkFibNum, eax						; Check to see if user's number is a Fibo. number
	je		YesFib								; Jump to label to tell user their number is a Fibo. number
	mov		preTerm, ebx						; Set preTerm to currTerm
	mov		currTerm, eax						; Set currTerm to the Fibo. number we just calculated
	loop	FibonacciCalc						; Loop to the beginning if there are still terms to calculate

	mov		edx, OFFSET noFibMess
	call	WriteString							; All numbers exhausted. Inform user their number is not a Fibo. number
	call	CrLf
	call	CrLf
	mov		edx, OFFSET EC2againMess
	call	WriteString							; Ask user if they want to try a different number
	call	ReadInt								; Take user input
	call	CrLf
	cmp		eax, inputYes
	je		EC2									; Prompt user for new number at top of this loop if yes
	jmp		Finale								; Otherwise jump to the end

YesFib:											; User number was found to be a Fibo. number
	mov		edx, OFFSET yesFibMess
	call	WriteString							; Let user know that their number is a Fibo. number
	call	CrLf
	call	CrLf
	mov		edx, OFFSET EC2againMess
	call	WriteString							; Ask user if they want to try a different number
	call	ReadInt								; Take user input
	call	CrLf
	cmp		eax, inputYes
	je		EC2									; Prompt user for new number at top of this loop if yes
	jmp		Finale								; Otherwise jumpt to the end

; 3) Provide instruction prompt asking user for number of Fibonacci terms in range of 1-46. 
;		Get and validate user input (use post-test loop).

Usual:
	mov		edx, OFFSET instruction
	call	WriteString							; Display prompt providing user with instructions

enterNum:										; Ask for and take user input while integer is less than 1 or greater than 46
	mov		edx, OFFSET termsPrompt
	call	WriteString							; Display prompt asking user to enter the number of terms
	call	ReadInt								; Take in user's input as an int
	cmp		eax, termsFloor
	jl		enterNum							; Prompt user to enter in number again if it is less than 1
	cmp		eax, termsCeiling
	jg		enterNum							; Prompt user to enter in number again if it is greater than 46
	mov		terms, eax

; 4) Calculate and display Fibonacci numbers. Display 5 terms per line with at least 5 spaces in between.
	
	call	CrLf
	mov		preTerm, 0							; Initialize preTerm to 0
	mov		currTerm, 1							; Initialize currTerm to 1
	mov		newLineChk, 0						; Initialize number of terms on a line to 0
	mov		rowCt, 1							; Initialize number of rows to 1
	mov		tabVerif, 0							; Initialize the need to add another tab to 0
	dec		terms								; Decrement the number of terms by 1 (the first Fibo. number is always 1 so we display it instead of calculating in a loop)
	mov		ecx, terms							; Set ecx to the number of terms for the loop instruction
	mov		eax, currTerm
	call	WriteDec							; Display the first Fibo. number
	mov		al, 9								; ASCII character for tab
	call	WriteChar							; Add tab
	call	WriteChar							; Add tab
	jmp		Fibonacci							; Jump into the Fibonacci loop to calculate the Fibo. numbers (need to skip the newline loop; only enter if Fibonacci calls it)

AddTab:											; Section for adding an additional tab for rows 1-7
	mov		al, 9								; ASCII character for tab
	call	WriteChar							; Add tab
	mov		tabVerif, 0							; Set the flag to go check for adding a new tab to false
	jmp		Fibonacci							; Jump back to Fibonacci calculations

RowCheck:										; Section to check if a new tab is needed to be added
	cmp		rowCt, 8							; Check to see if the row count is less than 8
	jl		AddTab								; Jump to label to add a new tab
	mov		tabVerif, 0							; Set the flag to go check for adding a new tab to false
	jmp		Fibonacci							; Jump back to Fibonacci calculations

NewLine:										; For the purposes of creating a newline and resetting number of terms on a line
	call	CrLf
	inc		rowCt
	mov		newLineChk, -1						; Reset the numbers of terms to -1 as we increment after we enter the Fibonacci loop

Fibonacci:
	cmp		tabVerif, 1							; Check flag to see if adding additional tab is necessary
	je		RowCheck							; Go to RowCheck to start tab checking process
	inc		newLineChk							; Increment the number of terms on a line
	cmp		newLineChk, newLineLimit
	je		NewLine								; Jump to newline label to create a newline and reset the number of terms on a line
	mov		eax, preTerm
	mov		ebx, currTerm
	add		eax, ebx							; Add preTerm to currTerm
	mov		edx, eax
	call	WriteDec							; Display currTerm
	mov		al, 9								; ASCII character for tab
	call	WriteChar							; Add tab
	mov		tabVerif, 1							; Set the flag for checking to see if additional tab is needed to true
	mov		preTerm, ebx						; Set preTerm to currTerm
	mov		currTerm, edx						; Set currTerm to the Fibo. number we just calculated
	loop	Fibonacci							; Loop to the beginning if there are still terms to calculate
	call	CrLf
	call	CrLf

; 5) Display a parting message that includes the user’s name, and terminate the program.

Finale:
	mov		edx, OFFSET exitMess
	call	WriteString							; Display the first half of the exit message
	mov		edx, OFFSET exitMess2
	call	WriteString							; Display the second half of the exit message
	mov		edx, OFFSET userName
	call	WriteString							; Display the user's name
	mov		edx, OFFSET period
	call	WriteString							; Display a period
	call	CrLf

; -----------------------------------------------------------------------------------------------------------

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main