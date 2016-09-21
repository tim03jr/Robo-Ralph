'This code increases the value of Pos[0] or Pos[1] by 1 everytime the encoder goes high(I think it's high).
'Knowing the count of the encoders gives us thier absolute position
'I tried to match each wheels position


'Parameters to tune:       (Make them all easily accessible here)
'The waitcnt in main and EncRead


OBJ
  Encoder : "Quadrature Encoder"
  pst : "Parallax_Serial_Terminal"  

VAR
  long Pos[3]                            'Create buffer for two encoders (plus room for delta position support of 1st encoder)
  long stack[50]
  long stack1[50]
  long stack2[50]
  long ForwardCog_L
  long ForwardCog_R
  long ReadCog
  long time
  long Position_Right
  long Position_Left
  long Pulse_length_Right
  long Pulse_length_Left
  
CON
_clkmode = xtal1 + pll16x                                                   
_xinfreq = 5_000_000
speed =  4

PUB Main                                 'This method is using the Encoder object.
  Encoder.Start(8, 2, 1, @Pos)           'Start continuous two-encoder reader (encoders connected to pins 8 - 11)
  pst.start(115200)
  ForwardCog_R := cognew(ForwardRight, @stack)     'This is the one with the drag
  ForwardCog_L := cognew(ForwardLeft, @stack1)    
  ReadCog := cognew(EncRead, @stack2)

  'Position := 0
  'time := 0
  Pos[0] := 0           
  Pos[1] := 0
  repeat
     Position_Right := Pos[0]             'Read each encoder's absolute position
     Position_Left := Pos[1]
    'time := Encoder.ReadDelta(0)   'Read 1st encoder's delta position (value since last read)             'This just produces a buch of 0's with sparse 1's
    
   {  
      pst.str(String("Right"))  
      pst.dec(Pos[0])
      pst.Str(String(pst#NL))
      pst.str(String("Left")) 
      pst.dec(Pos[1])
   }
   {
      pst.str(String("Pulse_length_right"))
      pst.dec(Pulse_length_right)
      pst.Str(String(pst#NL))
      waitcnt(clkfreq/100 + cnt)
    }
  ' waitcnt(clkfreq/100 + cnt) 

PUB EncRead                               'Keeping the added amount at zero seems to yield the most consistant results
 repeat
   ' waitcnt(clkfreq/10 +cnt)
    'Pulse_length_Right -= 1 
    if ||Position_Right > ||Position_Left
     
       Pulse_length_Right -=  5
    '   pst.str(String("down"))  'For debugging
    '   pst.Str(String(pst#NL))  
    if ||Position_Right < ||Position_Left
   
       Pulse_length_Right += 5
     '  pst.str(String("up"))     'For debugging
     '  pst.Str(String(pst#NL))

  waitcnt(clkfreq/10 + cnt)    
           
  
PUB ForwardRight  | Frequency, t                          'This one has the drag 

'ctra[30..26] := %00100       'Setting up counter modules for PWM
ctrb[30..26] := %00100
     
'ctra[5..0] := 20 'This controls it's LEFT motor
ctrb[5..0] := 23  'This controls it's RIGHT motor
                                                        
dira [19] := outa [19] := 0                     
dira [21] := outa [21] := 1
dira [22] := outa [22] := 0                     
dira [24] := outa [24] := 1

frqb := 1                     'The frq register adds one to the current value of the phs register. 
     
'dira[20]~~                                        
dira[23]~~

Frequency := clkfreq/20_000           'This controls the frequency that the repeat loops cycles
Pulse_length_Right := Frequency/Speed       'This controls the duration within a single cycle of the above frequency that the led stays on. The minumum pulse width is 1/80_000_000. So Pulse_length >= clkfreq

 
  repeat 
    t := cnt                                     'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
    repeat 1_000                                 'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.                           
        phsb:= -Pulse_length_Right             'Why is this negative?
        t += Frequency                           'phsa is the length of the pulse duration.       
        waitcnt(t)

PUB ForwardLeft  | Frequency, t                         

ctra[30..26] := %00100       'Setting up counter modules for PWM
'ctrb[30..26] := %00100
     
ctra[5..0] := 20 'This controls it's LEFT motor
'ctrb[5..0] := 23  'This controls it's RIGHT motor
                                                        
dira [19] := outa [19] := 0                     
dira [21] := outa [21] := 1
dira [22] := outa [22] := 0                     
dira [24] := outa [24] := 1

frqa := 1                     'The frq register adds one to the current value of the phs register. 
     
dira[20]~~                                        
'dira[23]~~

Frequency := clkfreq/20_000           'This controls the frequency that the repeat loops cycles
Pulse_length_Left := Frequency/Speed       'This controls the duration within a single cycle of the above frequency that the led stays on. The minumum pulse width is 1/80_000_000. So Pulse_length >= clkfreq

 
  repeat 
    t := cnt                                     'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
    repeat 1_000                                 'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.                           
        phsa := -Pulse_length_Left             'Why is this negative?
        t += Frequency                           'phsa is the length of the pulse duration.       
        waitcnt(t)    