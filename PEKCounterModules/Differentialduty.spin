''This code makes use of the counter module's differential mode where BPIN is set to opposite of APIN.
''So as pin 4 led gets brighter, pin 2 led gets dimmer.



scale = 16_777_216                                    ' 2��� 256

PUB TestDuty | pin, duty, mode

                                          ' Configure counter module.

ctra[30..26] := %00111                    ' Set ctra to DUTY mode. The [30..26] is the designation for duty mode.
                                          ' The %00111 is for differential duty mode. 
ctra[5..0]   := 4                         ' Set ctra's APIN.  The [5..0] is the APIN designation here set to pin 4.
ctra[14..9]  := 2
frqa := duty * scale                      ' Set frqa register 

                                          ' Use counter to take LED from off to gradually brighter, repeating at 2 Hz. 
dira[4]~~                                 ' Set P4 to output
dira[2]~~
repeat                                    ' Repeat indefinitely 
 repeat duty from 0 to 255                ' Sweep duty from 0 to 255 
  frqa := duty * scale                    ' Update frqa register. frqa is the amount of time that the pin is high (duty equation).
                                          ' declared after ctra[5..0] above.
                                          
                      ''So duty = timehigh / time    or    frqa / 4294967296 (2^32)(32 bit?)
                      ''If frqa = 1073741824, then the duty supplied is 25% of full.



  
                                           
  waitcnt(clkfreq/128 + cnt)              ' Delay for 1/128th s 