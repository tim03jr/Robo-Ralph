''This code is the same as "leddutysweep" except that this one uses two counter modules at once where 
''both leds flash pulse together.



scale = 16_777_216                                    ' 2³²÷ 256

PUB TestDuty | pin, duty, mode

                                          ' Configure counter module.

ctra[30..26] := %00110                    ' Set ctra to DUTY mode. The [30..26] is the designation for duty mode.
ctrb[30..26] := %00110                    ' The %00110 is for single-ended duty mode.
                                           
ctra[5..0] := 4                           ' Set ctra's APIN.  The [5..0] is the APIN designation here set to pin 4.
ctrb[5..0] := 0
frqa := duty * scale                      ' Set frqa register 
                                          ' Use counter to take LED from off to gradually brighter, repeating at 2 Hz. 
                                          ' Set P4 to output
dira[0]~~
dira[4]~~
repeat                                    ' Repeat indefinitely 
 repeat duty from 0 to 255                ' Sweep duty from 0 to 255 
                                          ' Update frqa register. frqa is the amount of time that the pin is high (duty equation).
  frqa := frqb := duty * scale
                                          ' declared after ctra[5..0] above.
                                          
                      ''So duty = timehigh / time    or    frqa / 4294967296 (2^32)(32 bit?)
                      ''If frqa = 1073741824, then the duty supplied is 25% of full.



  
                                           
  waitcnt(clkfreq/128 + cnt)              ' Delay for 1/128th s 