''This is a cleaned-up version of 99005ALLPINGS which is the same as RevSpin code except with a manual option built-in.

''Code starts in auto mode if button is down or manual if button is up.
''Manual mode:
  'Moves forward when joystick is moved forward
  'Rotates 90CW when joystick is moved right and 90CCW when moved to the left.
''Auto mode:
  'A new cog running pings is launched. Auto method is called.
  'Eddie roams around avoiding obsticles.


''Problems:
  'In manual mode, it frequently sticks in the forward method causing robot to run into obstacles.
  'Need to work on the pwm that is going to the motors to more accurately control thier speed. Need to change the pulse width rather than frequency.
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

scale = 800_000
SlowScale = 100_000   
ping_pin0 = 0   'Left front
ping_pin1 = 1   'Center front
ping_pin2 = 2   'Right front
ping_pin3 = 3   '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''WHAT SIDE IN REAR DO THESE BELONG TO?????????????????????????????
ping_pin4 = 4
ping_pin5 = 5
distance  = 5                                      ''When running, the distance should be 20"

' Set pins and Baud rate for XBee comms 
XB_Rx = 6 ' XBee DOUT      'This is the only one used.
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
long AutoCog
long DataUD
long DataLR
word DataIn
Pub Start
  XB.start(XB_Rx, XB_Tx, 0, XB_Baud)  ' Initialize comms for XBee
  pst.start(9600)                     ' Using this to print to serial monitor

  repeat
     DataIn := XB.Rx                 'IMPORTANT: XB.Rx can only receive one digit at a time.(Receives the y or @ or !)
    

     if DataIn == "y"                             'ASCII decimal equivalent for the character y is 121.
         PingsCog := cognew(Pings, @stack)        'PingsCog returns the ID of the cog that was launched(0-7). 
         waitcnt(clkfreq  + cnt)
         AutoMode                       
         waitcnt(clkfreq/100  + cnt)  
 
     if DataIn == "@"  'LR                 'Can use 64 or "@" here.
           DataIn := XB.RxDec              'DataIn sits at about 516ish                 'Must use XB.RxDec to receive a decimal.
           if DataIn < 200
              DataLR := DataIn
              CCWmanual 'Go left
           elseif DataIn > 800
              DataLR := DataIn
              CWmanual'Go right
           else
              waitcnt(clkfreq/1000 * 10 + cnt)       
          waitcnt(clkfreq/1000 * 10 + cnt)  
    
     if DataIn == "!"   'UD                'Can use 33 or "!" here.
           DataIn := XB.RxDec              'DataIn sits at about 516ish                 'Must use XB.RxDec to receive a decimal.
           if DataIn > 800
              DataUD := DataIn
              Manualforward 
           else
             'Stop 
          waitcnt(clkfreq/1000 + cnt)  

PUB Pings
   repeat             
     
     range0 := ping.Inches(ping_pin0)
     waitcnt(clkfreq/1_000 + cnt)
     
     range1 := ping.Inches(ping_pin1)
     waitcnt(clkfreq/1_000 + cnt)
     
     range2 := ping.Inches(ping_pin2)
     waitcnt(clkfreq/1_000 + cnt)
                                                 
     range3 := ping.Inches(ping_pin3)                
     waitcnt(clkfreq/1_000 + cnt)
     
     range4 := ping.Inches(ping_pin4)               
     waitcnt(clkfreq/1_000 + cnt)
     
     range5 := ping.Inches(ping_pin5)                
     waitcnt(clkfreq/1_000 + cnt)
     
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

PUB Forward  | Square        'This method is for auto mode.

ctra[30..26] := %00100       'Setting up counter modules for PWM
ctrb[30..26] := %00100
     
ctra[5..0] := 20 
ctrb[5..0] := 23
                                                        
dira [19] := outa [19] := 0                     
dira [21] := outa [21] := 1
dira [22] := outa [22] := 0                     
dira [24] := outa [24] := 1
     
dira[20]~~                                        
dira[23]~~

DataIn := XB.Rx

if DataIn == "y"
  
     repeat 1
           
         repeat Square from 1 to 1                         
              frqa := frqb := SlowScale    'frqa := frqb := Square * SlowScale   ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
              waitcnt(clkfreq/2 + cnt)
                               
         repeat until  DataIn <> "y" or  range0 < distance or range1 < distance or range2 < distance or  range3 < distance or range4 < distance or range5 < distance      'Speed holds here until conditions are met
             DataIn := XB.Rx
   
ctra[30..26] := %00000   ''This is to get rid of the sudden burst of the motors when they are stopping.
ctrb[30..26] := %00000


Pub Manualforward | Square         'This method needs some work. Somehow it gets locked in this method causing it to run into things.

ctra[30..26] := %00100
ctrb[30..26] := %00100

ctra[5..0] := 20 
ctrb[5..0] := 23

dira [19] := outa [19] := 0                     
dira [21] := outa [21] := 1
dira [22] := outa [22] := 0                     
dira [24] := outa [24] := 1

dira[20]~~                                        
dira[23]~~

 repeat 1

   repeat Square from 1 to 3           ''This is my attemp to start the motors more slowly. It works but there is still a bit of a jolt. It might be inevetible.
    frqa := frqb := Square * SlowScale
    waitcnt(clkfreq/20 + cnt)
                     
  repeat until  DataUD < 800  'Speed holds here until conditions are met
     DataIn := XB.Rx
     if DataIn == "!"   'UD   'Can use 33 or "!" here.
        DataUD := XB.RxDec    'DataIn sits at about 516ish                 'Must use XB.RxDec to receive a decimal.   
 
