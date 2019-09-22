TITLE Programming Assignment #5     (program5.asm)

; Author: Thanh Nguyen
; Course / Project ID : CS271-P05                Date: 2/25/18
; Description:
;		1. Introduce the program.
;		2. Get a user request in the range [min = 10 .. max = 200].
;		3. Generate request random integers in the range [lo = 100 .. hi = 999], storing them in consecutive elements of an array.
;		4. Display the list of integers before sorting, 10 numbers per line.
;		5. Sort the list in descending order (i.e., largest first).
;		6. Calculate and display the median value, rounded to the nearest integer.
;		7. Display the sorted list, 10 numbers per line.

; -----------------------------------------------------------------------------------------------------------

INCLUDE Irvine32.inc

max = 200																														; Constant for greatest number user can enter
min = 10																														; Constant for lowest number user can enter
hi = 999																														; Constant for greatest random number that can be generated
lo = 100																														; Constant for lowest random number that can be generated

; -----------------------------------------------------------------------------------------------------------

.data

;	1. Introduce the program.

titleAndName	BYTE	"Sorting Random Integers                  Programmed by Thanh Nguyen", 0ah, 0dh, 0ah, 0dh, 0			; Variable for title of program and name of programmer
explainMess		BYTE	"This program generates random numbers in the range [100 .. 999],", 0ah, 0dh
				BYTE	"displays the original list, sorts the list, and calculates the", 0ah, 0dh
				BYTE	"median value. Finally, it displays the list sorted in descending order.", 0ah, 0dh, 0ah, 0dh, 0		; Variable for instructions of program

;	2. Get a user request in the range [min = 10 .. max = 200].

numInputMess	BYTE	"How many numbers should be generated? [10 .. 200] :  ", 0												; Message asking user for number of random numbers to generate
invalidMess		BYTE	"Invalid input", 0ah, 0dh, 0																			; Message telling user their input was invalid
request			DWORD	?																										; Variable to hold the user input

;	3. Generate request random integers in the range [lo = 100 .. hi = 999], storing them in consecutive elements of an array.

array			DWORD	max DUP(?)																								; Create an array of DWORDs holding up to 200 values

;	4. Display the list of integers before sorting, 10 numbers per line.

titleUnsorted	BYTE	"The unsorted random numbers:", 0ah, 0dh, 0																; Title header for unsorted list

;	6. Calculate and display the median value, rounded to the nearest integer.

medianMess		BYTE	"The median is ", 0																						; Message before displaying median

;	7. Display the sorted list, 10 numbers per line.

titleSorted		BYTE	"The sorted list:", 0ah, 0dh, 0																			; Title header for sorted list

; -----------------------------------------------------------------------------------------------------------

.code
main PROC

call	Randomize								; Generate seed for random number creation

call	introduction							; Introduce the program

push	OFFSET request							; Push the address of the request variable onto the stack for the getData procedure
call	getData									; Get the number of requested random numbers from the user

push	request									; Push the number of random numbers the user wants to generate
push	OFFSET array							; Push the address of the array
call	fillArray								; Generate random numbers and store them in consequence elements of the array

push	OFFSET array
push	request
push	OFFSET titleUnsorted
call	displayList								; Display the list of integers before sorting, 10 numbers per line.

push	OFFSET array
push	request
call	sortList								; Sort the list in descending order (i.e., largest first).

push	OFFSET array
push	request
call	displayMedian							; Calculate and display the median value, rounded to the nearest integer.

push	OFFSET array
push	request
push	OFFSET titleSorted
call	displayList								; Display the list of integers before sorting, 10 numbers per line.

exit											; exit to operating system

main ENDP

; -----------------------------------------------------------------------------------------------------------

; ********************************************************************************************************
; This procedure writes strings to introduce the title of the program, the programmer's name, and 
; instructions about the program to the user.
; Receives: None
; Returns: None
; Preconditions: None
; Registers changed: None
; ********************************************************************************************************

