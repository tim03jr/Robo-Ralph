'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''ROBO-RALPH 833 lines and counting''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

''This code gives Eddie three modes of opperation:

''Manual-mode(Yellow light):
  'Moves forward when joystick is moved forward
  'Rotates 90CW when joystick is moved right and 90CCW when moved to the left.
''Auto-mode(White light):
  'Code moves into AutoMode.
  'A new cog that runs the ping sensors is launched in background.
  'Eddie roams around avoiding obsticles until the button is pushed again.
''Kinect-mode(Green light)
  
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''INFO''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''  
'The range that the IR sensors yield is from about 2500(close) and about 200(far). 1500 = about 5 inches 


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''TO DO'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  'Joystick control should be "continuous" instead of  only forward, spin left, and spin right. Might need to alter the ATtiny code.
  'Impliment encoders for AUTO-MODE
  'Should always have start and stop methods
  'Channel 7 of the ADC reads the current voltage of the battery
  'All encompasing method for all movements. Forward, reverse, rotate etc
  'Can use pin 13 with Simple_Serial object for recieving data from processing.
  'Run pings and IR's in Track-mode.
  'Implement obsticle avoidance in Kinect-mode.
  'Implement speech in response to picture being taken and various other functions.
  'When picture character is sent, give some sort of signal/countdown to let user know thier picture is being taken.
  
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
Serial : "Extended_FDSerial"  

CON 
_clkmode = xtal1 + pll16x                                                   
_xinfreq = 5_000_000
XB_Baud      = 9600' 
'___________________________________________________________________________________________________________________________________________________________
'________________________________________________________THESE ARE ALL OF THE PIN DESIGNATIONS______________________________________________________________| 
ping_pin0    = 0   'Right front(From it's point of view)                                                                                                    |
ping_pin1    = 1   'Center front ''This is the one pointing down. (Doesn't work because sound bounces away) (Replace with IR sensor)                        |
ping_pin2    = 2   'Left front (From it's point of view)                                                                                                    |
ping_pin3    = 3   'Rear                                                                                                                                    |
front_servo4 = 4 '                                                                                                                                          |
rear_servo5  = 5 '                                                                                                                                          |
'Pin 6 is for the XBee to send data to the board.
ping_pin7    = 7    'Rear/Top/It's left
ping_pin8    = 8    'Front/Top/It's left
ping_pin9    = 9    'Rear/Top/It's right
ping_pin10   = 10'  'Front/Top/It's right                                                                                                                   |
Speaker_Pin  = 11'                                                                                                                                          |                                                                                                                              |                                                                               |                                                                                                                                             |
'Pins 12-15 are spare GPIO from the center of the board.
Battery_GreenLED  = 13 '                                                                                                                                    |
Battery_BlueLED   = 14
Battery_RedLED    = 15'                                                                                                                                    |
'Pins 16-18 are the auxilary pins that put out 12V(Pin 16 is used for the EL wire).
EL_Pin            = 16'
K_Track_led       = 17'                                                                        |
'Pins 19-24 are for the H-bridges.                                                                                                                          |
'Pins 25-27 are for the ADC shown below.                                                                                                                    |                                                                                                                    |
'ADC                                                                                                                                                        |
chipSel      = 25                    'Pin 25 is connected to the chip select pin of the MCP3208 DAC                                                         |
chipDIO      = chipSel+1             'Pin 26 is connected to both the in and out pin of the MCP3208                                                         |
chipClk      = chipSel+2             'Pin 27 is connected to the clock pin of the MCP3208                                                                   |
'Pin 28 is the Pin that would send data to the XBee, but we're not using it. 
'I'm not sure what pin 29 is for.                                                                                                                           |
'Pin 30 = tx   'Via Serial
'Pin 31 = rx

