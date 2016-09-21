''Play C6, D6, E6, F6, G6, A6, B6, C7 as quarter notes quarter stops between. 
CON 
_clkmode = xtal1 + pll16x ' System clock →80 MHz 
_xinfreq = 5_000_000


PUB TestFrequency | index 
                                                        'Configure ctra module 
ctra[30..26] := %00100                                  ' Set ctra for "NCO single-ended" 
ctra[5..0] := 8                                         ' Set APIN to P8
frqa := 0
                                                        ' Don't play any notes yet 
repeat index from 0 to 7 
  frqa := long[@notes][index]                             'Set the frequency. This command is unfamiliar, but seems like a good way to enter specific values in series.


                                ''This part plays the sound for 1/4 s then turns off for 1/4 s. Then index changes and therefore the note changes.
  dira[8]~~                                               ' Set P8 to output 
  waitcnt(clkfreq/4 + cnt)                                ' Wait for tone to play for 1/4 s 
  dira[8]~                                                '1/4 s stop 
  waitcnt(clkfreq/4 + cnt)


DAT

                                              '80 MHz frqa values for square wave musical note approximations with the counter module 
                                              'configured to NCO: 
                                              'C6 D6 E6 F6 G6 A6 B6 C7

notes long 56_184, 63_066, 70_786, 74_995, 84_181, 94_489, 105_629, 112_528 