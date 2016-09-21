''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''ROBO-RALPH''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''



                                                                'THIS METHOD CAN'T BE USED. MUST USE V4 OR V6. JUST FOR TESTING








''This code gives Eddie two modes of opperation:

''Manual mode(Yellow light):
  'Moves forward when joystick is moved forward
  'Rotates 90CW when joystick is moved right and 90CCW when moved to the left.
''Auto mode(Blue light):
  'Code moves into AutoMode.
  'A new cog that runs the ping sensors is launched in background.
  'Eddie roams around avoiding obsticles until the button is pushed again.

  
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''INFO''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''  
'The range that the IR sensors yield is from about 2500(close) and about 200(far). 1500 = about 5 inches 


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''TO DO'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  'Joystick control should be "continuous" instead of  only forward, spin left, and spin right. Might need to alter the ATtiny code.
  'Get kinect to send data to board.
  'Impliment encoders for AUTO-MODE
  'Should always have start and stop methods
  'Setup a "Change this only" section for ralph to adjust.
  'Channel 7 of the ADC reads the current voltage of the battery
  'I'd like to create a method just for the motors that I can call.
  'This version: Impliment encoders and get processing communicating.
  'Set up so that there are 2 AUTO modes. One uses the kinect and one does not.
  'Can use pin 13 with Simple_Serial object for recieving data from processing.

{{''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''MOTOR-PIN KEY'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
pin 19 = Left reverse
pin 20 = PWM left
pin 21 = Left forward
pin 22 = Right reverse
pin 23 = PWM right
pin 24 = Right forward
}}
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
OBJ
XB : "XBee_Object"
pst : "Parallax_Serial_Terminal" 
ping : "Ping"
encoder: "Quadrature Encoder"
ADC : "MCP3208"
SimpSer : "Simple_Serial"

