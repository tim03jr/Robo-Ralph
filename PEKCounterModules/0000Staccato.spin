CON 
_clkmode = xtal1 + pll16x ' System clock →80 MHz 
_xinfreq = 5_000_000


{{
PUB TestFrequency     ''Here we're using toggling the Apin to be input or output in order to get a beeping tone.

                                               'Configure ctra module 
ctra[30..26] := %00100                         ' Set ctra for "NCO single-ended" 
ctra[5..0] := 8                                ' Set APIN to P8 
frqa := 112_367                                ' Set frqa for 2093 Hz (C7 note):

 
                                               'fifteen on/off beep cycles in 1 second.
repeat 30
 !dira[8]                                       ' Set P8 to output. Don't have to use outa...
                                                ' 
 waitcnt(clkfreq/30 + cnt)                      ' Repeating 30 times with a 1/30 of a second pause means the staccato plays for 1 sec.

                                               'Program ends, which also stops the counter module. Changing the waitcnt slows the beeping down.
}}




Pub TestFrequency      ''Here we're using a different way to accomplish the beeping. Set pin 8 to output, copy 00100 to bitfield then copy 00000 to bitfield, repeat. 


ctra[30..26] := %00100                     
ctra[5..0] := 8                                
frqa := 112_367                                

 
dira[8]~~                                              
repeat 15
 ctra[30..26]  := %00100                                      
                                                 
 waitcnt(clkfreq/30 + cnt)

 ctra[30..26]  := %00000                                      
                                                 
 waitcnt(clkfreq/30 + cnt)
                        