''This is a cleaned up version of 99000ForwardReverse90.
''Lowered the square duration in the 90 method from 10 to 5 in order to actually rotate 90.
''Changed the top speed from 10 to 5 in the Forward and Reverse methods.

''Need to work out a few kinks.
''                               Somtimes there is a burst of speed at the beginning or the end of a movement.
''                               May need to put the motors in a stop mode where either all the pins are high or low.

''This code starts moving forward when the code is uploaded. When ping0 senses an object within 5 inches, the ForwardRampUpAndDown method is called.
''                                                           When ping1 senses an object within 5 inches, the ReverseRampUpAndDown method is called.
''                                                           When ping2 senses an object within 5 inches, the Rotate90CCW method is called.
 

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

ping_pin0 = 0
ping_pin1 = 1
ping_pin2 = 2
distance = 5

VAR

long range0
long range1
long range2
long stack[20]
long cog1
long cog2
long cog3
long cog4


PUB PingsMain   


repeat
  range0 := ping.Inches(ping_pin0)
  waitcnt(clkfreq/1_024 + cnt)
   
  range1 := ping.Inches(ping_pin1)
  waitcnt(clkfreq/1_024 + cnt)
   
  range2 := ping.Inches(ping_pin2)
  waitcnt(clkfreq/1_024 + cnt)


  If  range0 > distance and range1 > distance and range2 > distance and cog1 == 0 and cog2 == 0 and cog3 == 0  and cog4 == 0  
   waitcnt(clkfreq + cnt)
   cog1 := cognew(Forward, @stack)
   

  
  If range0 < distance and cog1 == 0 and cog2 == 0 and cog3 == 0  and cog4 == 0
   waitcnt(clkfreq + cnt)
   cog2 := cognew(ForwardRampUpAndDown, @stack)
                                                                               

  If range1 < distance and cog1 == 0 and cog2 == 0 and cog3 == 0  and cog4 == 0
    waitcnt(clkfreq + cnt)  
    cog3 := cognew(ReverseRampUpAndDown, @stack)


   
  If range2 < distance and cog1 == 0 and cog2 == 0 and cog3 == 0  and cog4 == 0
    waitcnt(clkfreq + cnt)   
    cog4 := cognew(Rotate90ccw , @stack)
    

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
   repeat Square from 1 to 5
    frqa := frqb := Square * scale
    waitcnt(clkfreq/5 + cnt)
                     
repeat until  range0 < distance or range1 < distance or range2 < distance

cog1 := 0
  
PUB ForwardRampUpAndDown    | Square
                                               
                                       
ctra[30..26] := %00100                        
ctrb[30..26] := %00100                         

                                        
ctra[5..0] := 20                              
ctrb[5..0] := 23                              


dira [19] := outa [19] := 0                  
dira [22] := outa [22] := 0
dira [21] := outa [21] := 1                                                                               
dira [24] := outa [24] := 1                                             
                                                                          
                                                                              
dira[20]~~                                        
dira[23]~~

                                                   
  repeat 1
                                              
    repeat Square from 1 to 10                
     frqa := frqb := Square * scale                                             
     waitcnt(clkfreq/5 + cnt)

   repeat Square from 10 to 1  
    frqa := frqb := Square * scale                                               
    waitcnt(clkfreq/5 + cnt) 

   ctra[30..26] := %00000
   ctrb[30..26] := %00000                       

cog2 := 0


PUB STOP

if Cog1 
 cogstop(Cog1 - 1)
 

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
                                                   
    repeat Square from 1 to 10                
     frqa := frqb := Square * scale 
                                             
     waitcnt(clkfreq/10 + cnt)
   
    repeat Square from 10 to 1                                    
     frqa := frqb := Square * scale 
                                             
     waitcnt(clkfreq/10 + cnt) 

   ctra[30..26] := %00000
   ctrb[30..26] := %00000                      

cog3 := 0

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
                                             
     waitcnt(clkfreq/10 + cnt)
   
    repeat Square from 5 to 1                                    
     frqa := frqb := Square * scale 
                                             
     waitcnt(clkfreq/10 + cnt) 

   ctra[30..26] := %00000
   ctrb[30..26] := %00000
                           
cog4 := 0
 
PUB ROTATE45CCW  ''Same as Rotate90ccw except for a shorter time

PUB ROTATE180CCW ''Same as Rotate90ccw except for a shorter time