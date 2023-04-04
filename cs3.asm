list P=16F747
      title "On-Off Control"
;***********************************************************

 ;***********************************************************
       #include <P16F747.INC>
  __config  _CONFIG1, _FOSC_HS & _CP_OFF & _DEBUG_OFF & _VBOR_2_0 & _BOREN_0 & _MCLR_ON & _PWRTE_ON & _WDT_OFF
  __config  _CONFIG2, _BORSEN_0 & _IESO_OFF & _FCMEN_OFF
; Note: the format for the CONFIG directive starts with a double underscore.
; The above directive sets the oscillator to an external high speed clock,
; sets the watchdog timer off, sets the power up timer on, sets the system
; clear on (which enables the reset pin) and turns code protect off among
; other things.
; Variable declarations
Count equ   20h             ; the counter
Temp equ    21h             ; a temporary register
State equ   22h             ; the program state register
Octal equ   23h
Mode  equ   24h
ADconv equ  25h
Timer0 equ  26h
Timer1 equ  27h
Timer2 equ  28h
TimerState equ 29h 
org     00h            
goto    SwitchCheck  

org     04h            ; interrupt vector
goto    isrService ; goto interrupt service routine (dummy)
     
org     15h ; Beginning of program storage
SwitchCheck
call initPort ; initialize ports

Counter
clrf Count
   
waitPress
btfss PORTC,7
goto greenPress
goto waitPress

greenPress
call switchdelay
comf PORTE,W
andlw B'00000111'
movwf Octal
movwf PORTB
goto SwitchMode

SwitchMode
movf Octal,w
andlw B'11111111'
BTFSC STATUS,Z
goto mode0
movf Octal,w
andlw B'11111110'
BTFSC STATUS,Z
goto mode1
movf Octal,w
andlw B'11111101'
BTFSC STATUS,Z
goto mode2
movf Octal,w
andlw B'11111100'
BTFSC STATUS,Z
goto mode3
movf Octal,w
andlw B'11111011'
BTFSC STATUS,Z
goto mode4
movf Octal,w
andlw B'11111010'
BTFSC STATUS,Z
goto mode5
movf Octal,w
andlw B'11111011'
BTFSC STATUS,Z
goto mode6
movf Octal,w
andlw B'11111000'
BTFSC STATUS,Z
goto mode7
goto waitPress

mode0
bsf PORTB,3
bsf Mode,0
call DisengageSolenoid
goto waitPress

mode1
bcf PORTB,3
bsf Mode,1
goto waitRedPress

waitRedPress
btfss PORTC,6
goto redPress
btfss PORTC,7
goto greenPress
goto waitRedPress

redPress
call switchdelay
call EngageSolenoid
goto waitRedPress2

waitRedPress2
btfss PORTC,6
goto redPress2
btfss PORTC,7
goto greenPress
goto waitRedPress2

redPress2
call switchdelay
call DisengageSolenoid
goto waitRedPress

mode2
bcf PORTB,3
bsf Mode,2

goto waitRed

waitRed
btfss PORTC,6
goto red
btfss PORTC,7
goto greenPress
goto waitRed

red
call switchdelay
bsf PORTD,2

bsf ADCON0, GO

waitLoop1
btfsc ADCON0,GO
goto waitLoop1
 
movf ADRESH,W
btfsc STATUS,Z
goto ZERO

bcf STATUS,C
RRF ADRESH,F
bcf STATUS,0
RRF ADRESH,F
movf ADRESH,W
movwf Count
call EngageSolenoid
call decLoop
call DisengageSolenoid
 
goto waitRed
 
decLoop
call Timer
btfss PORTC,6
goto red
decfsz Count,F
goto decLoop
return
 
Timer
incf TimerState
goto timeLoop

timeLoop
movlw 06h
movwf Timer2
movlw 16h
movwf Timer1
movlw 15h
movwf Timer0
 
delay 
decfsz Timer0,F
goto delay
decfsz Timer1,F
goto delay
decfsz Timer2,F
goto delay
 
return

