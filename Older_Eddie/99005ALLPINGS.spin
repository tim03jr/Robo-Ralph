''This is the RevSpin code with a manual option built-in.

''Code starts in auto mode is button is down or manual if button is up.
''Manual mode:
  'Moves forward when joystick is moved forward
  'Rotates 90CW when joystick is moved right and 90CCW when moved to the left.
  

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
SlowScale = 600_000
ping_pin0 = 0
ping_pin1 = 1
ping_pin2 = 2
distance  = 5                                      ''When running, the distance should be 15"

' Set pins and Baud rate for XBee comms 
XB_Rx = 6 ' XBee DOUT      'This is the only one used.
XB_Tx = 7 ' XBee DIN 
XB_Baud = 9600

VAR

long range0
long range1
long range2
long stack[20]
long Straight
long ForwardRamp
long REVERSE
long CCW
long CW

'Need to put variables for receiver method.
long DataUD
word DataIn
Pub Start
  XB.start(XB_Rx, XB_Tx, 0, XB_Baud)                    ' Initialize comms for XBee
  pst.start(9600)                                       ' Using this to print to serial monitor

  repeat
     DataIn := XB.Rx                                   'IMPORTANT: XB.Rx can only receive one digit at a time.
    

     if DataIn == "y"                     'Could use a while here I think.             'ASCII decimal equivalent for the character y is 121.
         waitcnt(clkfreq + cnt)
         AutoMode                         'I don't think a cognew is needed here. 
        waitcnt(clkfreq/1000 * 10 + cnt)  'Might need to shorten delay time.

     
     
  
     if DataIn == "@"  'LR                                       'Can use 64 or "@" here.
           DataIn := XB.RxDec              'DataIn sits at about 516ish                 'Must use XB.RxDec to receive a decimal.
           if DataIn < 200
              Rotate90CCW 'Go left or right
           elseif DataIn > 800
              Rotate90CW'Go left or right
           else
              'Stop       
          waitcnt(clkfreq/1000 * 10 + cnt)  'Might need to shorten delay time. 
    
     if DataIn == "!"   'UD                                    'Can use 33 or "!" here.
           DataIn := XB.RxDec              'DataIn sits at about 516ish                 'Must use XB.RxDec to receive a decimal.
           if DataIn > 800
              DataUD := DataIn
              Manualforward'Go forward. No reverse 
           else
             'Stop 
          waitcnt(clkfreq/1000 * 10 + cnt)  'Might need to shorten delay time. 

    

PUB AutoMode   


'repeat until ina[Button]          Reapeat until button = something other than 0.
                             
waitcnt (clkfreq + cnt)

repeat until DataIn <> "y"
  DataIn := XB.Rx
  
  range0 := ping.Inches(ping_pin0)
  waitcnt(clkfreq/1_024 + cnt)
   
  range1 := ping.Inches(ping_pin1)
  waitcnt(clkfreq/1_024 + cnt)
   
  range2 := ping.Inches(ping_pin2)
  waitcnt(clkfreq/1_024 + cnt)
 
  If  range0 > distance and range1 > distance and range2 > distance and Straight == 0 and ForwardRamp == 0 and REVERSE == 0  and CCW == 0 and CW == 0  and  DataIn == "y"
   waitcnt(clkfreq + cnt)
   Straight := cognew(Forward, @stack)
  
  If range0 < distance and Straight == 0 and ForwardRamp == 0 and REVERSE == 0  and CCW == 0 and CW == 0   and  DataIn == "y"
   waitcnt(clkfreq + cnt)
   CCW := cognew(Rotate90CCW, @stack)

  If range1 < distance and Straight == 0 and ForwardRamp == 0 and REVERSE == 0  and CCW == 0 and CW == 0    and  DataIn == "y"
    waitcnt(clkfreq + cnt)  
    REVERSE := cognew(ReverseRampUpAndDown, @stack)
   
  If range2 < distance and Straight == 0 and ForwardRamp == 0 and REVERSE == 0  and CCW == 0 and CW == 0     and  DataIn == "y"
    waitcnt(clkfreq + cnt)   
    CW := cognew(Rotate90cw , @stack)
    

