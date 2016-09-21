''Working on PWM. Using PEK pg 163

''The H-bridgees on the Eddie board can recieve 0 - 20kHz.
''Main board opperates 6.75 - 18V
  
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


CON 
_clkmode = xtal1 + pll16x                                                   
_xinfreq = 5_000_000

SlowScale = 100_000   

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

{
PUB practice | tC, tHa, t
'This part is to test pwm on an led. Do not alter, just copy and paste then alter.

'This code sets the counter module of it's cog to single ended NCO mode.
'I'm not sure why the freq is set to 1.??????????????????

'tC is set to the number of clockfrequencies in one second(Or you can think of it as just setting the value of tC to one second).
'tHa is set to a quater of a second.
't is the current number that the clock is at. The internal clock is constantly counting. So anytime you want a timed event, you have to specify the number of clock cycles after the current
'clock number that you want it to happen.

'So for the code below, the repeat loop is doing all the work. The phsa register is what controls the duration of the pulse. Here it is set to pulse for 1/4clockfrequency which is 1/4 of a second.
'Basically what is happening is that the phsa is sending a single 1/4 second pulse. The loop just repeats every second. So it ends up being a 1/4 second pulse every second.

'If you alter the value of tHa, you alter the duration of the pulse.
'If you alter the value of tC, you alter the time of the repeat loop.

ctra[30..26] := %00100 
ctra[5..0] :=  0
dira[0]~~
frqa := 1

tC := clkfreq
tHa := clkfreq/4
t := cnt

repeat  
  phsa := -tHa                       'phsa is the length of the pulse duration.
  t += tC                            'Here we add one second to the current clock position
  waitcnt(t)                         'Here we wait for one second. 1/4 of this time is spent with phsa sending a pulse to the designated pin.

 }


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

{
PUB More | Frequency, Pulse_length, t 
'This section of code is a manipulation of the code above. The difference is that the variables are named a bit more intuitively and the frequency and pulse duration are manipulated.

ctra[30..26] := %00100 
ctra[5..0] :=  0
dira[0]~~
frqa := 1

Frequency := clkfreq/10_000       'This controls the frequency that the repeat loops cycles.
Pulse_length := Frequency/4       'This controls the duration within a single cycle of the above frequency that the led stays on. So 1/4th of 1/1000th of a second the pulse is high.
                                  'The lowest possible pulse width is 1/80_000_000. So Pulse_length >= 1/clkfreq
t := cnt                          'The current position of the clock.

repeat                            'We want the repeat loops to repeat 10-20k times per second. So the waitcnt time is 1/10,000th of a second.
  phsa := -Pulse_length           'phsa is the length of the pulse duration. The pulse length is 1/4th of 1/10,000th of a second.
  t += Frequency                  't is the current clock position + 1/10,000th of a second.
  waitcnt(t)

}

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

PUB Forward| Frequency, Pulse_length, t 
'This code is for testing the pwm on the robot. Here we use the insight gained through the above sections to send the correct pwm values to the H-bridges in order to get the desired speed from the motors.
'A frequency value of 1/20,000 gives the smoothest motor rotation and allows for the finest resolution of speed (Able to go slower). Leave Frequency here.
'The main variable to be altered is the value of Pulse_length. This determines the speed of the motors.
'Max speed is reached when Pulse_length = Frequency(Way too fast)
'Min speed is reached when Pulse_length = Frequency/12 (Without any load). 


ctra[30..26] := %00100           'Configures counters for CTRMODE(the 30..26 part) and single ended NCO mode(the %00100 part) .  
ctrb[30..26] := %00100
     
ctra[5..0] := 20 
ctrb[5..0] := 23                 'These pins are where the signal is sent.
                                                        
dira [19] := outa [19] := 0                     
dira [21] := outa [21] := 1
dira [22] := outa [22] := 0       'Selects the direction of the motors          
dira [24] := outa [24] := 1

frqa := frqb := 1
    
dira[20]~~                                        
dira[23]~~                        'Sets PWM pins as outputs(the ~~ part means they are outputs). 
 

                                  
  
Frequency := clkfreq/20_000       'This controls the frequency that the repeat loops cycles.
Pulse_length := Frequency/5       'This controls the duration within a single cycle of the above frequency that the led stays on. So 1/4th of 1/1000th of a second the pulse is high.
                                  'The lowest possible pulse width is 1/80_000_000. So Pulse_length >= 1/clkfreq
t := cnt                          'The current position of the clock.

repeat                            'We want the repeat loops to repeat 10-20k times per second. So the waitcnt time is 1/10,000th of a second.
  phsa := phsb:= -Pulse_length           'phsa is the length of the pulse duration. The pulse length is 1/4th of 1/10,000th of a second.
  t += Frequency                  't is the current clock position + 1/10,000th of a second.
  waitcnt(t)         

