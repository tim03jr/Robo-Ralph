''Causes motors to ramp together in response to ping sensors.
''Forward method pulses up and stops, repeats.
''Reverse method ramps up then down and stops.

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
_clkmode = xtal1 + pll16x                                                       ' Set up clkfreq = 80 MHz. 
_xinfreq = 5_000_000
scale = 800_000

ping_pin0 = 0
ping_pin1 = 1
ping_pin2 = 2

var

long range0
long range1
long range2
long stack[20]
long cog1 

PUB PingsMain 

repeat
  range0 := ping.Inches(ping_pin0)
  waitcnt(clkfreq/1_024 + cnt)
   
  range1 := ping.Inches(ping_pin1)
  waitcnt(clkfreq/1_024 + cnt)
   
  range2 := ping.Inches(ping_pin2)
  waitcnt(clkfreq/1_024 + cnt)


  ''Cognew forward.


   
  If range0 < 2
    ForwardRampUpAndDown                ''Need to get it going forward initially, then stop when it detects something, then reverse and stop.
                                        ''------------------------------------------------------------------------------------------------------

  If range1 < 2
    ReverseRampUpAndDown

  If range2 < 2
    Rotate90ccw   


PUB ForwardRampUpAndDown    | Square
                                               'Configure ctra module
                                       
ctra[30..26] := %00100                         ' Set ctra for "NCO SINGLE ENDED"
ctrb[30..26] := %00100                         ' Set ctrb for "NCO SINGLE ENDED"


                                                 ' The [30..26] is for "counter mode" and the %00100 is for NCO mode of the "counter mode". NCO = numerically controlled oscillator.
                                        
ctra[5..0] := 20                               ' Set APIN to P20. Meaning that we are numerically controlling pin 20
ctrb[5..0] := 23                               ' Set BPIN to P23. Meaning that we are numerically controlling pin 23


                                                    'FRQA = frequency you want × (2^32 ÷ clkfreq)


dira [19] := outa [19] := 0                     ''Have to turn reverse pins off.
dira [22] := outa [22] := 0                                                                               
dira [21] := outa [21] := 1                     ''REMEMBER THAT DIRA IS ITS OWN THING. DIRB DOES NOT EXIST!!!
dira [24] := outa [24] := 1                     ''SAME THING WITH OUTA!!
                                                                              
dira[20]~~                                         ' Set P20 to output. which starts the counter module. Don't have to set high(outa...)
dira[23]~~
                                                   
  repeat 1
   
    repeat Square from 0 to 10                
     frqa := frqb := Square * scale 
                                            
     waitcnt(clkfreq/10 + cnt)
    repeat Square from 10 to 1                    ''It's important to have 1 here rather than 0. Having zero causes a sudden burst right before it stops.                
   
     frqa := frqb := Square * scale 
                                              
      waitcnt(clkfreq/10 + cnt) 

   ctra[30..26] := %00000
   ctrb[30..26] := %00000                        ''Copying 0 to the counter modules to turn them off and return to pingmain.
pingsmain

PUB STOP

   ''This is to stop cogs. Blinker object says need start and stop objects when using cogstop





PUB ReverseRampUpAndDown | Square  ''This method ramps up and down in reverse in response to range0 

ctra[30..26] := %00100                         ' Set ctra for "NCO SINGLE ENDED"
ctrb[30..26] := %00100                         ' Set ctrb for "NCO SINGLE ENDED"


                                                 ' The [30..26] is for "counter mode" and the %00100 is for NCO mode of the "counter mode". NCO = numerically controlled oscillator.
                                        
ctra[5..0] := 20                               ' Set APIN to P20. Meaning that we are numerically controlling pin 20
ctrb[5..0] := 23                               ' Set BPIN to P23. Meaning that we are numerically controlling pin 23


                                                    'FRQA = frequency you want × (2^32 ÷ clkfreq)


dira [21] := outa [21] := 0                     ''Have to turn forward pins off.
dira [24] := outa [24] := 0                                                                              
dira [19] := outa [19] := 1                     ''REMEMBER THAT DIRA IS ITS OWN THING. DIRB DOES NOT EXIST!!!
dira [22] := outa [22] := 1                     ''SAME THING WITH OUTA!!
                                                                              
dira[20]~~                                         ' Set P20 to output. which starts the counter module. Don't have to set high(outa...)
dira[23]~~
                                                   
  repeat 1
   
    repeat Square from 0 to 10                
     frqa := frqb := Square * scale 
                                             
     waitcnt(clkfreq/10 + cnt)
   
    repeat Square from 10 to 1                    ''It's important to have 1 here rather than 0. Having zero causes a sudden burst right before it stops.                
     frqa := frqb := Square * scale 
                                             
     waitcnt(clkfreq/10 + cnt) 

   ctra[30..26] := %00000
   ctrb[30..26] := %00000                        ''Copying 0 to the counter modules to turn them off and return to pingmain.
pingsmain  

PUB Rotate90CCW  | Square                                   ''Wheels turnig in opposite directions.

                                  
ctra[30..26] := %00100                         ' Set ctra for "NCO SINGLE ENDED"
ctrb[30..26] := %00100                         ' Set ctrb for "NCO SINGLE ENDED"


                                                 ' The [30..26] is for "counter mode" and the %00100 is for NCO mode of the "counter mode". NCO = numerically controlled oscillator.
                                        
ctra[5..0] := 20                               ' Set APIN to P20. Meaning that we are numerically controlling pin 20(PWM left)
ctrb[5..0] := 23                               ' Set BPIN to P23. Meaning that we are numerically controlling pin 23(PWM Right)


                                                    'FRQA = frequency you want × (2^32 ÷ clkfreq)                                                                                          MOTOR pin key

                                                                                                                                                               ''     on             pin 19 = Left reverse
                                                                                                                                                               ''     on             pin 20 = PWM left
                                                                                                                                                               ''      off           pin 21 = Left forward
                                                                                                                                                               ''      off           pin 22 = Right reverse
                                                                                                                                                      ''->     ''     on             pin 23 = PWM right
                                                                                                                                         '''''''''''''         ''     on             pin 24 = Right forward
                                                                                                                       ''''''''''''''''''
                                                                        '''''''''''''''''''''''''''''''''''''''''''''''
dira [21] := outa [21] := 0   ''''''''''''''''''''''''''''''''''''''''''                  
dira [24] := outa [24] := 1                                                                                
dira [19] := outa [19] := 1                     ''REMEMBER THAT DIRA IS ITS OWN THING. DIRB DOES NOT EXIST!!!
dira [22] := outa [22] := 0                     ''SAME THING WITH OUTA!!
                                                                              
dira[20]~~                                         ' Set P20 to output. which starts the counter module. Don't have to set high(outa...)
dira[23]~~
                                                   
  repeat 1
   
    repeat Square from 0 to 10                
     frqa := frqb := Square * scale 
                                             
     waitcnt(clkfreq/10 + cnt)
   
    repeat Square from 10 to 1                    ''It's important to have 1 here rather than 0. Having zero causes a sudden burst right before it stops.                
     frqa := frqb := Square * scale 
                                             
     waitcnt(clkfreq/10 + cnt) 

   ctra[30..26] := %00000
   ctrb[30..26] := %00000                        ''Copying 0 to the counter modules to turn them off and return to pingmain.
pingsmain 


PUB ROTATE45CCW  ''Same as Rotate90ccw except for a shorter time

PUB ROTATE180CCW ''Same as Rotate90ccw except for a shorter time