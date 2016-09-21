'DETERMINES THE AMOUNTOF CLOCK TICKS OF A PULSE FROM AN ENCODER. DOES SAME FOR A CYCLE
'This is the modified version of the code from pg 144 of "Programming the propeller with spin"
'Starts a cog for each wheel and one for controlling the speed of each wheel.
'Prints various values to the serial terminal.



'When High_time = 30, the range from both wheels is 2_500_000 to 3_500_000
'What we want to do:
'                    if PulseLen < 3_300_000
'                        increase the pulse width of the square wave being sent to the motors

'Need different cogs controlling each wheel.
'Wheels need to be driven independently

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  Encoder_Pin_Right = 8
  Encoder_Pin_Left = 9
  High_time = 30             'This is the fraction of one period that the pulse being sent to the motors is high.
  frequency = 20_000
  
OBJ
  pst : "Parallax_Serial_Terminal" 
  
VAR
  long Stack[20]
  long Stack1[20]
  long Stack2[55]
  long startWave
  long endPulse
  long endWave
  long PL_Encoder
  long waveLen
  long freq
  long MotorCog
  long EncCog
  long PL_Motor
  long Dif
  long ForwardCog_R
  long ForwardCog_L
  long PL_Motor_right
  long PL_Motor_left
  
PUB go
  ForwardCog_R := cognew(ForwardRight, @stack)     'This is the one with the drag
  ForwardCog_L := cognew(ForwardLeft, @stack1)
  EncCog := cognew(PL_Motor_Set, @Stack2)
  pst.start(115200)
   'repeat
   '  pst.dec(10)  
   '  waitcnt(clkfreq/10 + cnt)
  DIRA[Encoder_Pin_Left]~                                      'This is the pin that the encoder is connected to
  DIRA[Encoder_Pin_Left]~ 
  repeat
    'pst.dec(10) 
    repeat while ina[Encoder_Pin]==1  
    repeat while ina[Encoder_Pin]==0    
    repeat while ina[Encoder_Pin]==1   
    startWave:=CNT
    repeat while ina[Encoder_Pin]==0
    endPulse:=CNT     
    repeat while ina[Encoder_Pin]==1
    endWave:=CNT                               
    PL_Encoder:=endPulse-startWave              'Range of PL_Encoder: 2.6M to 3.6M
   ' waveLen:=endWave-startWave
    'freq:=80_000_000/waveLen
   ' waitcnt(clkfreq/25+cnt)
    pst.dec(PL_Encoder)
    pst.str(String(pst#NL))
   ' pst.dec(PLEnc)
   '  Dif := (3_130_000-PL_Encoder)              'The range of Dif: -470_000 to +470_000
   ' if Dif > 470_000                             'A low Pulselen = wheel is moving too fast
       'repeat 10
    '   PL_Motor -= 20                            'PL_Motor is the amount of clock ticks that the pulse going to the motor is high.
   ' if PL_Encoder > 3300000
       'repeat 10
   '    PL_Motor += 20

PUB PL_Motor_Set
   waitcnt(2*clkfreq + cnt)                      'Allow enough time to get a value for PL_Motor
  repeat
    'if PL_Encoder < 3300000                        'A low Pulselen = wheel is moving too fast
       'repeat 10
     '  PL_Motor -= 10
   ' if PL_Encoder > 3300000
       'repeat 10
      ' PL_Motor += 10
 '  repeat while PL_Encoder==3_130_000
 '  repeat until PL_Encoder==3_130_000
     ' if Dif >


PUB ForwardRight  | Period, t                          'This one has the drag 

                        'Setting up counter modules for PWM
ctrb[30..26] := %00100

ctrb[5..0] := 23  'This controls it's RIGHT motor
                                                        
dira [19] := outa [19] := 0                     
dira [21] := outa [21] := 1
dira [22] := outa [22] := 0                     
dira [24] := outa [24] := 1

frqb := 1                     'The frq register adds one to the current value of the phs register. 
     
                                       
dira[23]~~

Period := clkfreq/20_000           'This controls the frequency that the repeat loops cycles
PL_Motor_Right := Frequency/High_time       'This controls the duration within a single cycle of the above frequency that the led stays on. The minumum pulse width is 1/80_000_000. So Pulse_length >= clkfreq

 
  repeat 
    t := cnt                                     'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
    repeat 1_000                                 'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.                           
        phsb:= -PL_Motor_Right             'Why is this negative?
        t += Period                           'phsa is the length of the pulse duration.       
        waitcnt(t)

PUB ForwardLeft  | Period, t                         

ctra[30..26] := %00100       'Setting up counter modules for PWM

     
ctra[5..0] := 20 'This controls it's LEFT motor

                                                        
dira [19] := outa [19] := 0                     
dira [21] := outa [21] := 1
dira [22] := outa [22] := 0                     
dira [24] := outa [24] := 1

frqa := 1                     'The frq register adds one to the current value of the phs register. 
     
dira[20]~~                                        


Period := clkfreq/20_000           'This controls the frequency that the repeat loops cycles
PL_Motor_Left := Frequency/High_time       'This controls the duration within a single cycle of the above frequency that the led stays on. The minumum pulse width is 1/80_000_000. So Pulse_length >= clkfreq

 
  repeat 
    t := cnt                                     'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
    repeat 1_000                                 'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.                           
        phsa := -PL_Motor_Left             'Why is this negative?
        t += Period                           'phsa is the length of the pulse duration.       
        waitcnt(t)





PUB Motors  |  t, Period   

ctra[30..26] := %00100       'Setting up counter modules for PWM
ctrb[30..26] := %00100
     
ctra[5..0] := 20             '(It's left)
ctrb[5..0] := 23             '(It's right. This one has the lag)
                                                        
dira [19] := outa [19] := 0                     
dira [21] := outa [21] := 1
dira [22] := outa [22] := 0                     
dira [24] := outa [24] := 1

frqa := frqb := 1                     'The frq register adds one to the current value of the phs register. 
     
dira[20]~~                                        
dira[23]~~

Period := clkfreq/Frequency'(Frequency to motors)           'This controls the frequency that the repeat loops cycles
PL_Motor := Period/High_time                                'This controls the duration within a single cycle of the above frequency that the led stays on. The minumum pulse width is 1/80_000_000. So Pulse_length >= clkfreq

 
  repeat 
    t := cnt                                     'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
    repeat 10                                    'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.                           
        phsa := phsb:= -PL_Motor                 'phsa is the length of the pulse duration.   
        t += Period                                  
        waitcnt(t)

