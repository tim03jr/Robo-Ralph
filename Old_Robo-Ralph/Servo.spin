' Want to limit the range of the front and expand the range of the rear.



CON 
_clkmode = xtal1 + pll16x                                                   
_xinfreq = 5_000_000

Servo_Pin = 5



Pub stopit
repeat
 waitcnt(10)
 
 
PUB Servo_pan_Micro  | Frequency, Pulse_length, t, i

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


  


 {
PUB Servo_pan_Standard  | Frequency, Pulse_length, t, i

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
    t := cnt                                       'The reading of the current clock position must be as close as possible to the repeat loop within which it is used.
    repeat while i < 20000              'Cannot check DataIn := XB.Rx while in the repeat loop. The timing of the loop is important. The time it takes to check XB.Rx throws off the pwm.                           
        i += 1200
        phsa := phsb := -(pulse_length + i)            'Why is this negative?
        t += Frequency                           'phsa is the length of the pulse duration.       
        waitcnt(t)

    t := cnt
    repeat while i > -100000
        i -= 1200
        phsa := phsb := -(pulse_length + i)            'Why is this negative?
        t += Frequency                           'phsa is the length of the pulse duration.       
        waitcnt(t)

  }      
PUB Specific_Pos | Frequency, Pulse_length, t

 ctra[30..26] := %00100       'Setting up counter modules for PWM  
 ctra[5..0] := Servo_Pin
 frqa := frqb := 1                     'The frq register adds one to the current value of the phs register. 
 dira[Servo_Pin]~~

 Frequency := clkfreq/50           'Freq = 50Hz 

 'PULSE LENGTH RANGE
 'Pulse_length := clkfreq/1750 
 'Pulse_length := clkfreq/1667      '0   degrees, pulse width = 0.0006s.
 'Pulse_length := clkfreq/1111      '30  deg
 'Pulse_length := clkfreq/1100      '75  deg   'Middle
 'Pulse_length := clkfreq/476       '150 deg
 Pulse_length := clkfreq/450 
 t := cnt                                       
    repeat
        phsa := phsb := -(pulse_length)            'Why is this negative?
        t += Frequency                                 'phsa is the length of the pulse duration.       
        waitcnt(t)       