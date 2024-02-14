TITLE Prime Numbers		(Proj4_fantauzd.asm)

; Author:  Dominic Fantauzzo
; Last Modified:  11/15/2023
; OSU email address:  fantauzd@oregonstate.edu
; Course number/section:  CS271 Section 400
; Project Number:         4        Due Date:  11/20/2023
; Description: Program calculates a series of prime numbers based on a number specified by the user.
;		First, the user is instructed to enter the how many prime numbers they would like to see,
;		within the range 1 to 200. The user enters a number and then the program 
;		verifies that their number is within [1-200]. If their number is out of range, the user is 
;		re-prompted until they enter a value in the specified range. The program then calculates 
;		and displays prime numbers until it has displayed as many prime numbers as the user's number.

INCLUDE Irvine32.inc

MIN_RANGE = 1
MAX_RANGE = 200

.data

; (insert variable definitions here)

programName			BYTE "Prime Numbers Programmed by Dominic Fantauzzo",13,10,13,10,"**EC: Output columns aligned (1pt)",13,10,0
intro				BYTE "Enter the number of prime numbers you would like to see.",13,10,"I will accept orders for up to 200 primes.",13,10,0
farewellMessage		BYTE "Results certified and delivered. Have a good day.",13,10,0
outRange			BYTE "WOAH, sorry, woah. That number is out of range. Try again.",13,10,0
userNum				DWORD 0 
prompt1				BYTE "Enter the number of primes to display [1 ... 200]: ",0
blankSpace			WORD " "

.code
main PROC

	PUSH	OFFSET intro
	PUSH	OFFSET programName
	CALL	introduction
	PUSH	OFFSET outRange
	PUSH	OFFSET userNum
	PUSH	MIN_RANGE
	PUSH	MAX_RANGE
	PUSH	OFFSET prompt1
	CALL	getUserData
	PUSH	userNUM
	CALL	showPrimes
	PUSH	OFFSET farewellMessage
	CALL	farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ---------------------------------------------------------------------------------
; Name: introduction
;
; Introduces the program to the user by describing the program name and author.
; Then, after skipping a line, tells the user to enter the number of primes they 
; wish to see and lists the acceptable range of input
;
; Preconditions: [EBP + 8] and [EBP + 12] both reference strings that are 0 terminated
;				 and move to a new line (like "..........",13,10,0)
;
; Postconditions: none
;
; Receives:
;	[EBP + 8]		= reference to string which states the program name and author
;   [EBP + 12]		= reference to string that introduces the program
;
; Returns: none
; ---------------------------------------------------------------------------------
introduction PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDX						; We must save EDX before overwriting with string references
	MOV		EDX, [EBP + 8]
	Call	WriteString
	Call	CrLf
	MOV		EDX, [EBP + 12]
	Call	WriteString
	Call	CrLf
	POP		EDX						; Reset EDX, EBP 
	POP		EBP
	RET		8						; Reset stack (We pushed two memory address (DWORD) before call)
introduction ENDP


; ---------------------------------------------------------------------------------
; Name: getUserData
;
; Obtains an integer within the specified range from the user. This integer is the
; number of primes that we will return to the user. Prints message and repeats if user's
; input is outside specified range.
;
; Preconditions: MASM in 32 bit mode and MAX_RANGE and MIN_RANGE are constants that
;				represent the minimum and maximum allowable number of primes, respectively.
;				[EBP + 8] and [EBP + 24] are both 0 terminated. [EBP + 24] moves to new line
;				(ends "..............",13,10,0)
;
; Postconditions: Once a valid number of primes is entered, the value is stored at [EBP + 16]
;
; Receives:
;	[EBP + 8]		= reference to string that prompts user for input
;	[EBP + 12]		= MAX_RANGE (maximum allowable number of primes)
;	[EBP + 16]		= MIN_RANGE (minimum allowable number of primes)
;	[EBP + 20]		= address of DWORD
;	[EBP + 24]		= reference to string that tells the user their input is invalid, try again
;
; Returns: 
;	[EBP + 20]		= address of the number of primes to return
; ---------------------------------------------------------------------------------
getUserData PROC
	PUSH	EBP
	MOV		EBP, ESP
	SUB		ESP, 4					; create space for local variable which will hold user input until validated
	PUSH	EAX
	PUSH	EDX

_promptUser:
	MOV		EDX, [EBP + 8]			; place the address of our prompt message into EDX before printing
	CALL	WriteString
	MOV		EAX, 0
	MOV		[EBP - 4], EAX			; set the space on stack for user input to 0
	CALL	ReadInt
	MOV		[EBP - 4], EAX			; move user input to stack [EBP - 4]
	CALL	validate
	CMP		EAX, 0
	JE		_valid
	MOV		EDX, [EBP + 24]			; tell the user their input was invalid, try again
	CALL	WriteString
	JMP		_promptUser