CON 
_clkmode = xtal1 + pll16x                                                   
_xinfreq = 5_000_000
'___________________________________________________________________________________________________________________________________________________________
'________________________________________________________THESE ARE THE PIN DESIGNATIONS_____________________________________________________________________| 
ping_pin0    = 0   'Right front(From it's point of view)                                                                                                    |
ping_pin1    = 1   'Center front ''This is the one pointing down. (Doesn't work because sound bounces away) (Replace with IR sensor)                        |
ping_pin2    = 2   'Left front (From it's point of view)                                                                                                    |
ping_pin3    = 3   'Rear                                                                                                                                    |
front_servo4 = 4 '                                                                                                                                          |
rear_servo5  = 5 '                                                                                                                                          |
'Pin 6 is for the XBee to send data to the board.                                                                                                           |
Speaker_Pin  = 7 '                                                                                                                                          |
'Pins 8-11 are for the Encoder                                                                                                                              |
'Pin 12 is the Pin that would send data to the XBee, but we're not using it.                                                                                |
Knct_Pin = 13'                                                                                                                                              |
'Pins 13-15 are spare GPIO (13 might be for recieving data from Processing).                                                                                |
EL_Pin = 16'                                                                                                                                                |
'Pins 16-18 are the auxilary pins that put out 12V(Pin 16 is used for the EL wire).                                                                         |
'Pins 19-24 are for the H-bridges.                                                                                                                          |
'Pins 25-27 are for the ADC shown below.                                                                                                                    |
'I'm not sure what pins 28-31 are for.                                                                                                                      |
'ADC                                                                                                                                                        |
chipSel      = 25                    'Pin 25 is connected to the chip select pin of the MCP3208 DAC                                                         |
chipDIO      = chipSel+1             'Pin 26 is connected to both the in and out pin of the MCP3208                                                         |
chipClk      = chipSel+2             'Pin 27 is connected to the clock pin of the MCP3208                                                                   |
'Pins and Baud rate for XBee comms.                                                                                                                         |
XB_Rx        = 6 ' XBee DOUT      'This is the only one used. We are only recieving with the on-board XBee. DOut sends the recieved signal out to the board.|
XB_Tx        = 12 ' XBee DIN      'This is set to pin 12 because pin 12 is not an I/O pin(We are not using DIN of the XBee)  DUMMY PIN                      |
XB_Baud      = 9600'                                                                                                                                        |
'___________________________________________________________________________________________________________________________________________________________|
'_________________________________________________________THESE ARE THE CHANGEABLE PARAMETERS_______________________________________________________________|                                                                                                                                                           |
distance  = 5   'Distance at which things are sensed by Ping sensors (Inches)                                                                               |
speed     = 5   'Smaller is faster. This controls the speed of the wheels. It the time within one cycle that the signal is high. In this case. 1/5th        |
IR_dist = 1500   'Higher is closer. 1500 is about 5 inches                                                                                                  |
IR_dist_ground = 1500 '                                                                                                                                     |
track_dist = 4'''''''''''''''''''''''''''4 feet
'___________________________________________________________________________________________________________________________________________________________|                                                                                                                                                            |

VAR                                         'This section can be optimized. ie: Do they all need to be longs?
long range0
long range1
long range2
long range3
long range4
long range5
long IR_range0
long IR_range1
long IR_range2
long IR_range3
long DataUD
long DataLR
word DataIn
long pos[3]
long stack[20]
long stack1[20]
long stack2[20]
long stack3[20]
long stack4[20]
long stack5[20]
long PingsCog
long JoyStickValueUDCog
long JoyStickValueLRCog
long ServoCog
long XBCog
long EL_tapeCOG  
long BeepCOG
long Knct_Data   'This will be the distance from the kinect to the Center of mass of skeleton.
   
Pub Start
  XB.start(XB_Rx, XB_Tx, 0, XB_Baud)                 'Initialize comms for XBee
  pst.start(115_200)                                 'Using this to print to serial monitor
  ADC.start(chipDIO, chipCLK, chipSel, 255)
  SimpSer.init(Knct_Pin,-1,9600)                           'init(rxPin, txPin, baud)  Puting -1 for tx pin because we are not transmitting.
                                                     {Call SimpSer.finalize when done with object to release transmit pin.} 
  
 ' Encoder.Start(8, 2, 1, @Pos)                      'Start continuous two-encoder reader (encoders connected to pins 8 - 11)
  'encoderCog := cognew(Encoder_Read, @stack1)

 ' Servo

  repeat     
     DataIn := XB.Rx                              'IMPORTANT: XB.Rx can only receive one digit at a time.(Receives the y or @ or !)(Each character denotes a different function)
     Knct_Data := SimpSer.rx
     
     if knct_Data ' != 0
         PingsCog := cognew(Pings, @stack5)       'Still want to avoid obsticles in track mode.
         Track
     
     if DataIn == "y"                             'ASCII decimal equivalent for the character y is 121.
         PingsCog := cognew(Pings, @stack)        'PingsCog returns the ID of the cog that was launched(0-7). 
         waitcnt(clkfreq + cnt)                   'This pause must be here in order to give the Ping sensors time to gather data before AutoMode begins trying to use it. Must be about clkfreq/10   
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

    ctra[30..26] := %00000                           'This is here to get rid of the sudden burst of the motors when they are stopping.
    ctrb[30..26] := %00000

Pub Track                                  'If no skeleton is being tracked, return to start method.
 repeat 
    if (knct_Data > track_dist) and (range0 > distance) and (range1 > distance) and (range2 > distance) and (IR_range0 < IR_dist) and (IR_range1 < IR_dist) and (IR_range2 < IR_dist)
       Forward(knct_Data, 0)         'If knct_data = 0, forward method stops and the cog returns here.

    if (knct_data  < track_dist) and (range1 < distance) or IR_range0 > IR_dist_ground        'Rear Ping and IR
       reverse(30)

    if knct_data == 0
       Start      
  
PUB Forward(Check, value)  | Frequency, Pulse_length, t         'AUTO                    'Repeats until check does not equal 

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
   
   'Would like to exit the loop when transmitter power is shut off, but I can't figure out how(Need to exit this loop).
    repeat until Check <> value or range0 < distance or range1 < distance or range2 < distance or IR_range0 > IR_dist_ground or IR_range1 > IR_dist or IR_range2 > IR_dist
      t := cnt                                     'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
      repeat 1_000                                 'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.                           
          phsa := phsb:= -Pulse_length             'Why is this negative?
          t += Frequency                           'phsa is the length of the pulse duration.       
          waitcnt(t)
   
  ctra[30..26] := %00000                           'This is here to get rid of the sudden burst of the motors when they are stopping.
  ctrb[30..26] := %00000
   
  cogstop(EL_tapeCOG)
  cogstop(ServoCog)
  if dataIn == "y"
     AutoMode
  else
     Track
   

PUB AutoMode                            'IR_range(x) gets larger as objects closer. Range(x) gets smaller.
                                        
 repeat
    
    If  (range0 > distance) and (range1 > distance) and (range2 > distance) and (IR_range0 < IR_dist) and (IR_range1 < IR_dist) and (IR_range2 < IR_dist) and (DataIn == "y")
        waitcnt(clkfreq + cnt)
        EL_tapeCOG := cognew(EL_tape, @Stack2)
        ServoCog := cognew(Servo(front_servo4), @stack1) 
        Forward(dataIn, "y")

    If (range1 < distance) and (DataIn == "y")  or IR_range0 > IR_dist_ground        'Center rear
       waitcnt(clkfreq + cnt)
       BeepCog := cognew(Beep, @Stack3)
       ServoCog := cognew(Servo(rear_servo5), @stack4)
       Reverse(60)
    
    If (range0 < distance) and (DataIn == "y") or (IR_range1 > IR_dist)                'Right side
       waitcnt(clkfreq + cnt) 
       Rotate90CCW
    
    If (range2 < distance) and (DataIn == "y")  or (IR_range2 > IR_dist)               'Left
       waitcnt(clkfreq + cnt)
       Rotate90cw

    if  DataIn <> "y"
        Start

PUB Servo(Servo_Pin)  | Frequency, Pulse_length, t, i

 ctra[30..26] := %00100       'Setting up counter modules for PWM  
 ctra[5..0] := Servo_Pin
 frqa := frqb := 1                     'The frq register adds one to the current value of the phs register. 
 dira[Servo_Pin]~~

 Frequency := clkfreq/50           'Freq = 50Hz

  'PULSE LENGTH RANGE 
 'Pulse_length := clkfreq/1667      'For 0 degrees, pulse width = 0.0006s.
  Pulse_length := clkfreq/1111      'For 30 degreees 
 'Pulse_length := clkfreq/476       'For 150 degrees


  repeat    
    t := cnt                                       
    repeat while i < 100000                                       
        i += 3000
        phsa := phsb := -(pulse_length + i)            'Why is this negative?
        t += Frequency                                 'phsa is the length of the pulse duration.       
        waitcnt(t)

    t := cnt
    repeat while i > -15000       '27_000 seems to be the farthest right that the servo can pan.
        i -= 3000
        phsa := phsb := -(pulse_length + i)            'Why is this negative?
        t += Frequency                                 'phsa is the length of the pulse duration.       
        waitcnt(t)       

    if DataIn <> "y"
     ' cogstop(PingsCog)                        '''''Do we need this????????????????????????????????????
      cogstop(ServoCog)     
        