introduction	PROC
	mov		edx, OFFSET titleAndName
	call	WriteString								; Display the title of the program and name of the programmer
	mov		edx, OFFSET explainMess
	call	WriteString								; Display a message explaining the programmer to the user
	ret
introduction	ENDP

; ********************************************************************************************************																									   *
; This procedure prompts the user to enter a number of random numbers they want to generate and
; then proceeds to validate it.											   
; Receives: Address of request on system stack
; Returns: User input in global request
; Preconditions: None
; Registers changed: EAX, ESI
; ********************************************************************************************************

getData		PROC
		push	ebp
		mov		ebp, esp
		mov		esi, [ebp+8]				; Get the address of global request into esi for indirect addressing
		jmp		GetUserNum

	Invalid:
		mov		edx, OFFSET invalidMess
		call	WriteString					; Let the user know the number is invalid

	GetUserNum:
		mov		edx, OFFSET numInputMess
		call	WriteString					; Prompt user for a number
		call	ReadInt
		cmp		eax, max
		jg		Invalid						; Check to see if number is greater than max
		cmp		eax, min
		jl		Invalid						; Check to see if number is less than min
		jmp		Valid

	Valid:
		mov		[esi], eax					; Store valid user input into global request
		pop		ebp
		call	CrLf
		ret		4
getData		ENDP

; ********************************************************************************************************																									   *
; Generate request random integers in the range [lo = 100 .. hi = 999], storing them in consecutive 
; elements of an array.
; Receives: 1) Request (value) 2) Array (reference)
; Returns: Array with cells filled in
; Preconditions: None
; Registers changed: EAX, ECX, ESI
; ********************************************************************************************************

fillArray	PROC
		push	ebp
		mov		ebp, esp

		mov		ecx, [ebp+12]				; Put the value of request into ECX for LOOP instruction
		mov		esi, [ebp+8]				; Put the array address into ESI

	Generate:								; Label to generate a random number and store into the array
		mov		eax, hi
		sub		eax, lo
		inc		eax							; Get range of random numbers for EAX
		call	RandomRange					; Generate a random number into EAX
		add		eax, lo						; Get the corrected random number after adding the floor

		mov		[esi], eax					; Add the random number into the array
		add		esi, 4						; Move to the next spot of the array

		loop	Generate					; As long as there are still random numbers requested, continue to generate and store them

		pop		ebp
		ret		8
fillArray	ENDP

; ********************************************************************************************************																									   *
; Display the list of integers, 10 numbers per line.
; Receives: 1) Array (reference) 2) Request (value) 3) Title (reference)
; Returns: The contents of the array filled in (on screen)
; Preconditions: None
; Registers changed: EAX, EBX, ECX, EDX, ESI
; ********************************************************************************************************

displayList		PROC
		push	ebp
		mov		ebp, esp

		mov		esi, [ebp+16]			; Put the array address into ESI
		mov		edx, [ebp+8]			; Put the address of the unsorted message title into EDX
		mov		ecx, [ebp+12]
		call	WriteString				; Display the unsorted message title

		mov		ebx, 0					; Set EBX to 0 to use as counter for number of terms per line
		jmp		Display					; Jump to the Display label to skip the NewLine label

	NewLine:
		call	CrLf					; Display a newline
		mov		ebx, 0					; Reset EBX to 0 for new set of terms on line

	Display:
		cmp		ebx, 10
		je		Newline					; Check to see if number of terms per line has reached 10
		mov		eax, [esi]
		call	WriteDec				; Display the current element of the array
		mov		al, 9
		call	WriteChar				; Display a tab character
		inc		ebx						; Increment the number of terms on the line
		add		esi, 4					; Go to the next element of the array
		loop	Display					; If there are still more terms to display, go back to the top of the loop

		call	CrLf
		call	CrLf
		pop		ebp
		ret		12