; --------------------------
; If the user has entered a valid input,
;	saves input to output paramete ([EBP + 4])
;	cleans up stack
; --------------------------
_valid:
	MOV		EAX, [EBP - 4]
	MOV		EDX, [EBP + 20]			; set EDX to address of our output parameter
	MOV		[EDX], EAX				; set the value of the output parameter to user's input
	POP		EDX
	POP		EAX
	ADD		ESP, 4
	POP		EBP
	RET		20						; we passed 5 parameters with 4 bytes each so we use RET 20
getUserData ENDP


; ---------------------------------------------------------------------------------
; Name: validate
;
; Checks that the user input is within the specified bounds. Returns 0 if within bounds
; and 1 if outside bounds.Subprocedure for getUserData
;
; Preconditions: MASM in 32 bit mode and MAX_RANGE and MIN_RANGE are constants that
;				represent the minimum and maximum allowable number of primes, respectively.
;				[EBP - 4] holds DWORD or SDWORD.
;
; Postconditions: changes register eax
;
; Receives:
;	[EBP - 4]		= user input, number that we want to see in range
;	[EBP + 12]		= MAX_RANGE (maximum allowable number of primes)
;	[EBP + 16]		= MIN_RANGE (minimum allowable number of primes)
;
; Returns: eax	= 0 if [ebp-4] is within bounds and 1 if [ebp-4] is outside bounds
; ---------------------------------------------------------------------------------
validate PROC
	MOV		EAX, [EBP - 4]
	CMP		EAX, [EBP + 16]			; checks if user input too low
	JL		_false
	CMP		EAX, [EBP + 12]			; checks if user input too high
	JG		_false
	MOV		EAX, 0
	RET
_false:
	MOV		EAX, 1
	RET
validate ENDP


; ---------------------------------------------------------------------------------
; Name: showPrimes
;
; Displays prime numbers based on the number input by the user. Uses a counting loop
; and the LOOP instruction to track the number of primes displayed. Candidate primes
; are generated within the counting loop and passed to isPrime for evaluation.
;
; Preconditions: [EBP + 8] is a DWORD greater than or equal to 1.
;
; Postconditions: none
;
; Receives:
;	[EBP + 8]		= the number of primes we want to show
;
; Returns: none
; ---------------------------------------------------------------------------------
showPrimes PROC
; --------------------------
; We are setting up the stack frame.
;	we leave space for two local DWORD variable:
;	[EBP - 4] will hold our boolean output (0 or 1) from isPrime (ouput parameter)
;	[EBP - 8] will hold our display counter to ensure 10 primes per line (input-output parameter)
; --------------------------
	PUSH	EBP
	MOV		EBP, ESP
	SUB		ESP, 8
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
; --------------------------
; We set our loop counter (ECX) to the number of primes we want to show, [EBP + 8].
;	We set our line display counter to 0, local variable [EBP - 8]
;	We set our first potential prime (AX) to 2 as 2 is the first prime
; --------------------------
	CALL	CrLf
	MOV		ECX, [EBP + 8]
	MOV		[EBP - 8], DWORD PTR 0
	XOR		EAX, EAX				; clear EAX as we will later divide DX:AX by BX
	MOV		AX, 2
; --------------------------
; We use the registers to pass isPrime our potential prime (AX)
;	isPrime returns a Bool value in [EBP - 4], if 1 then we display prime
; --------------------------
_searchAgain:
	CALL	isPrime
	MOV		EBX, [EBP - 4]
	CMP		EBX, 1					; with bool return in EBX, check to see if prime was found
	JE		_display
	INC		AX						; increment potential prime
	JMP		_searchAgain
; --------------------------
; We use the register (AX) to pass displayPrime our potential prime
;	Once ECX is decremented and the loop is broken, we clean up registers and stack frame
; --------------------------
_display:
	call	displayPrime
	INC		AX						; increment potential prime 
	LOOP	_searchAgain			; since we displayed a prime, lower ECX by 1
	CALL	CrLf
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	ADD		ESP, 8
	POP		EBP
	RET		4						; we passed one DWORD parameter so we use RET 4
showPrimes ENDP


; ---------------------------------------------------------------------------------
; Name: isPrime
;
; Checks to see if a number is prime. Receives a candidate value, return boolean
; (0 or 1) indicating whether candidate value is prime (1) or not prime (0).
; Subprocedure for showPrimes
;
; Preconditions: AX greater than or equal to 1. 
;
; Postconditions: changes local variable [EBP - 8]
;
; Receives:
;	AX			= potential prime
;
; Returns:
;	[EBP - 4]	= boolean output, 1 if prime, 0 if not prime
; ---------------------------------------------------------------------------------
isPrime PROC
; --------------------------
; Save all registers that we will be using
; --------------------------
	PUSH	EAX
	PUSH	EBX
	PUSH	EDX
	PUSH	ESI
	XOR		EBX, EBX
	MOV		BX, 2					; reset initial divisor to 2 whenever called

_checkPotential:
	MOV		DX,	0
	MOV		SI, AX					; store the value of AX at SI
	CMP		AX, BX
	JE		_foundPrime				; if we were not able to find a divisor before BX incremented to AX, then AX is Prime
	DIV		BX
	CMP		DX, 0
	MOV		AX, SI					; restore the value of AX, as it was altered by Division
	JE		_notPrime				; check to see if potential prime (AX) has a divisor (not one or itself)
	INC		BX
	JMP		_checkPotential
