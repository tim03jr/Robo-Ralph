'''''''''''''''''''''''''''''''''''''''''''''''''''TRACKS A HAND''''''''''''''''''''''''''''''''''''''''''''''


'HOW THE CODE WORKS:
'start Serial comm.
'receive K_Character(either an x or a z)
'if K_Character received is an x,
  'receive the data string immediately following the K_Character.
  'move left or right
  'wait for a z-K_Character to be received
  'when a z-K_Character is received, receive the data string immediately following the K_Character
  'move forward or backward

OBJ
Serial : "Extended_FDSerial"

CON 
_clkmode = xtal1 + pll16x                                                   
_xinfreq = 5_000_000
Baud      = 9600'
Speed = 6   'lower is faster.

VAR
long K_DataIn_z
long K_DataIn_x
word K_Character
long K_CharIn

PUB Start

Serial.start(31, 30, 0, 9600) 'Start (RXpin, TXPin, Mode, Baud) 

repeat          'FIRST ADJUST X-POS THEN Z-POS.

  Serial.RxFlush                         'This needed to clear out the rx buffer. Will give inaccurate values if not used.
  K_CharIn := Serial.Rx    
 
  if K_CharIn == "x"                      '1700 is approximately 4' from kinect. Larger = farther.
 
       K_DataIn_x := Serial.RxDec               'This recieves a string of numbers ending with a carriage return(\r).
     
    if K_DataIn_x < -100 'if hand is left, move left or if hand is right, move right
       K_CW(10_000)'move right until K_DataIn_x is within range
    if K_DataIn_x > 100
       K_CCW(10_000)'move left
     
    repeat until K_CharIn == "z"                     '1700 is approximately 4' from kinect. Larger = farther.
           Serial.RxFlush 
           K_CharIn := Serial.Rx

    K_DataIn_z := Serial.RxDec               'This recieves a string of numbers ending with a carriage return(\r).
       
       
    if K_DataIn_z > 1_400 and K_DataIn_z <> 0 
           K_forward(10_000)                       'Should be: Repeat until DataIn < ...
           waitcnt(clkfreq/100 + cnt)
       
    elseif K_DataIn_z < 1_000 and K_DataIn_z <> 0
           K_reverse(10_000)
           waitcnt(clkfreq/100 + cnt)

    
PUB K_Forward(iterations)  | Frequency, Pulse_length, t         'AUTO_kinect                    'Repeats until check does not equal 

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

      t := cnt                                     'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
      repeat iterations                                 'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.                           
          phsa := phsb:= -Pulse_length             'Why is this negative?
          t += Frequency                           'phsa is the length of the pulse duration.       
          waitcnt(t)
   
  ctra[30..26] := %00000                           'This is here to get rid of the sudden burst of the motors when they are stopping.
  ctrb[30..26] := %00000
  waitcnt(clkfreq/5 + cnt)
 
PUB K_Reverse(iterations) | Frequency, Pulse_length, t          ''For AUTO MODE.  Remember:  'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.

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
   
  t := cnt  
  repeat iterations                                                                    'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.                                                                  'The number here represents the number of times the repeat loop repeats.
           phsa := phsb:= -Pulse_length
           t += Frequency                                                           'phsa is the length of the pulse duration.       
           waitcnt(t)

    
  ctra[30..26] := %00000                           'This is here to get rid of the sudden burst of the motors when they are stopping.
  ctrb[30..26] := %00000  
  waitcnt(clkfreq/5 + cnt)                                                           'This is the pause between reversing and rotating 90 deg

PUB K_CW(iterations)  | Frequency, Pulse_length, t                            
                                  
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

 t := cnt                             
 repeat iterations
     phsa := phsb:= -Pulse_length                                   'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
     t += Frequency                                                 'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.
     waitcnt(t)
    
ctra[30..26] := %00000
ctrb[30..26] := %00000

Pub K_CCW(iterations) | Frequency, Pulse_length, t                      

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

 t := cnt                             
 repeat iterations
     phsa := phsb:= -Pulse_length                                   'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
     t += Frequency                                                 'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.
     waitcnt(t)
   
ctra[30..26] := %00000
ctrb[30..26] := %00000
       