'Pins and Baud rate for XBee comms.                                                                                                                         |
XB_Rx        = 6 ' XBee DOUT      'This is the only one used. We are only recieving with the on-board XBee. DOut sends the recieved signal out to the board.|
XB_Tx        = 28 ' XBee DIN      'This is set to pin 12 because pin 12 is not an I/O pin(We are not using DIN of the XBee)  DUMMY PIN                      |    
'___________________________________________________________________________________________________________________________________________________________|
'__________________________________________________________________ADC PIN KEY______________________________________________________________________________|
'                                                                                                                                                           |
'0 = Center, front, downward-facing IR                                                                                                                      |
'1 = Top, right IR.                                                                                                                                         |
'2 = Top, left IR.                                                                                                                                          |
'3 = Top, rear IR.                                                                                                                                          |
'Pins 4-7 are unused.                                                                                                                                       |
'8 = battery gauge.                                                                                                                                         |
'___________________________________________________________________________________________________________________________________________________________|
'_________________________________________________________THESE ARE THE CHANGEABLE PARAMETERS_______________________________________________________________|                                                                                                                                                           |
Ping_dist      = 5   'Ping_dist at which things are sensed by Ping sensors (Inches)                                                                         |
speed          = 5   'Smaller is faster. This controls the speed of the wheels. It the time within one cycle that the signal is high. In this case. 1/5th   |
IR_dist        = 1500   'Higher is closer. 1500 is about 5 inches                                                                                           |
IR_dist_ground = 1500 '                                                                                                                                     |
K_Horiz_dist   = 200  'This is for kinect mode. It's the amount of pixels from the middle of the display that a tracked user can move before Robo-Ralph moves. If it's too small, The robot moves back and forth trying to put the user in view.
K_Far_dist     = 1_200  'This is for kinect mode. It's the distance in mm that a user is from the kinect.                                                   |
K_Near_dist    = 600   'This is for kinect mode. It's the distance in mm that a user is from the kinect.                                                    |
'                                                                                                                                                           |
'___________________________________________________________________________________________________________________________________________________________|                                                                                                                                                            |

VAR                                         'This section can be optimized. ie: Do they all need to be longs?
long range0
long range1
long range2
long range3
long range4
long range5
long range7
long range8
long range9
long range10
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
long stack6[20]
long stack7[20]
long stack8[20]
long PingsCog
long PingsCog_k
long JoyStickValueUDCog
long JoyStickValueLRCog
long ServoCog
long XBCog
long EL_tapeCOG  
long BeepCOG
long P_checkCOG
long K_LEDCOG
long Battery_CheckCOG
long K_DataIn_z
long K_DataIn_x
word K_Character
long K_CharIn
long Battery_Voltage

Pub Init
   XB.start(XB_Rx, XB_Tx, 0, XB_Baud)                 'Initialize comms for XBee
  'pst.start(9600)                                     'Using this to print to serial monitor
  ADC.start(chipDIO, chipCLK, chipSel, 255)
  Serial.start(31, 30, 0, 9600)                   ' Either pst OR Serial, not both!!       'This is for comm. to comp.            'Start (RXpin, TXPin, Mode, Baud)
  Battery_CheckCOG := cognew(Batt_RGB_LED, @Stack8)
  Start
   
Pub Start

  repeat     
     DataIn := XB.Rx                              'IMPORTANT: XB.Rx can only receive one digit at a time.(Receives the y or @ or !)(Each character denotes a different function)
     
     if DataIn == "k" 'Kinect
         PingsCog_k := cognew(Pings_k, @stack5)       'Still want to avoid obsticles in track mode.
         waitcnt(clkfreq + cnt)
         Track_Mode
         waitcnt(clkfreq/100  + cnt)
     
     if DataIn == "y"                             'ASCII decimal equivalent for the character y is 121.
         PingsCog := cognew(Pings, @stack)        'PingsCog returns the ID of the cog that was launched(0-7). 
         waitcnt(clkfreq + cnt)                   'This pause must be here in order to give the Ping sensors time to gather data before AutoMode begins trying to use it. Must be about clkfreq/10   
         Auto_Mode                      
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

Pub Track_Mode                            'pst.dec(123)  Either pst OR Serial, not both!!! 
Servo_Straight(Front_servo4)
Servo_Straight(Rear_Servo5)
P_CheckCOG := cognew(P_Check, @Stack)
waitcnt(clkfreq + cnt)

                'This tells the motors what to do based on the tracked user's position.
