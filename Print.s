; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix
		
	AREA  DATA, ALIGN=2;
outfix SPACE 6;

    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
n	EQU	0; binding
LCD_OutDec
	PUSH{LR, R0}; allocation
	  CMP R0, #10;
	  BLO base;
	  MOV R2, #10;
	  UDIV R0, R0, R2;
	  BL LCD_OutDec;
	  LDR R0, [SP, #n]; access
	  MOV R3, #10;
	  UDIV R2, R0, R3;
	  MUL R1, R2, R3;
	  SUB R1, R0, R1;
	  MOV R0, R1;
	  ADD R0, #0x30;
	  BL ST7735_OutChar
	  B done;
base  ADD R0, #0x30;
	  BL ST7735_OutChar
done  POP{PC, R0}; deallocation

     ; BX  LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11

MAX EQU 10000; lots of binding
StartIndex EQU 5;
num EQU 0;
index EQU 4;
pointer EQU 8;
star EQU 0x2A;
dot EQU 0x2E;	
OverArr DCB star, dot, star, star, star, 0; Array

LCD_OutFix
       PUSH{LR, R0}; (make sure we can exit LCD_OutFix)
	   MOV R1, #StartIndex; R1 is the current index of the array, starts at the last index
	   LDR R2, =outfix; R2 is the pointer to the index of the array, starts at the last index
	   MOV R3, #1;
	   MUL R3, R1;
	   ADD R2, R3; move the pointer to the last index
	   MOV R3, #MAX; check if N >= 10000 and if it is skip and put *.***;
	   CMP R0, R3;
	   BHS Over;
	   BL LCD_OF; Go to the helper function thing
	   B  OS2; When we return, the array will be filled so go to the end and OutputString
	   ;LCD_OF is a "mini internal function helper thing". Essentially it is where the recursion actually occurs. Difference between this and
	   ;the normal OutFix is that it takes in two additional inputs, the index to which the value is to be stored in the array, and a pointer to that index
	   ;The end result of LCD_OF is a filled 6 index array meant to symbolize the X.YZA;
LCD_OF PUSH{LR, R0, R1, R2} ;create 3 local variables:n, index, pointer (allocation)	 
	   
	   CMP R1, #5; Check if this is the last index (index 5), if it is put 0 in for null
	   BNE Nonull;
	   MOV R0, #0;
	   STRB R0, [R2];
	   LDR R0, [SP, #num]; this is an example of access
	   SUB R1, #1;
	   SUB R2, #1;
	   BL LCD_OF; Pass in the previous num, and decremented index and pointer
	   B OS; When we inevitably return, terminate the iteration by skipping to the POP
Nonull CMP R1, #1; check to see if the index is 1 (do we need a "."?)
	   BNE Nodot; 
	   MOV R0, #dot;
	   STRB R0, [R2]; store a "." into the array
	   LDR R0, [SP, #num]; pass along the R0 from index 2's iteration
	   SUB R1, #1; decrement index
	   SUB R2, #1; decrement the pointer
	   BL LCD_OF; recuression
	   B OS; When we return, terminate the iteration (finish touches such as deallocation)
Nodot  CMP R1, #0; if the first index, its done and all that is left is to put the final value in the array and go back up the recursion chain (Store the remainders)
	   BEQ Finish;
	   
	   CMP R0, #10; if n < 10, store n in the resp. index and pass 0 for num
	   BLO smol;
	   MOV R3, #10;
	   UDIV R0, R0, R3;
	   SUB R1, #1; dec index *R1 changed
	   SUB R2, #1; dec pointer *R2 changed
	   BL LCD_OF; LCD_OF(n/10, index--, pointer--)
	   ;When we get back store the remainder in its respective index
	   LDR R0, [SP, #num];
	   MOV R3, #10;
	   UDIV R1, R0, R3; R1 = num /10, *R1 is changed
	   MUL R1, R3; R1 = (num / 10) * 10
	   SUB R0, R1; R0 = remainder (num % 10)
	   ADD R0, #0x30;
	   LDR R1, [SP, #index];
	   LDR R2, [SP, #pointer];
	   STRB R0, [R2];
	   ;SUB R1, #1; dec ind
	   ;SUB R2, #1; dec pointer
	   B OS; After storing the remainder, finish the iteration by popping
	   
smol   ADD R0, #0x30;
	   STRB R0, [R2];
	   MOV R0, #0; pass along 0
	   SUB R1, #1; dec index
	   SUB R2, #1; dec pointer
	   BL LCD_OF; if it is already less than 10, further nums will be 0
	   B OS; when we get back finish this iteration
Over  ;PUSH {LR, R0};
	  LDR R0, =OverArr; if R0, is over 9999 go ahead and output *.***
	  BL ST7735_OutString;
	  POP{PC, R0} 
Finish ADD R0, #0x30; 
	  STRB R0, [R2]; store the last value
	 ; LDR R0, =outfix; load address of array	  
      
OS    POP{PC, R0, R1, R2}; finishing touches for each iteration (terminate the iteration) (deallocation)
OS2	  LDR R0, =outfix; Actually output (called from the original LCD_OutFix)
	  BL ST7735_OutString; output array	
	  POP{PC, R0}; we done boys
    ; BX   LR
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
