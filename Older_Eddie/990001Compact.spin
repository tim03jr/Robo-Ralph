''This code is exactly the same as 9909NewPWM. I was just trying to compact it a bit





''This code gives Eddie two modes of opperation:

''Manual mode(Green light):
  'Moves forward when joystick is moved forward
  'Rotates 90CW when joystick is moved right and 90CCW when moved to the left.
''Auto mode(Yellow light):
  'Code moves into AutoMode.
  'A new cog that runs the ping sensors is launched in background.
  'Eddie roams around avoiding obsticles until the button is pushed again.


''Problems:
  'Need to get the ping sensors sensing more frequently.

  
{{....................................
MOTOR pin key

pin 19 = Left reverse
pin 20 = PWM left
pin 21 = Left forward
pin 22 = Right reverse
pin 23 = PWM right
pin 24 = Right forward
....................................
}}
OBJ
XB : "XBee_Object"
pst : "Parallax_Serial_Terminal" 
ping : "Ping"

CON 
_clkmode = xtal1 + pll16x                                                   
_xinfreq = 5_000_000


ping_pin0 = 0   'Left front
ping_pin1 = 1   'Center front
ping_pin2 = 2   'Right front
ping_pin3 = 3   
ping_pin4 = 4
ping_pin5 = 5
distance  = 5   
speed     = 5   'Smaller is faster.

'Pins and Baud rate for XBee comms 
XB_Rx = 6 ' XBee DOUT      'This is the only one used. We are only recieving with the on-board XBee.
XB_Tx = 7 ' XBee DIN 
XB_Baud = 9600

VAR
long range0
long range1
long range2
long range3
long range4
long range5
long stack[60]
long PingsCog
long JoyStickValueUDCog
long JoyStickValueLRCog
long DataUD
long DataLR
word DataIn

Pub Start
  XB.start(XB_Rx, XB_Tx, 0, XB_Baud)              'Initialize comms for XBee
  pst.start(9600)                                 'Using this to print to serial monitor

  repeat
     DataIn := XB.Rx                              'IMPORTANT: XB.Rx can only receive one digit at a time.(Receives the y or @ or !)
    

     if DataIn == "y"                             'ASCII decimal equivalent for the character y is 121.
         PingsCog := cognew(Pings, @stack)        'PingsCog returns the ID of the cog that was launched(0-7). 
         waitcnt(clkfreq/10  + cnt)               'This pause must be here in order to give the Ping sensors time to gather data before AutoMode begins trying to use it. Must be about clkfreq/10.
         AutoMode                      
         waitcnt(clkfreq/100  + cnt)  
 
     if DataIn == "@"  'LR                       'Can use 64 or "@" here.
           DataLR := XB.RxDec                    'DataIn sits at about 516ish                 'Must use XB.RxDec to receive a decimal.
           if DataLR < 200
              CCWmanual 'Go left
           elseif DataLR > 800             
              CWmanual'Go right
           else
              waitcnt(clkfreq/100 + cnt)       
          waitcnt(clkfreq/100 + cnt)  
 
     if DataIn == "!"   'UD                     'Can use 33 or "!" here.
           DataUD := XB.RxDec                   'DataIn sits at about 516ish                 'Must use XB.RxDec to receive a decimal.
          if DataUD > 800                 
             Manualforward 
        
           
  
PUB Pings
   repeat             
     
     range0 := ping.Inches(ping_pin0)
     waitcnt(clkfreq/100_000 + cnt)
     
     range1 := ping.Inches(ping_pin1)
     waitcnt(clkfreq/100_000 + cnt)
     
     range2 := ping.Inches(ping_pin2)
     waitcnt(clkfreq/100_000 + cnt)
                                                 
     range3 := ping.Inches(ping_pin3)                
     waitcnt(clkfreq/100_000 + cnt)
     
     range4 := ping.Inches(ping_pin4)               
     waitcnt(clkfreq/100_000 + cnt)
     
     range5 := ping.Inches(ping_pin5)                
     waitcnt(clkfreq/100_000 + cnt)
     
    DataIn := XB.Rx

    if DataIn <> "y"
     cogstop(PingsCog)
    