ctra[30..26] := %00000                                                       ''Put this here to get rid of the sudden burst of the motors when they are stopping.
ctrb[30..26] := %00000
 
PUB ReverseRampUpAndDown | Square         ''For auto mode. 

ctra[30..26] := %00100                                                    
ctrb[30..26] := %00100                     
                                        
ctra[5..0] := 20                              
ctrb[5..0] := 23                               

dira [19] := outa [19] := 1
dira [21] := outa [21] := 0                   
dira [22] := outa [22] := 1
dira [24] := outa [24] := 0                                                                              
                                                                             
dira[20]~~                                        
dira[23]~~

if range3 > distance and range4 > distance and range5 > distance                                                     
  repeat 1
                                                   
      repeat Square from 1 to 7                                 
       frqa := frqb := Square * scale 
                                               
       waitcnt(clkfreq/20 + cnt)
       
      repeat Square from 5 to 1                                    
       frqa := frqb := Square * scale 
                                               
       waitcnt(clkfreq/20 + cnt) 
   ctra[30..26] := %00000
   ctrb[30..26] := %00000
                                             
if DataIn == "y"
   waitcnt(clkfreq + cnt)
   Rotate90CCW
 
PUB Rotate90CCW  | Square       'Used for auto mode.                
                                  
ctra[30..26] := %00100                    
ctrb[30..26] := %00100                                              
                                        
ctra[5..0] := 20                          
ctrb[5..0] := 23                               
                                                                                               
dira [19] := outa [19] := 1                                           
dira [21] := outa [21] := 0  
dira [22] := outa [22] := 0                    
dira [24] := outa [24] := 1
                                                                              
dira[20]~~                                         
dira[23]~~
                                                   
  repeat 1
                                                  
    repeat Square from 1 to 5                
     frqa := frqb := Square * scale 
                                             
     waitcnt(clkfreq/40 + cnt)
   
    repeat Square from 5 to 1                                    
     frqa := frqb := Square * scale 
                                             
     waitcnt(clkfreq/40 + cnt) 

   ctra[30..26] := %00000
   ctrb[30..26] := %00000

PUB Rotate90CW  | Square   'Used for auto mode.                  
                                  
ctra[30..26] := %00100                    
ctrb[30..26] := %00100                                              
                                        
ctra[5..0] := 20                          
ctrb[5..0] := 23                               
                                                                                               
dira [19] := outa [19] := 0                                           
dira [21] := outa [21] := 1  
dira [22] := outa [22] := 1                    
dira [24] := outa [24] := 0
                                                                              
dira[20]~~                                         
dira[23]~~
                                                   
  repeat 1
                                                  
    repeat Square from 1 to 5                
     frqa := frqb := Square * scale                                             
     waitcnt(clkfreq/40 + cnt)
   
    repeat Square from 5 to 1                                    
     frqa := frqb := Square * scale                                             
     waitcnt(clkfreq/40 + cnt) 

   ctra[30..26] := %00000
   ctrb[30..26] := %00000

pub CCWmanual | Square                      

ctra[30..26] := %00100     'Configures counters for CTRMODE(the 30..26 part) and single ended NCO mode(the %00100 part) .               
ctrb[30..26] := %00100                                              
                                        
ctra[5..0] := 20            'These pins are where the signal is sent.              
ctrb[5..0] := 23                               
                                                                                               
dira [19] := outa [19] := 1             'Selects the direction of the motors.                              
dira [21] := outa [21] := 0  
dira [22] := outa [22] := 0                    
dira [24] := outa [24] := 1
                                                                              
dira[20]~~                                         
dira[23]~~                              'Sets PWM pins as outputs(the ~~ part means they are outputs).
                                                   
  repeat 1
                                                  
    repeat Square from 1 to 5                
     frqa := frqb := Square * scale             'Frqx sets the frequency, but we need phsx to set the pulse width.                                 
     waitcnt(clkfreq/40 + cnt)
   
    repeat Square from 5 to 1                                    
     frqa := frqb := Square * scale                                             
     waitcnt(clkfreq/40 + cnt) 

    repeat until  DataLR > 200  'Speed holds here until conditions are met
      DataIn := XB.Rx
      if DataIn == "@"   'Left                           
         DataLR := XB.RxDec 
     
   ctra[30..26] := %00000
   ctrb[30..26] := %00000

PUB CWmanual  | Square                               
                                  
ctra[30..26] := %00100                    
ctrb[30..26] := %00100                                              
                                        
ctra[5..0] := 20                          
ctrb[5..0] := 23                               
                                                                                               
dira [19] := outa [19] := 0                                           
dira [21] := outa [21] := 1  
dira [22] := outa [22] := 1                    
dira [24] := outa [24] := 0
                                                                              
dira[20]~~                                         
dira[23]~~
                                                   
  repeat 1
                                                  
    repeat Square from 1 to 5                
     frqa := frqb := Square * scale 
                                             
     waitcnt(clkfreq/40 + cnt)
   
    repeat Square from 5 to 1                                    
     frqa := frqb := Square * scale 
                                             
     waitcnt(clkfreq/40 + cnt) 

    repeat until  DataLR < 800   'Speed holds here until conditions are met
      DataIn := XB.Rx
      if DataIn == "@"   'Right                  
       DataLR := XB.RxDec 

   ctra[30..26] := %00000
   ctrb[30..26] := %00000
  