; --------------------------
; Returns appropriate boolean value based on if we found divisor, restores registers
; --------------------------
_notPrime:
	MOV		DWORD PTR [EBP - 4], 0
	POP		ESI
	POP		EDX
	POP		EBX
	POP		EAX
	RET

_foundPrime:
	MOV		DWORD PTR [EBP - 4], 1
	POP		ESI
	POP		EDX
	POP		EBX
	POP		EAX
	RET
isPrime ENDP


; ---------------------------------------------------------------------------------
; Name: displayPrime
;
; Receives a prime number and prints that number to screen. Keeps track of how many numbers
; have been shown on a line and moves to a new line once 10 numbers have been displayed.
; Subprocedure for showPrimes.
;
; Preconditions: AX is a prime number 
;
; Postconditions: changes local variable [EBP - 8]
;
; Receives:
;	AX			= Prime number to be displayed
;	[EBP - 8]	= number of primes already displayed on line
;
; Returns:
;	[EBP - 8]	= number of primes displayed on current line
; ---------------------------------------------------------------------------------
displayPrime PROC
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
; --------------------------
; checks to see how many primes have been displayed on line and moves to new line if 10
; --------------------------
	MOV		EBX, [EBP - 8]
	CMP		EBX, 10
	JE		_newline					; check to see if we are on 11th prime to be displayed on this line (0-9 displayed)
	CALL	WriteDec
	PUSH	blankSpace
	CALL	addSpacing
	ADD		[EBP - 8], DWORD PTR 1		; if not 11th, add one to line display counter (input-output parameter)
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET

_newline:								; if we are on 11th, move to new line and reset line display counter
	CALL	CrLF
	CALL	WriteDec
	PUSH	blankSpace
	CALL	addSpacing
	MOV		[EBP - 8], DWORD PTR 1		; since we just put a prime on this line, we reset to 1
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET
displayPrime ENDP


; ---------------------------------------------------------------------------------
; Name: addSpacing
;
; Receives a prime number that has just been displayed and calculates how many spaces should be
; added to keep column spacing aligned.Subprocedure for displayPrimes
;
; Preconditions: AX is a prime number, less than 65,535. 
;				 [EBP + 8] is data type WORD
;
; Postconditions: none
;
; Receives:
;	AX			= Prime number that was just displayed
;	[EBP + 8]	= blank space (' '), WORD 
;
; Returns: none
; ---------------------------------------------------------------------------------
addSpacing PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
; --------------------------
; sorts displayed value into code label based on number of digits
; --------------------------
	CMP		AX, 10					; see if number is one digit, two digit, three digit, or four digit (most possible)
	JL		_fourSpace
	CMP		AX, 100
	JL		_threeSpace
	CMP		AX, 1000
	JL		_twoSpace
; --------------------------
; adds appropriate number of spaces depending on size opf displayed value
; --------------------------
	XOR		EAX, EAX
	MOV		AL, [EBP + 8]			; we do not need to check for 100,000 becuase we know AX goes to 65,535 (preconditions)
	CALL	WriteChar				; 4 digit numbers receive one space, registers restored and stacka cleaned up
	POP		EAX
	POP		EBP
	Ret		2						; we passed 1 WORD parameter, so we use RET 2 for all returns

_fourSpace:							; 1 digit numbers receive four spaces, registers resotred and stack cleaned up
	XOR		EAX, EAX
	MOV		AL, [EBP + 8]
	CALL	WriteChar
	CALL	WriteChar
	CALL	WriteChar
	CALL	WriteChar
	POP		EAX
	POP		EBP
	RET		2

_threeSpace:						; 2 digit numbers receive three spaces, registers resotred and stack cleaned up
	XOR		EAX, EAX
	MOV		AL, [EBP + 8]
	CALL	WriteChar
	CALL	WriteChar
	CALL	WriteChar
	POP		EAX
	POP		EBP
	RET		2

_twoSpace:							; 3 digit numbers receive two spaces, registers resotred and stack cleaned up	
	XOR		EAX, EAX
	MOV		AL, [EBP + 8]
	CALL	WriteChar
	CALL	WriteChar
	POP		EAX
	POP		EBP
	RET		2
addSpacing ENDP
	

; ---------------------------------------------------------------------------------
; Name: farewell
;
; Prints a goodbye message for the user before finishing the program.
;
; Preconditions: [EBP + 8] is 0 terminated.
;
; Postconditions: none

; Receives:
;	[EBP + 8]		= string referencing a goodbye message
;
; Returns: none
; ---------------------------------------------------------------------------------
farewell PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDX
	CALL	CrLf
	MOV		EDX, [EBP + 8]
	CALL	WriteString
	CALL	CrLf
	POP		EDX
	POP		EBP
	RET		4						; we pass one 4 Byte paramete so RET 4 is used
farewell ENDP


END main
