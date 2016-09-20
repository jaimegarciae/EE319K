;****************** main.s ***************
; Program written by: Jesus Quijano and Jaime Garcia
; Date Created: 1/22/2016 
; Last Modified: 9/13/2016 
; Section: Tuesday 5-6
; Instructor: VJ
; Lab number: 2
; Brief description of the program
; The overall objective of this system an interactive alarm
; Hardware connections
;  PF4 is switch input  (1 means SW1 is not pressed, 0 means SW1 is pressed)
;  PF3 is LED output (1 activates green LED) 
; The specific operation of this system 
;    1) Make PF3 an output and make PF4 an input (enable PUR for PF4). 
;    2) The system starts with the LED OFF (make PF3 =0). 
;    3) Delay for about 100 ms
;    4) If the switch is pressed (PF4 is 0), then toggle the LED once, else turn the LED OFF. 
;    5) Repeat steps 3 and 4 over and over

GPIO_PORTF_DATA_R       EQU   0x400253FC
GPIO_PORTF_DIR_R        EQU   0x40025400
GPIO_PORTF_AFSEL_R      EQU   0x40025420
GPIO_PORTF_PUR_R        EQU   0x40025510
GPIO_PORTF_DEN_R        EQU   0x4002551C
GPIO_PORTF_AMSEL_R      EQU   0x40025528
GPIO_PORTF_PCTL_R       EQU   0x4002552C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608

       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
Start
	   ;Start clock for Port F
	   LDR R0,= SYSCTL_RCGCGPIO_R
       LDR R1,[R0]
	   ORR R1, R1, #0x20			;set bit 5 to turn on clock
	   STR R1,[R0] 
	   ;Wait 2 bus cycles
	   NOP
	   NOP
	   ;Set direction of pins in the port (PF3 is output; PF4 are input)
	   LDR R0,= GPIO_PORTF_DIR_R
	   LDR R1,[R0]
	   BIC R1,#0x10     			;clear PF4 to set as input
	   ORR R1,#0x08					;set PF3 to set as output
	   STR R1,[R0]
	   ;Clear AFSEL to set regular I/O
	   LDR R0,= GPIO_PORTF_AFSEL_R
	   LDR R1,[R0]
	   BIC R1,#0x18
	   STR R1,[R0]
	   ;Set DEN bits to 1 to enable the data pins 
	   LDR R0,= GPIO_PORTF_DEN_R
	   LDR R1,[R0]
	   ORR R1,#0x18
	   STR R1,[R0]
	   ;Pull-up resistor for PF4
	   LDR R0,= GPIO_PORTF_PUR_R
	   LDR R1,[R0]
	   ORR R1,#0x10					;enable pull-up on PF4
	   STR R1,[R0]					


	   ;System starts with LED off
	   LDR R0,= GPIO_PORTF_DATA_R
	   LDR R1, [R0]
	   BIC R1, #0x08				;clear PF3 in DR to turn LED off
	   STR R1, [R0]
	   
loop  
	   BL   DelayLoop
	   
       LDR  R0,= GPIO_PORTF_DATA_R

	   ;Check if button is pressed
	   LDR  R1,[R0]
	   AND  R1, #0x10				;extract contents of PF4
	   CMP  R1, #0
	   BEQ  Toggle					;if button is pressed, toggle LED
	   BNE  TurnOff					;if button is not pressed turn LED off
	   
Toggle 
	   LDR  R1,[R0]
	   AND  R2, R1, #0x08			;extract contents of PF3
	   EOR  R2, R2, #0x08			;toggle LED
	   ORR  R1, R1, R2
	   STR  R1,[R0]
	   B    loop
	   
TurnOff  
	   LDR  R1,[R0]
       BIC  R1, #0x08
	   STR  R1,[R0]
       B    loop

DelayLoop
	   MOV  R5, #40000			
Subtract	   
	   SUBS R5, #1
	   BNE  Subtract
	   BX   LR

       ALIGN      ; make sure the end of this section is aligned
       END        ; end of file