repeat          'FIRST ADJUST X-POS THEN Z-POS.

    if (K_DataIn_x < -K_Horiz_dist) AND (range0 > Ping_dist) AND (IR_range1 < IR_dist) AND (range10 > Ping_dist)              
       K_CW                               
       waitcnt(clkfreq/100 + cnt)
       
    if (K_DataIn_x > K_Horiz_dist) AND (range2 > Ping_dist) AND (IR_range2 < IR_dist) AND (range8 > Ping_dist)
       K_CCW                              
       waitcnt(clkfreq/100 + cnt)
       
    if (K_DataIn_z > K_Far_dist) AND (K_DataIn_z <> 0) AND (range0 > Ping_dist) AND (range1 > Ping_dist) AND (range2 > Ping_dist) AND (IR_range0 < IR_dist) AND (IR_range1 < IR_dist) AND (IR_range2 < IR_dist) AND (range10 > Ping_dist) AND (range8 > Ping_dist)
       K_forward                      
       waitcnt(clkfreq/100 + cnt)  
        
    if (K_DataIn_z < K_Near_dist) AND (K_DataIn_z <> 0) AND (range3 > Ping_dist) AND (IR_range3 < IR_dist) AND (range7 > Ping_dist) AND (range9 > Ping_dist)
       K_reverse
       waitcnt(clkfreq/100 + cnt)
            
    DataIn := XB.Rx
    if DataIn <> "k"
       waitcnt(clkfreq + cnt)
       Start    

PUB Pings_k                                                  'Reads DataIn and Knct_dist so that other cogs can use them.