displayList		ENDP

; ********************************************************************************************************																									   *
; Sort the array in descending order (i.e., largest first).
; Receives: 1) Array (reference) 2) Request (value)
; Returns: A sorted array
; Preconditions: None
; Registers changed: EAX, EBX, ECX, EDX, ESI
; Citation: From OSU-CS271 assignment guide, uses C++ Selection Sort algorithm
; ********************************************************************************************************

sortList	PROC
		push	ebp
		mov		ebp, esp

		mov		esi, [ebp+12]					; Move the address of the array into ESI
		mov		ecx, [ebp+8]					; Put request into ECX

		mov		edx, 0							; Prepare EDX for division
		mov		eax, 0							; EAX = k
		
	OuterForBeg:								; Beginning of outer for-loop
		push	ecx								; (request)
		dec		ecx								; ECX = request - 1																	
		cmp		eax, ecx						; k < request - 1																		 
		jge		Done
		pop		ecx								; (request)																			
		mov		ebx, eax						; i = k

	; Pre-InnerFor. Need to convert EAX from k to (j)
		push	eax								; (k)
		inc		eax								; j = k + 1

	InnerFor:									; Beginning of inner for-loop
		cmp		eax, ecx						; j < request
		jge		ExchangeNum

	; To get array[j] ==> EAX
		push	eax								; (j)
		push	ebx								; (i)																					
		mov		ebx, 4							; DWORD size to multiply array index by to get correct OFFSET
		mul		ebx								; (i * 4)
		pop		ebx								; (i)																			
		push	esi								; (@array)																											
		add		esi, eax						; @array[j]
		mov		eax, [esi]						; array[j]
		pop		esi								; (@array)

	; To get array[i] ==> EDX
		push	eax								; (array[j])
		mov		eax, ebx						; EAX <-- EBX = i
		push	ebx								; (i)																
		mov		ebx, 4							; DWORD size to multiply array index by to get correct OFFSET
		mul		ebx								; (i * 4)
		pop		ebx								; (i)																				
		push	esi								; (@array)																			
		add		esi, eax						; @array[i]
		mov		edx, [esi]						; EDX = array[i]
		pop		esi								; (@array)
		pop		eax								; (array[j])																			

	; if(array[j] > array[i])
		cmp		eax, edx
		jg		InnerForIf						; if(array[j] > array[i])																			
		pop		eax								; (j)																			
		inc		eax								; j++
		jmp		InnerFor
		
	; i = j
	InnerForIf:																			
		pop		eax								; (j)
		mov		ebx, eax						; i = j
		inc		eax								; j++
		jmp		InnerFor

	ExchangeNum:
		pop		eax								; (k)																				

	; To get @array[k] ==> EAX
		push	eax								; (k)																						
		push	ebx								; (i)																						
		mov		ebx, 4							; DWORD size to multiply array index by to get correct OFFSET
		mul		ebx								; (k * 4)
		pop		ebx								; (i)																				
		push	esi								; (@array)																				
		add		esi, eax						; @array[k]
		mov		eax, esi						; EAX = @array[k]
		pop		esi								; (@array)																			

	; To get @array[i] ==> EDX
		push	eax								; (@array[k])																			
		mov		eax, ebx						; EAX <-- EBX = i
		push	ebx								; (i)																					
		mov		ebx, 4							; DWORD size to multiply array index by to get correct OFFSET
		mul		ebx								; (i * 4)
		pop		ebx								; (i)																					
		push	esi								; (@array)																			
		add		esi, eax						; @array[i]
		mov		edx, esi						; EDX = @array[i]
		pop		esi								; (@array)																				
		pop		eax								; (@array[k])																				

	; Call exchange
		push	eax								; @array[k]
		push	edx								; @array[i]
		call	exchange

		pop		eax								; (k)																			

	; OuterForEnd:
		mov		edx, 0							; Reset for division
		inc		eax								; k + 1
		jmp		OuterForBeg

	Done:
		pop	ecx									; (request)
		pop	ebp
		ret 8