PUB AutoMode   

 repeat
    If  range0 > distance and range1 > distance and range2 > distance and DataIn == "y"
        waitcnt(clkfreq + cnt) 
        Forward
    
    If range0 < distance and DataIn == "y"
       waitcnt(clkfreq + cnt) 
       Rotate90CCW
     
    If range1 < distance and DataIn == "y"
       waitcnt(clkfreq + cnt)
       ReverseRampUpAndDown
    
    If range2 < distance and  DataIn == "y"
      waitcnt(clkfreq + cnt)
      Rotate90cw

    if  DataIn <> "y"
        Start
    
   
PUB Forward  | Frequency, Pulse_length, t         'This method is for auto mode.

ctra[30..26] := %00100       'Setting up counter modules for PWM
ctrb[30..26] := %00100
     
ctra[5..0] := 20 
ctrb[5..0] := 23
                                                        
dira [19] := outa [19] := 0                     
dira [21] := outa [21] := 1
dira [22] := outa [22] := 0                     
dira [24] := outa [24] := 1

frqa := frqb := 1                     'The frq register adds one to the current value of the phs register. 
     
dira[20]~~                                        
dira[23]~~

Frequency := clkfreq/20_000           'This controls the frequency that the repeat loops cycles
Pulse_length := Frequency/Speed       'This controls the duration within a single cycle of the above frequency that the led stays on. The minumum pulse width is 1/80_000_000. So Pulse_length >= clkfreq

DataIn := XB.Rx                       'Here we read the value being sent from the controller to the XBee
waitcnt(clkfreq/10 + cnt)             'Must have a pause after DataIn := XB.Rx in order to give it time to read from the XBee.

if DataIn == "y"
  repeat until DataIn <> "y"  or  range0 < distance or range1 < distance or range2 < distance or  range3 < distance or range4 < distance or range5 < distance                     'This repeat loop keeps the motors going forward until the botton is switched to manual.    
    t := cnt                                     'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.                                                 
    repeat 1_000                                'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.                           
        phsa := phsb:= -Pulse_length
        t += Frequency                           'phsa is the length of the pulse duration.       
        waitcnt(t)
   
ctra[30..26] := %00000   ''This is here to get rid of the sudden burst of the motors when they are stopping.
ctrb[30..26] := %00000

AutoMode

PUB ReverseRampUpAndDown | Frequency, Pulse_length, t          ''For AUTO MODE.  Remember:  'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.

ctra[30..26] := %00100                                                    
ctrb[30..26] := %00100                     
                                        
ctra[5..0] := 20                              
ctrb[5..0] := 23                               

dira [19] := outa [19] := 1
dira [21] := outa [21] := 0                   
dira [22] := outa [22] := 1
dira [24] := outa [24] := 0

frqa := frqb := 1                                     'The frq register adds one to the current value of the phs register.                                                                              
                                                                             
dira[20]~~                                        
dira[23]~~

Frequency := clkfreq/20_000                          'This controls the frequency that the repeat loops cycles
Pulse_length := Frequency/Speed                      'This controls the duration within a single cycle of the above frequency that the led stays on. The minumum pulse width is 1/80_000_000. So Pulse_length >= clkfreq


DataIn := XB.Rx                                      'Here we read the value being sent from the controller to the XBee
waitcnt(clkfreq/10 + cnt)                            'Must have a pause after DataIn := XB.Rx in order to give it time to read from the XBee.

if DataIn == "y" and range3 > distance and range4 > distance and range5 > distance
 repeat 60
  if range3 > distance and range4 > distance and range5 > distance   
    t := cnt                                                                      'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.                                                 
    repeat 1_000                                                                  'The number here represents the number of times the repeat loop repeats.
         phsa := phsb:= -Pulse_length
         t += Frequency                                                           'phsa is the length of the pulse duration.       
         waitcnt(t)

DataIn := XB.Rx                                                                  'Here we read the value being sent from the controller to the XBee
waitcnt(clkfreq/10 + cnt)                                                        'Must have a pause after DataIn := XB.Rx in order to give it time to read from the XBee.
                                            
if DataIn == "y"
   waitcnt(clkfreq + cnt)
   Rotate90CCW
 
PUB Rotate90CCW  | Frequency, Pulse_length, t       'Used for AUTO MODE.                
                                  
