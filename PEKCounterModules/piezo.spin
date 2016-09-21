''This code just sends a frequency to a speaker for 1 second. Uses NCO mode to emit a square wave.


CON 
_clkmode = xtal1 + pll16x                                                       ' Set up clkfreq = 80 MHz. 
_xinfreq = 5_000_000

PUB TestFrequency 
                                                                                'Configure ctra module
 
ctra[30..26] := %00100                  ' Set ctra for "NCO single-ended"
                                        ' The [30..26] is for "counter mode" and the %00100 is for NCO mode of the "counter mode". NCO = numerically controlled oscillator.
                                        
ctra[5..0] := 8                         ' Set APIN to P8. Meaning that we are numerically controlling pin 8 
frqa := 79_456                        ' Set frqa for 2093 Hz (C7 note) using:



                                                                                'FRQA = frequency you want × (2^32 ÷ clkfreq)


                                                                               
                                                                                'Broadcast the signal for 1 sec
dira[8]~~                                                                       ' Set P8 to output. Don't have to set high(outa...)
waitcnt(clkfreq + cnt)                                                          ' Wait for tone to play for 1 s



''Afer the waitcnt the counter module just stops. to keep the counter module active to be recalled later:

''1) Set pin 8 to input right after the waitcnt.

''2) Set the ctra register's ctrmode low by ctra[30.26]~ or := %00000

''3) Set frq to 0 