repeat     
     range0 := ping.Inches(ping_pin0)      'Front right     
     range1 := ping.Inches(ping_pin1)      'Front on servo     
     range2 := ping.Inches(ping_pin2)      'Front left                                                 
     range3 := ping.Inches(ping_pin3)      'Back         
     range7 := ping.Inches(ping_pin7)      'Top/Rear/Left
     range8 := ping.Inches(ping_pin8)      'Top/Front/Left
     range9 := ping.Inches(ping_pin9)      'Top/Rear/Right
     range10:= ping.Inches(ping_pin10)     'Top/Front/Right
     
     IR_range0 := adc.in(0)                'front facing down
    ' IR_range1 := adc.in(1)                'front right(It's right)
     IR_range2 := adc.in(2)                'front left
     IR_range3 := adc.in(3)                'back

     DataIn := XB.Rx                       'Having this cog check DataIn slows down the ping sensors. Having it in another cog would be ideal.
    
     if (DataIn <> "k") 
        cogstop(P_CheckCOG)       
        cogstop(k_LEDCOG)
        OUTA[k_track_led] := 0
        cogstop(PingsCog_k) 

PUB P_Check  | PicIn

K_CharIn := Serial.Rxcheck   'This must be outside of the repeat loop.
k_LEDCOG := cognew(k_LED, @Stack7)

repeat

  Serial.RxFlush                         'This needed to clear out the rx buffer. Will give inaccurate values if not used.
  K_CharIn := Serial.Rx
  PicIn := K_CharIn
  if PicIn == "p"
     waitcnt(clkfreq + cnt)
     Speaker_4_Pic
  
  if K_CharIn == "x"                      '1700 is approximately 4' from kinect. Larger = farther.
 
     K_DataIn_x := Serial.RxDec 

     repeat until K_CharIn == "z"                     '1700 is approximately 4' from kinect. Larger = farther.
           Serial.RxFlush 
           K_CharIn := Serial.Rx

     K_DataIn_z := Serial.RxDec

PUB k_LED

'If not tracking set off.
'If tracking set on.
repeat
  if K_CharIn == "x" OR K_CharIn == "z"
  
    DIRA[K_track_led] := OUTA[K_track_led] := 1
    waitcnt(clkfreq/2+ cnt)
    
 OUTA[K_track_led] := 0
 waitcnt(clkfreq/2+ cnt) 

PUB  Batt_RGB_LED                 'Could also do a mixture of rgb to create a finer resolution of color.

    DIRA[Battery_GreenLED] := 1 
    DIRA[Battery_BlueLED]  := 0
    DIRA[Battery_RedLED]   := 0 

repeat
  Battery_Voltage := adc.in(7)
 ' pst.dec(Battery_Voltage)
 ' pst.Str(String(pst#NL))  
 ' waitcnt(clkfreq/10 + cnt)

  if Battery_Voltage > 3_000
    OUTA[Battery_GreenLED] := 1 
    OUTA[Battery_BlueLED]  := 0
    OUTA[Battery_RedLED]   := 0 
  if Battery_Voltage < 3_000  and Battery_Voltage > 2_500
    OUTA[Battery_GreenLED] := 0 
    OUTA[Battery_BlueLED]  := 1
    OUTA[Battery_RedLED]   := 0  
  if Battery_Voltage < 2_500
    OUTA[Battery_GreenLED] := 1 
    OUTA[Battery_BlueLED]  := 0
    OUTA[Battery_RedLED]   := 0 
  
PUB Speaker_4_Pic | i, a

  DIRA[Speaker_Pin] := OUTA[Speaker_Pin] := 1
  
    repeat 2       
      repeat 300
        !OUTA[Speaker_Pin]
        waitcnt(clkfreq/(500) + cnt)
      waitcnt(clkfreq/2+ cnt)
    repeat 1
      repeat 750
        !OUTA[Speaker_Pin]
        waitcnt(clkfreq/(900) + cnt)
      waitcnt(clkfreq/2+ cnt)      

DIRA[Speaker_Pin] := OUTA[Speaker_Pin] := 0 


PUB Servo_Straight(Servo_Pin)  | Frequency, Pulse_length, t, i

 ctra[30..26] := %00100       'Setting up counter modules for PWM  
 ctra[5..0] := Servo_Pin
 frqa := frqb := 1                     'The frq register adds one to the current value of the phs register. 
 dira[Servo_Pin]~~

 Frequency := clkfreq/50           'Freq = 50Hz

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''PULSE LENGTH RANGE (and initial pos)''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' 
                                'Pulse_length := clkfreq/1667      'For 0 degrees, pulse width = 0.0006s.
                                ' Pulse_length := clkfreq/1111      'For 30 degreees
                                 Pulse_length := clkfreq/690       'For Servos to face directly forward.
                                'Pulse_length := clkfreq/476       'For 150 degrees
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
   
    t := cnt                                       
    repeat 30
        phsa := phsb := -(pulse_length)            'Why is this negative?
        t += Frequency                                 'phsa is the length of the pulse duration.       
        waitcnt(t)

PUB Auto_Mode                            'IR_range(x) gets larger as objects closer. Range(x) gets smaller.                                       
 repeat
    
    If  (DataIn == "y") AND (range0 > Ping_dist) AND (range1 > Ping_dist) AND (range2 > Ping_dist) AND (range8 > Ping_dist) AND (range10 > Ping_dist) AND (IR_range0 < IR_dist) AND (IR_range1 < IR_dist) AND (IR_range2 < IR_dist) 
        waitcnt(clkfreq/2 + cnt)
        EL_tapeCOG := cognew(EL_tape, @Stack2)
        ServoCog := cognew(Servo(front_servo4), @stack1) 
        Forward("y")

    If (DataIn == "y") AND ((range1 < Ping_dist) OR (IR_range0 > IR_dist_ground))        'Center front
       waitcnt(clkfreq/2 + cnt)
       BeepCog := cognew(Beep, @Stack3)
       ServoCog := cognew(Servo(rear_servo5), @stack4)
       Reverse(60)
    
    If (DataIn == "y") AND ((range0 < Ping_dist) OR (range10 < Ping_dist) OR (IR_range1 > IR_dist))                'Right side
       waitcnt(clkfreq/2 + cnt) 
       Rotate90CCW
    
    If (DataIn == "y") AND ((range2 < Ping_dist)  OR (range8 < Ping_dist) OR (IR_range2 > IR_dist))               'Left
       waitcnt(clkfreq/2 + cnt)
       Rotate90cw

    if  DataIn <> "y"
        Start

PUB Pings                                                  'Reads DataIn and Knct_dist so that other cogs can use them.

repeat     
     range0 := ping.Inches(ping_pin0)      'Front right     
     range1 := ping.Inches(ping_pin1)      'Front on servo     
     range2 := ping.Inches(ping_pin2)      'Front left                                                 
     range3 := ping.Inches(ping_pin3)      'Back         
     range7 := ping.Inches(ping_pin7)      'Top/Rear/Left
     range8 := ping.Inches(ping_pin8)      'Top/Front/Left
     range9 := ping.Inches(ping_pin9)      'Top/Rear/Right
     range10:= ping.Inches(ping_pin10)     'Top/Front/Right       

     IR_range0 := adc.in(0)                'front facing down
     IR_range1 := adc.in(1)                'front right(It's right)
     IR_range2 := adc.in(2)                'front left
     IR_range3 := adc.in(3)                'back

     DataIn := XB.Rx                       'Having this cog check DataIn slows down the ping sensors. Having it in another cog would be ideal.

     if (DataIn <> "y")    'Can't stop a cog that has never started.
          cogstop(El_tapeCog)
          cogstop(PingsCog)  'This must be last or else any commands that follow will not be executed. 
          cogstop(ServoCog)
         