ctra[30..26] := %00100                    
ctrb[30..26] := %00100                                              
                                        
ctra[5..0] := 20                          
ctrb[5..0] := 23                               
                                                                                               
dira [19] := outa [19] := 1                                           
dira [21] := outa [21] := 0  
dira [22] := outa [22] := 0                    
dira [24] := outa [24] := 1

frqa := frqb := 1                                    'The frq register adds one to the current value of the phs register.
                                                                              
dira[20]~~                                         
dira[23]~~
                                                   
Frequency := clkfreq/20_000                         'This controls the frequency that the repeat loops cycles
Pulse_length := Frequency/Speed                     'This controls the duration within a single cycle of the above frequency that the led stays on. The minumum pulse width is 1/80_000_000. So Pulse_length >= clkfreq


DataIn := XB.Rx                                    'Here we read the value being sent from the controller to the XBee
waitcnt(clkfreq/10 + cnt)                          'Must have a pause after DataIn := XB.Rx in order to give it time to read from the XBee.

if DataIn == "y"    
    t := cnt                                                                      'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.                                                 
    repeat 25_000                                                                 'The number here represents the number of times the repeat loop repeats.                           
        phsa := phsb:= -Pulse_length                                 
        t += Frequency                                                            'phsa is the length of the pulse duration.       
        waitcnt(t)

   ctra[30..26] := %00000
   ctrb[30..26] := %00000

PUB Rotate90CW  | Frequency, Pulse_length, t   'Used for AUTO MODE.                  
                                  
ctra[30..26] := %00100                    
ctrb[30..26] := %00100                                              
                                        
ctra[5..0] := 20                          
ctrb[5..0] := 23                               
                                                                                               
dira [19] := outa [19] := 0                                           
dira [21] := outa [21] := 1  
dira [22] := outa [22] := 1                    
dira [24] := outa [24] := 0

frqa := frqb := 1                 'The frq register adds one to the current value of the phs register.
                                                                              
dira[20]~~                                         
dira[23]~~
                                                   
Frequency := clkfreq/20_000       'This controls the frequency that the repeat loops cycles
Pulse_length := Frequency/Speed       'This controls the duration within a single cycle of the above frequency that the led stays on. The minumum pulse width is 1/80_000_000. So Pulse_length >= clkfreq

DataIn := XB.Rx                   'Here we read the value being sent from the controller to the XBee
waitcnt(clkfreq/10 + cnt)         'Must have a pause after DataIn := XB.Rx in order to give it time to read from the XBee.

if DataIn == "y"    
    t := cnt                                                                      'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.                                                 
    repeat 25_000                                                                'The number here represents the number of times the repeat loop repeats.                           
        phsa := phsb:= -Pulse_length
        t += Frequency                                                            'phsa is the length of the pulse duration.       
        waitcnt(t)

   ctra[30..26] := %00000
   ctrb[30..26] := %00000

Pub Manualforward | Frequency, Pulse_length, t         'This method needs some work. Somehow it gets locked in this method causing it to run into things.

ctra[30..26] := %00100
ctrb[30..26] := %00100

ctra[5..0] := 20 
ctrb[5..0] := 23

dira [19] := outa [19] := 0                     
dira [21] := outa [21] := 1
dira [22] := outa [22] := 0                     
dira [24] := outa [24] := 1
                                                                 
frqa := frqb := 1                                                       'The frq register adds one to the current value of the phs register.

dira[20]~~                                        
dira[23]~~

Frequency := clkfreq/20_000                                             'This controls the frequency that the repeat loop cycles by controlling the wait time.
Pulse_length := Frequency/Speed                                         'This controls the duration within a single cycle of the above frequency that the led stays on. The minumum pulse width is 1/80_000_000. So Pulse_length >= clkfreq

JoyStickValueUDCog := cognew(JoyStickValueUD, @stack)                   'JoyStickValueCog returns the ID of the cog that was launched(0-7).
waitcnt(clkfreq/10 + cnt)                                               'Have to use another cog to check the value of DataUD. Would do it in the repeat loop, but that would disturb the pwm.
t := cnt
                              
 repeat until DataUD < 800                                              'Speed holds here until conditions are met. 'UD.
     phsa := phsb:= -Pulse_length                                       'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
     t += Frequency                                                     'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.
     waitcnt(t)

