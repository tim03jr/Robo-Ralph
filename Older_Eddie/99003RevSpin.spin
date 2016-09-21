''This code works good. It is fully automatic.




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
Button    = 8

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


PUB PingsMain   


'repeat until ina[Button]                              ''This is for the initiation button.
                             
waitcnt (clkfreq + cnt)

repeat
  range0 := ping.Inches(ping_pin0)
  waitcnt(clkfreq/1_024 + cnt)
   
  range1 := ping.Inches(ping_pin1)
  waitcnt(clkfreq/1_024 + cnt)
   
  range2 := ping.Inches(ping_pin2)
  waitcnt(clkfreq/1_024 + cnt)


  If  range0 > distance and range1 > distance and range2 > distance and Straight == 0 and ForwardRamp == 0 and REVERSE == 0  and CCW == 0 and CW == 0  
   waitcnt(clkfreq + cnt)
   Straight := cognew(Forward, @stack)
  
  If range0 < distance and Straight == 0 and ForwardRamp == 0 and REVERSE == 0  and CCW == 0 and CW == 0
   waitcnt(clkfreq + cnt)
   CCW := cognew(Rotate90CCW, @stack)

  If range1 < distance and Straight == 0 and ForwardRamp == 0 and REVERSE == 0  and CCW == 0 and CW == 0
    waitcnt(clkfreq + cnt)  
    REVERSE := cognew(ReverseRampUpAndDown, @stack)
   
  If range2 < distance and Straight == 0 and ForwardRamp == 0 and REVERSE == 0  and CCW == 0 and CW == 0
    waitcnt(clkfreq + cnt)   
    CW := cognew(Rotate90cw , @stack)
    

PUB Forward     | Square  

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
                     
repeat until  range0 < distance or range1 < distance or range2 < distance

ctra[30..26] := %00000                                                       ''Put this here to get rid of the sudden burst of the motors when they are stopping.
ctrb[30..26] := %00000
   
Straight := 0


PUB STOP
                                                 ''''''''''''''''''''''''''''''''''''Need to figure out how the stop method is implimented.

PUB ReverseRampUpAndDown | Square  

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
                                                 '''''''''''''''''''''''''''''''''Need to put some sort of rotation here.

Rotate90CCW

REVERSE := 0                                    ''Have to set Reverse =  to 0 after the Rotate 90CCW not before.
                                                ''This should always be the last thing that a method does, and it shouldn't have a wait after it because
                                                ''as soon as REVERSE is set to 0, the cog that is running in the main method will start to open new cogs to run the method.
                                                ''This means that multiple cogs will be running the same method and setting variable to different values.



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