PUB Forward(mode)  | Frequency, Pulse_length, t         'AUTO_kinect                    'Repeats until check does not equal 

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
    repeat until (dataIn <> mode) or (range0 < Ping_dist) or (range1 < Ping_dist) or (range2 < Ping_dist) or (IR_range0 > IR_dist_ground) or (IR_range1 > IR_dist) or (IR_range2 > IR_dist) OR (range8 < Ping_dist) OR (range10 < Ping_dist)              
      t := cnt                                     'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
      repeat 1_000                                 'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.                           
          phsa := phsb:= -Pulse_length             'Why is this negative?
          t += Frequency                           'phsa is the length of the pulse duration.       
          waitcnt(t)
   
  ctra[30..26] := %00000                           'This is here to get rid of the sudden burst of the motors when they are stopping.
  ctrb[30..26] := %00000

  if EL_tapeCOG <> 0 
    cogstop(EL_tapeCOG)

  if ServoCog <> 0
    cogstop(ServoCog)
  
  if dataIn == "y"
     Auto_Mode

  if  DataIn <> "y"
     Start

PUB Servo(Servo_Pin)  | Frequency, Pulse_length, t, i

 ctra[30..26] := %00100       'Setting up counter modules for PWM  
 ctra[5..0] := Servo_Pin
 frqa := frqb := 1                     'The frq register adds one to the current value of the phs register. 
 dira[Servo_Pin]~~

 Frequency := clkfreq/50           'Freq = 50Hz

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''PULSE LENGTH RANGE''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' 
                                'Pulse_length := clkfreq/1667      'For 0 degrees, pulse width = 0.0006s.
                                 Pulse_length := clkfreq/1111      'For 30 degreees 
                                'Pulse_length := clkfreq/476       'For 150 degrees
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
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
   
  if (DataIn == "y") and (range3 > Ping_dist) and (IR_range3 < IR_dist) AND (range7 > Ping_dist) AND (range9 > Ping_dist)
   repeat iterations
    if (range3 > Ping_dist) AND (IR_range3 < IR_dist) AND (range7 > Ping_dist) AND (range9 > Ping_dist)    
      t := cnt                                                                      'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.                                                 
      repeat 1_000                                                                  'The number here represents the number of times the repeat loop repeats.
           phsa := phsb:= -Pulse_length
           t += Frequency                                                           'phsa is the length of the pulse duration.       
           waitcnt(t)
   
  cogstop(BeepCOG)
  cogstop(servoCog)
   
  waitcnt(clkfreq/5 + cnt)                                                           'This is the pause between reversing and rotating 90 deg
                                              
  if (DataIn == "y") 'or (DataIn == "k")
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

if DataIn == "y" ' or DataIn == "k"    
    t := cnt                                                                      'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.                                                 
    repeat 25_000                                                                 'The number here represents the number of times the repeat loop repeats.                           
        phsa := phsb:= -Pulse_length                                 
        t += Frequency                                                            'phsa is the length of the pulse duration.       
        waitcnt(t)

   ctra[30..26] := %00000
   ctrb[30..26] := %00000
   waitcnt(clkfreq/2 + cnt)

   if (DataIn == "y")
     Auto_Mode
 '  if(DataIn == "k")
 '    Track_Mode
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

if DataIn == "y" 'or DataIn == "k"   
    t := cnt                                                                      'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.                                                 
    repeat 25_000                                                                'The number here represents the number of times the repeat loop repeats.                           
        phsa := phsb:= -Pulse_length
        t += Frequency                                                            'phsa is the length of the pulse duration.       
        waitcnt(t)

   ctra[30..26] := %00000
   ctrb[30..26] := %00000
   waitcnt(clkfreq/2 + cnt)

   if (DataIn == "y")
     Auto_Mode
  ' if(DataIn == "k")
  '   Track_Mode

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