sortList	ENDP

; ********************************************************************************************************																									   *
; Swap two values in an array
; Receives: 1) @array[k] 2) @array[i]
; Returns: An array with two elements swapped
; Preconditions: None
; Registers changed: None
; ********************************************************************************************************

exchange	PROC
		push	ebp
		mov		ebp, esp

		mov		eax, [ebp+12]				; Get the address of array[k] into EAX
		mov		edx, [ebp+8]				; Get the address of array[i] into EDX

		push	ecx							; (request)
		push	ebx							; (i)

		mov		ecx, [eax]					; ECX = temp1 = array[k]
		mov		ebx, [edx]					; EBX = temp2 = array[i]

		mov		[eax], ebx					; array[k] = EBX = temp2 = array[i]
		mov		[edx], ecx					; array[i] = ECX = temp1 = array[k]

		pop		ebx							; (i)
		pop		ecx							; (request)

		pop ebp
		ret	8
exchange	ENDP

; ********************************************************************************************************																									   *
; Find and display the median in a sorted array
; Receives: 1) Array (reference) 2) Request (value)
; Returns: Displays the median of a sorted array
; Preconditions: Array must be sorted (ascending or descending)
; Registers changed: EAX, EBX, ECX, EDX, ESI
; ********************************************************************************************************

displayMedian		PROC
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+12]					; Get the address of array into ESI
	mov		eax, [ebp+8]					; Get the value of request into EAX

	mov		edx, OFFSET	medianMess
	call	WriteString						; Display the median message before displaying the value

	mov		edx, 0							; To prepare for division
	mov		ebx, 2							; To use for dividing EAX in half

	div		ebx								; Divide request by 2
	cmp		edx, 0							; Check to see if there is a remainder
	je		EvenNum							; Jump to the EvenNum label to calculate average of two medians

	; OddNum
		mov		ebx, 4						; DWORD size to multiply array index by to get correct OFFSET
		mul		ebx							; [(request/2) * 4]
		add		esi, eax					; @array[request/2]
		mov		eax, [esi]					; EAX = array[request/2]
		call	WriteDec					; Print the median
		mov		al, 46
		call	WriteChar					; Print a period
		call	CrLf
		call	CrLf
		jmp		MedianDone					; Skip EvenNum label

	EvenNum:
		mov		edx, eax
		dec		edx							; EDX = [(request/2) - 1]

	; To get array[{request/2} * 4] ==> ECX
		push	edx							; (request/2) - 1
		push	esi							; (@array)
		mov		ebx, 4						; DWORD size to multiply array index by to get correct OFFSET
		mul		ebx							; [(request/2) * 4]
		add		esi, eax					; @array[(request/2) * 4]
		mov		ecx, [esi]					; ECX = array[(request/2) * 4]
		pop		esi							; (@array)
		pop		edx							; (request/2) - 1

	; To get array[((request/2) - 1) * 4] ==> EDX
		mov		eax, edx					; EAX = (request/2) - 1
		mul		ebx							; ((request/2) - 1) * 4
		add		esi, eax					; @array[((request/2) - 1) * 4]
		mov		edx, [esi]					; EDX = array[((request/2) - 1) * 4]

	; Get median total
		add		ecx, edx					; Add two median values together

	; Get median average
		mov		edx, 0						; Prepare EDX for division
		mov		ebx, 2						; Prepare to divide by 2
		mov		eax, ecx					; Move combined median values into EAX for division
		div		ebx							; Divide the total median by half

	; Display median
		call	WriteDec					; Display the median average
		mov		al, 46
		call	WriteChar					; Display a period
		call	CrLf
		call	CrLf

	MedianDone:
		pop		ebp
		ret		8
displayMedian		ENDP

; -----------------------------------------------------------------------------------------------------------

END main
