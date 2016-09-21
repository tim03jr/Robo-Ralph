''The H-bridgees on the Eddie board can recieve 0 - 20kHz. That's what the H-bridge papers said, but I found that a much higher frequency is needed. Maybe it has to do with the fact that we're using a square wave rather than a PWM signal.
''Main board opperates 6.75 - 18V
''Here we're just sending a square wave to the LPWM pin(pin20). This is an easier way to scale the motors up and down.
''The frequency of the square wave is being incremented by the scale constant every time through the repeat loop.
''Controls only right wheel going forward.


CON 
_clkmode = xtal1 + pll16x                                                       ' Set up clkfreq = 80 MHz. 
_xinfreq = 5_000_000
scale = 900_000

PUB TestFrequency    | Square
                                               'Configure ctra module
                                       
ctra[30..26] := %00100                         ' Set ctra for "NCO single-ended"
                                               ' The [30..26] is for "counter mode" and the %00100 is for NCO mode of the "counter mode". NCO = numerically controlled oscillator.
                                        
ctra[5..0] := 20                               ' Set APIN to P20. Meaning that we are numerically controlling pin 20 
frqa := Square * scale                         ' Set frqa for pwm signal



                                                    'FRQA = frequency you want × (2^32 ÷ clkfreq)


                                                                               
dira [21] := outa [21] := 1
                                                                              
dira[20]~~                                         ' Set P20 to output. which starts the counter module. Don't have to set high(outa...)
                                                   
repeat

 repeat Square from 1 to 20                
  frqa := Square * scale
                                          
  waitcnt(clkfreq/10 + cnt)

  