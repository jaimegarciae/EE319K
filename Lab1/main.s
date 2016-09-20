;****************** main.s ***************
; Program written by: Jaime Eugenio Garcia
; Date Created: 1/22/2016 
; Last Modified: 9/7/2016 
; Section Tuesday 5-6
; Instructor: VJ
; Lab number: 1
; Brief description of the program
; The overall objective of this system is a digital lock
; Hardware connections
;  PE3 is switch input  (1 means switch is not pressed, 0 means switch is pressed)
;  PE4 is switch input  (1 means switch is not pressed, 0 means switch is pressed)
;  PE5 is switch input  (1 means switch is not pressed, 0 means switch is pressed)
;  PE2 is LED output (0 means door is locked, 1 means door is unlocked) 
; The specific operation of this system is to 
;   unlock if all three switches are pressed

GPIO_PORTE_DATA_R       EQU   0x400243FC
GPIO_PORTE_DIR_R        EQU   0x40024400
GPIO_PORTE_AFSEL_R      EQU   0x40024420
GPIO_PORTE_DEN_R        EQU   0x4002451C
GPIO_PORTE_AMSEL_R      EQU   0x40024528
GPIO_PORTE_PCTL_R       EQU   0x4002452C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608
"
      AREA    |.text|, CODE, READONLY, ALIGN=2
      THUMB
      EXPORT  Start
Start
	  ;Start clock for Port E
	  LDR R0,= SYSCTL_RCGCGPIO_R
	  LDR R1,[R0]
	  ORR R1,#0x10
	  STR R1,[R0]
	  ;Wait 2 bus cycles
	  NOP
	  NOP
	  ;Set direction of pins in the port (P2 is output; P3,P4,P5 are input)
	  LDR R0,= GPIO_PORTE_DIR_R
	  LDR R1,[R0]
	  BIC R1,#0x38 ;Clear P3,P4,P5 to set as input
	  ORR R1,#0x04 ;Set P5 as output
	  STR R1,[R0]
	  ;Clear AFSEL to set regular I/O
	  LDR R0,= GPIO_PORTE_AFSEL_R
	  LDR R1,[R0]
	  BIC R1,#0x3C ;Clear P3,P3,P4,P5 to set as regular I/O
	  STR R1,[R0]
	  ;Set DEN bits to 1 to enable the data pins 
	  LDR R0,= GPIO_PORTE_DEN_R
	  LDR R1,[R0]
	  ORR R1,#0x3C
	  STR R1,[R0]
		

	  ;Load PORTE data register address
	  LDR  R0,= GPIO_PORTE_DATA_R

loop  
	  LDR R1, [R0] ; Load contents of PORTE DR
	  BIC R1, #0x04; Set door to locked by default
	  
	  ;Mask bits for P3,P4,P5 and EOR to check if buttons were pressed
	  EOR  R1, #0x38

	  ;Clear registers for use
	  AND  R2, R2, #0
      AND  R3, R3, #0
	  AND  R4, R4, #0
	  
	  
	  ;Isolate each button's input
	  AND  R2, R1, #0x08 ;P3
	  AND  R3, R1, #0x10 ;P4
	  AND  R4, R1, #0x20 ;P5
	  
	  ;Align bits determining if buttons are pressed (align with P2 bit location)
	  LSR  R2, R2, #1
	  LSR  R3, R3, #2
	  LSR  R4, R4, #3
	 
	  ;Logical AND bits to set P2 to 1 if all buttons are pressed
	  AND  R2, R2, R3
	  AND  R2, R2, R4
	  ORR  R1, R1, R2
			 
	  ;Store back to PORTE to open door if buttons were pressed
	  STR  R1,[R0]
	  
	  
	  B   loop


      ALIGN        ; make sure the end of this section is aligned
      END          ; end of file