PUB Pings                                                  'Might have to put a wait after each ping reading.
   repeat     
     range0 := ping.Inches(ping_pin0)      'Front right     
     range1 := ping.Inches(ping_pin1)      'On the servo     
     range2 := ping.Inches(ping_pin2)      'Front left                                                 
     range3 := ping.Inches(ping_pin3)      'Back         

     IR_range0 := adc.in(0)                'front facing down
     IR_range1 := adc.in(1)                'front right(It's right)
     IR_range2 := adc.in(2)                'front left
     IR_range3 := adc.in(3)                'back

     DataIn := XB.Rx                       'Having this cog check DataIn slows down the ping sensors. Having it in another cog would be ideal.     
     Knct_Data := SimpSer.rx

     if (DataIn <> "y")  
       cogstop(PingsCog)
       cogstop(ServoCog)

PUB EL_tape
  dira[EL_Pin]~~ 
  repeat
     !outa[EL_Pin]
     waitcnt(clkfreq/5 + cnt)    
   

PUB Encoder_Read 

  
PUB Reverse(iterations) | Frequency, Pulse_length, t          ''For AUTO MODE.  Remember:  'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.

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

if DataIn == "y" and range3 > distance
 repeat iterations
  if range3 > distance  
    t := cnt                                                                      'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.                                                 
    repeat 1_000                                                                  'The number here represents the number of times the repeat loop repeats.
         phsa := phsb:= -Pulse_length
         t += Frequency                                                           'phsa is the length of the pulse duration.       
         waitcnt(t)

cogstop(BeepCOG)
cogstop(servoCog)
DataIn := XB.Rx                                                                  'Here we read the value being sent from the controller to the XBee
waitcnt(clkfreq/10 + cnt)                                                        'Must have a pause after DataIn := XB.Rx in order to give it time to read from the XBee.
                                            
if DataIn == "y"
   waitcnt(clkfreq + cnt)
   Rotate90CCW

PUB Beep
  DIRA[Speaker_Pin] := OUTA[Speaker_Pin] := 1
  repeat
    repeat 350
      !OUTA[Speaker_Pin]
      waitcnt(clkfreq/500 + cnt)

    waitcnt(clkfreq/2+ cnt)
    
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