PUB K_Forward  | Frequency, Pulse_length, t         'AUTO_kinect                    'Repeats until check does not equal 

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

  repeat until (K_DataIn_z < K_Far_dist) OR (K_CharIn == "l") OR (K_DataIn_x < -K_Horiz_dist) OR (K_DataIn_x > K_Horiz_dist) OR (range0 < Ping_dist) OR (range1 < Ping_dist) OR (range2 < Ping_dist) OR (range8 < Ping_dist) OR (range10 < Ping_dist)OR (IR_range0 > IR_dist) OR (IR_range1 > IR_dist) OR (IR_range2 > IR_dist)
      t := cnt                                     'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
      repeat 1_000                                 'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.                           
          phsa := phsb:= -Pulse_length             'Why is this negative?
          t += Frequency                           'phsa is the length of the pulse duration.       
          waitcnt(t)
   
  ctra[30..26] := %00000                           'This is here to get rid of the sudden burst of the motors when they are stopping.
  ctrb[30..26] := %00000
  waitcnt(clkfreq/5 + cnt)


PUB K_Reverse | Frequency, Pulse_length, t          ''For AUTO MODE.  Remember:  'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.

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

  repeat until (K_DataIn_z > K_Near_dist) OR (K_CharIn == "l") OR (range3 < Ping_dist) OR (IR_range3 > IR_dist) OR (range7 < Ping_dist) OR (range9 < Ping_dist)
     t := cnt  
     repeat 1_000                                                                    'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.                                                                  'The number here represents the number of times the repeat loop repeats.
           phsa := phsb:= -Pulse_length
           t += Frequency                                                           'phsa is the length of the pulse duration.       
           waitcnt(t)

    
  ctra[30..26] := %00000                           'This is here to get rid of the sudden burst of the motors when they are stopping.
  ctrb[30..26] := %00000  
  waitcnt(clkfreq/5 + cnt)                                                           'This is the pause between reversing and rotating 90 deg

PUB K_CW  | Frequency, Pulse_length, t                            
                                  
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

repeat until (K_DataIn_x > -K_Horiz_dist) OR (K_CharIn == "l") OR (range0 < Ping_dist) OR (range10 < Ping_dist) OR (IR_range1 > IR_dist)
  t := cnt                             
  repeat 1_000
     phsa := phsb:= -Pulse_length                                   'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
     t += Frequency                                                 'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.
     waitcnt(t)
    
ctra[30..26] := %00000
ctrb[30..26] := %00000


Pub K_CCW | Frequency, Pulse_length, t                      

ctra[30..26] := %00100     'Configures counters for CTRMODE(the 30..26 part) and single ended NCO mode(the %00100 part) .               
ctrb[30..26] := %00100                                              
                                        
ctra[5..0] := 20            'These pins are where the signal is sent.              
ctrb[5..0] := 23                               
                                                                                               
dira [19] := outa [19] := 1             'Selects the direction of the motors.                              
dira [21] := outa [21] := 0  
dira [22] := outa [22] := 0                    
dira [24] := outa [24] := 1

frqa := frqb := 1                       'The frq register adds one to the current value of the phs register. 
                                                                              
dira[20]~~                                         
dira[23]~~                              'Sets PWM pins as outputs(the ~~ part means they are outputs).

Frequency := clkfreq/20_000           'This controls the frequency that the repeat loops cycles
Pulse_length := Frequency/Speed       'This controls the duration within a single cycle of the above frequency that the led stays on. The minumum pulse width is 1/80_000_000. So Pulse_length >= clkfreq

repeat until (K_DataIn_x < K_Horiz_dist) OR (K_CharIn == "l") OR (range2 < Ping_dist) OR (range8 < Ping_dist) OR (IR_range2 > IR_dist)
  t := cnt                             
  repeat 1_000
     phsa := phsb:= -Pulse_length                                   'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
     t += Frequency                                                 'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.
     waitcnt(t)
   
ctra[30..26] := %00000
ctrb[30..26] := %00000
   