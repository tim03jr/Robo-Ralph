''TwoTones.spin 
''Play individual notes with each piezospeaker, then play notes with both at the 
''same time.

CON

_clkmode = xtal1 + pll16x ' System clock →80 MHz 
_xinfreq = 5_000_000

OBJ
 
SqrWave : "SquareWave"

PUB PlayTones | index, pin, duration
 
                                               'Initialize counter modules 
  repeat index from 0 to 1                     'Repeating when index is 0 and 1
    pin := byte[@pins][index]                  'First time through the loop, index = 0 therefore pin is set to 8.
    spr[8 + index] := (%00100 << 26) + pin     'Second time through, index = 1 therfore pin is set to 2.
    dira[pin]~~
                                               '<< is the shift command. %00100 gets shifted 26 places to the left.
                                               'The above cammand is equivalent to 8 * 2^26 = 536_870_912
                                   ''I'm not sure why the %00100 << 26 has to be there.......................

                                               ''SPR is the Special Purpose Register
                                               ''I think this repeat loop is just a different way of inititalizing
                                               ''the counter modules. The SPR command is an indirect way of accessing the cog's
                                               ''speacial purpose registers.
                                               ''Explanation of SPR on pg 200 Prop Manual.
                                               ''Here spr[8] is for ctrA and spr[9] is for ctrB.

                                               
    
                                                'Look up tones and durations in DAT section and play them. 
  repeat index from 0 to 4 
    frqa := SqrWave.NcoFrqReg(word[@Anotes][index]) 
    frqb := SqrWave.NcoFrqReg(word[@Bnotes][index]) 
    duration := clkfreq/(byte[@durations][index]) 
    waitcnt(duration + cnt)

DAT

pins byte 8, 2


'index               0      1      2      3     4

durations    byte    1,     2,     1,     2,    1 
anotes       word    1047,  0,     0,     0,    1047 
bnotes       word    0,     0,     1319,  0,    1319