''This version of LedDutySweep increases the brightness of the led and then decreases it and repeats.
''The trick to getting it to transition gradually from going brighter to going dimmer is to have a very small delay.

CON

scale = 16_777_216                                    ' 2��� 256

PUB TestDuty | pin, duty, mode

                                          ' Configure counter module.

ctra[30..26] := %00110                    ' Set ctra to DUTY mode. The [30..26] is the designation for duty mode.
                                          ' The %00110 is for single-ended duty mode
ctra[5..0] := 4                           ' Set ctra's APIN.  The [5..0] is the APIN designation here set to pin 4.
frqa := duty * scale                      ' Set frqa register 
                                          ' Use counter to take LED from off to gradually brighter, repeating at 2 Hz. 
dira[4]~~                                 ' Set P4 to output 
repeat                                    ' Repeat indefinitely 
 repeat duty from 50 to 255                ' Sweep duty from 0 to 255 
  frqa := duty * scale                    ' Update frqa register. frqa is the amount of time that the pin is high (duty equation).
                                          ' declared after ctra[5..0] above.
                                          
                                          ''So duty = timehigh / time    or    frqa / 4294967296 (2^32)(32 bit?)
                                          ''If frqa = 1073741824, then the duty supplied is 25% of full.



  
                                           
  waitcnt(clkfreq/128 + cnt)              ' Delay for 1/128th s

 repeat duty from 255 to 50               ''Here we're scaling down.
  frqa := duty * scale
                                          
  waitcnt(clkfreq/128 + cnt) 