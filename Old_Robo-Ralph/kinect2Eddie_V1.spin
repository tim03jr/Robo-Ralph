'RECEIVES DATA FROM PROCESSING. THE DATA REPRESENTS THE DISTANCE THAT A USER'S HAND IS AWAY FROM THE KINECT.
'IF THE DATA RECEIVED IS < 1600 REVERSE.
'IF THE DATA RECEIVED IS > 1800 FORWARD.
'IF IT'S EXACTLY 1700, BEEP.

OBJ
pst : "Parallax_Serial_Terminal"
fds : "FullDuplexSerial"
Serial : "Extended_FDSerial"

CON 
_clkmode = xtal1 + pll16x                                                   
_xinfreq = 5_000_000
Baud      = 9600'
Speaker_Pin = 7
Speed = 5


VAR
long DataIn
word Character
long SerialCOG


PUB Start

SerialCOG := Serial.start(31, 30, 0, 9600) 'Start (RXpin, TXPin, Mode, Baud) 

repeat

  Serial.RxFlush                         'This needed to clear out the rx buffer. Will give inaccurate values if not used.
  repeat 2                               'Have to repeat this twice because the first two values are inaccurate.
    DataIn := Serial.RxDec               'This recieves a string of numbers ending with a carriage return(\r).
   
  if DataIn == 1700                      '1700 is approximately 4' from kinect. Larger = farther.
    
        DIRA[Speaker_Pin] := OUTA[Speaker_Pin] := 1
        repeat 1
          repeat 350
            !OUTA[Speaker_Pin]
            waitcnt(clkfreq/500 + cnt)
         
          waitcnt(clkfreq/2+ cnt)
  
  elseif DataIn > 1_800 and DataIn <> 0 
       forward(10_000)                       'Should be repeat until DataIn < ...
       waitcnt(clkfreq/100 + cnt)

  elseif DataIn < 1_600 and DataIn <> 0
       reverse(10_000)
       waitcnt(clkfreq/100 + cnt)
       
  elseif DataIn == 0
      Stop
      waitcnt(clkfreq/100 + cnt)     

    
PUB Forward(iterations)  | Frequency, Pulse_length, t         'AUTO_kinect                    'Repeats until check does not equal 

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

  'start      'If this is here, it starts the method from the begining instead of where it left off.
  
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
   
  t := cnt  
  repeat iterations                                                                    'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.                                                                  'The number here represents the number of times the repeat loop repeats.
           phsa := phsb:= -Pulse_length
           t += Frequency                                                           'phsa is the length of the pulse duration.       
           waitcnt(t)

    
  ctra[30..26] := %00000                           'This is here to get rid of the sudden burst of the motors when they are stopping.
  ctrb[30..26] := %00000  
  waitcnt(clkfreq/5 + cnt)                                                           'This is the pause between reversing and rotating 90 deg

 ' start                          'If this is here, it starts the method from the begining instead of where it left off.                                          

PUB STOP

ctra[30..26] := %00000                           'This is here to get rid of the sudden burst of the motors when they are stopping.
ctrb[30..26] := %00000
waitcnt(clkfreq/5 + cnt)
start            