mode3
bcf PORTB,3
bsf Mode,3

goto waitRedButton

waitRedButton
btfss PORTC,6
goto redButton
btfss PORTC,7
goto greenPress
goto waitRedButton

redButton
call switchdelay
bsf PORTD,2

btfss PORTC,6
goto redButton2

bsf ADCON0, GO

waitLoop
btfsc ADCON0,GO
goto waitLoop

btfss PORTC,6
goto redButton2

movf ADRESH,W
btfsc STATUS,Z
goto ZERO

movlw D'112'
subwf ADRESH,w
btfsc STATUS,C
goto GREATER
goto LESSER

goto waitLoop

LESSER
call DisengageSolenoid
goto redButton

ZERO
bsf PORTB,3
call DisengageSolenoid
goto ZERO

GREATER
call EngageSolenoid
goto redButton

redButton2
call switchdelay
bcf PORTD,2
goto waitRedButton


mode4
bcf PORTB,3
bsf Mode,4
bcf State,1

waitRR
btfss PORTC,6
goto RR
btfss PORTC,7
goto greenPress
goto waitRR

RR
call switchdelay

bsf ADCON0, GO
waitLoop2
btfsc ADCON0,GO
goto waitLoop2

movf ADRESH,W
btfsc STATUS,Z
goto ZERO
 
call EngageSolenoid
clrf TimerState
 
faultcheck
btfss PORTC,0 ; optical check
goto checkfault2
bsf PORTD,6 ;reduced on
call Timer 
call Timer
bcf PORTD,7 ; main off

bcf STATUS,C
RRF ADRESH,F
bcf STATUS,0
RRF ADRESH,F
movf ADRESH,W
movwf Count
clrf TimerState
call decLoop1
call DisengageSolenoid
bcf State,1
bcf State,0
 
clrf TimerState
finalfault
btfsc PORTC,0
goto checkfinalfault 
goto waitRR
 
checkfinalfault
call Timer 
movlw D'10'
subwf TimerState,W
btfsc STATUS,Z 
goto ZERO
goto finalfault
 
checkfault2
call Timer 
movlw D'10'
subwf TimerState,W
btfsc STATUS,Z 
goto ZERO
goto faultcheck
 
decLoop1
call Timer
btfss PORTC,0 ; sensor on check
call checkfault3
decfsz Count,F
goto decLoop1
return

checkfault3
btfsc State,1 ; check first fail
goto ZERO
bsf State,1 ; first fail done
goto RR
 
mode5
bsf PORTB,3
bsf Mode,5
call DisengageSolenoid
goto waitPress

mode6
bsf PORTB,3
bsf Mode,6
call DisengageSolenoid
goto waitPress

mode7
bsf PORTB,3
bsf Mode,7
call DisengageSolenoid
goto waitPress


EngageSolenoid
;bsf PORTD,6
BSF PORTD,7
bsf State,0
return

DisengageSolenoid
BCF PORTD,6
BCF PORTD,7
bcf State,0
return

switchdelay
movlw D'5'
movwf Temp

delay1

decfsz Temp,f
goto delay1

return



goto Exit
; ; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
; ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
 ; Port Initialization Subroutine
initPort
    clrf PORTA
    clrf PORTB
    clrf PORTC
    clrf PORTD
    clrf PORTE
    bsf STATUS, RP0
    movlw B'11111111'
    movwf TRISA
    movlw B'11110000'
    movwf TRISB
    movlw B'11111111'
    movwf TRISC
    movlw B'00011100'
    movwf TRISD
    movlw B'00000111'
    movwf TRISE
   
    movlw B'00001110'
    movwf ADCON1
    bcf STATUS, RP0
    movlw B'01000001'
    movwf ADCON0
   
return
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
 ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ; Note: this is a dummy interrupt service routine. It is good programming
; practice to have it. If interrupts are enabled (which they should not be)
; and if an interrupt occurs (which should not happen), this routine safely
; hangs up the microcomputer in an infinite loop.
isrService
 goto isrService ; error - - stay here
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Exit
 end