cogstop(JoyStickValueUDCog)  
ctra[30..26] := %00000                                                       ''Put this here to get rid of the sudden burst of the motors when they are stopping.
ctrb[30..26] := %00000

Start 

PUb JoyStickValueUD                 'This is used by ManualForward

repeat 
  DataIn := XB.Rx                   'Here we read the value being sent from the controller to the XBee
   if DataIn == "!"
      DataUD := XB.RxDec

Pub CCWmanual | Frequency, Pulse_length, t                      

ctra[30..26] := %00100     'Configures counters for CTRMODE(the 30..26 part) and single ended NCO mode(the %00100 part) .               
ctrb[30..26] := %00100                                              
                                        
ctra[5..0] := 20            'These pins are where the signal is sent.              
ctrb[5..0] := 23                               
                                                                                               
dira [19] := outa [19] := 1             'Selects the direction of the motors.                              
dira [21] := outa [21] := 0  
dira [22] := outa [22] := 0                    
dira [24] := outa [24] := 1

frqa := frqb := 1                 'The frq register adds one to the current value of the phs register. 
                                                                              
dira[20]~~                                         
dira[23]~~                              'Sets PWM pins as outputs(the ~~ part means they are outputs).

Frequency := clkfreq/20_000       'This controls the frequency that the repeat loops cycles
Pulse_length := Frequency/Speed       'This controls the duration within a single cycle of the above frequency that the led stays on. The minumum pulse width is 1/80_000_000. So Pulse_length >= clkfreq

JoyStickValueLRCog := cognew(JoyStickValueLR, @stack)                   'JoyStickValueCog returns the ID of the cog that was launched(0-7).
waitcnt(clkfreq/10 + cnt)                                               'Have to use another cog to check the value of DataUD. Would do it in the repeat loop, but that would disturb the pwm.

 t := cnt                             
 repeat until DataLR > 200                                          'Speed holds here until conditions are met.  'UD.   'Can use 33 or "!" here.
     phsa := phsb:= -Pulse_length                                   'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
     t += Frequency                                                 'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.
     waitcnt(t)

cogstop(JoyStickValueLRCog)     
ctra[30..26] := %00000
ctrb[30..26] := %00000

PUb JoyStickValueLR                 'This is used by CCWmanual

repeat 
  DataIn := XB.Rx                   'Here we read the value being sent from the controller to the XBee  
   if DataIn == "@"
      DataLR := XB.RxDec
   
PUB CWmanual  | Frequency, Pulse_length, t                            
                                  
ctra[30..26] := %00100                    
ctrb[30..26] := %00100                                              
                                        
ctra[5..0] := 20                          
ctrb[5..0] := 23                               
                                                                                               
dira [19] := outa [19] := 0                                           
dira [21] := outa [21] := 1  
dira [22] := outa [22] := 1                    
dira [24] := outa [24] := 0
                                                                              
frqa := frqb := 1                 'The frq register adds one to the current value of the phs register. 
                                                                              
dira[20]~~                                         
dira[23]~~                              'Sets PWM pins as outputs(the ~~ part means they are outputs).

Frequency := clkfreq/20_000       'This controls the frequency that the repeat loops cycles
Pulse_length := Frequency/Speed       'This controls the duration within a single cycle of the above frequency that the led stays on. The minumum pulse width is 1/80_000_000. So Pulse_length >= clkfreq

JoyStickValueLRCog := cognew(JoyStickValueLR, @stack)                   'JoyStickValueCog returns the ID of the cog that was launched(0-7).
waitcnt(clkfreq/10 + cnt)                                               'Have to use another cog to check the value of DataUD. Would do it in the repeat loop, but that would disturb the pwm.

 t := cnt                             
 repeat until DataLR < 800                                          'Speed holds here until conditions are met.  'UD.   'Can use 33 or "!" here.
     phsa := phsb:= -Pulse_length                                   'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
     t += Frequency                                                 'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.
     waitcnt(t)

cogstop(JoyStickValueLRCog)     
ctra[30..26] := %00000
ctrb[30..26] := %00000