PUB Forward  | Square  


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
     
       repeat Square from 1 to 1                                                 ''This is my attemp to start the motors more slowly. It works but there is still a bit of a jolt. It might be inevetible.
        frqa := frqb := Square * SlowScale
        waitcnt(clkfreq/2 + cnt)
     
        
       repeat Square from 1 to 5                       
        frqa := frqb := Square * scale
        waitcnt(clkfreq/5 + cnt)
                         
    repeat until  DataIn <> "y" or  range0 < distance or range1 < distance or range2 < distance      'Speed holds here until conditions are met
      DataIn := XB.Rx
   
    ctra[30..26] := %00000                                                       ''Put this here to get rid of the sudden burst of the motors when they are stopping.
    ctrb[30..26] := %00000
       
    Straight := 0


Pub Manualforward | Square        'Needs to be adjusted to move smoothly.

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

   repeat Square from 1 to 1                                                 ''This is my attemp to start the motors more slowly. It works but there is still a bit of a jolt. It might be inevetible.
    frqa := frqb := Square * SlowScale
    waitcnt(clkfreq/2 + cnt)

    
  ' repeat Square from 1 to 5                       
   ' frqa := frqb := Square * scale
    'waitcnt(clkfreq/5 + cnt)
                     
repeat until  DataUD < 800                                       'Speed holds here until conditions are met
  DataIn := XB.Rx
   if DataIn == "!"   'UD                                    'Can use 33 or "!" here.
      DataUD := XB.RxDec              'DataIn sits at about 516ish                 'Must use XB.RxDec to receive a decimal.   
       
            



ctra[30..26] := %00000                                                       ''Put this here to get rid of the sudden burst of the motors when they are stopping.
ctrb[30..26] := %00000


PUB STOP
                                                 ''''''''''''''''''''''''''''''''''''Need to figure out how the stop method is implimented.

PUB ReverseRampUpAndDown | Square  

ctra[30..26] := %00100                                                            ''NEED TO ADD THE SENSING IN REVERSE COMMAND HERE.
ctrb[30..26] := %00100                     
                                        
ctra[5..0] := 20                              
ctrb[5..0] := 23                               

dira [19] := outa [19] := 1
dira [21] := outa [21] := 0                   
dira [22] := outa [22] := 1
dira [24] := outa [24] := 0                                                                              
                                                                             
dira[20]~~                                        
dira[23]~~
                                                   
  repeat 1
                                                   
    repeat Square from 1 to 7                                  ''Changed the Square durration from 1 to 10 down to 1 to 7
     frqa := frqb := Square * scale 
                                             
     waitcnt(clkfreq/20 + cnt)
   
    repeat Square from 5 to 1                                    
     frqa := frqb := Square * scale 
                                             
     waitcnt(clkfreq/20 + cnt) 

   ctra[30..26] := %00000
   ctrb[30..26] := %00000                      



waitcnt(clkfreq/2 + cnt)
                                                 '''''''''''''''''''''''''''''''''It strickly turns CCW after reversing.
if DataIn == "y"
  Rotate90CCW

REVERSE := 0                                    ''Have to set Reverse =  to 0 after the Rotate 90CCW not before.
                                                ''This should always be the last thing that a method does, and it shouldn't have a wait after it because
                                                ''as soon as REVERSE is set to 0, the cog that is running in the main method will start to open new cogs to run the method.
                                                ''This means that multiple cogs will be running the same method and setting variables to different values.


 
PUB Rotate90CCW  | Square                               
                                  
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
                                             
     waitcnt(clkfreq/20 + cnt)
   
    repeat Square from 5 to 1                                    
     frqa := frqb := Square * scale 
                                             
     waitcnt(clkfreq/20 + cnt) 

   ctra[30..26] := %00000
   ctrb[30..26] := %00000
                           
CCW := 0



PUB Rotate90CW  | Square                               
                                  
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
                                             
     waitcnt(clkfreq/20 + cnt)
   
    repeat Square from 5 to 1                                    
     frqa := frqb := Square * scale 
                                             
     waitcnt(clkfreq/20 + cnt) 

   ctra[30..26] := %00000
   ctrb[30..26] := %00000
                           
CW := 0

