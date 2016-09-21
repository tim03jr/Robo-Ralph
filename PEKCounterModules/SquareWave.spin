'' From Parallax Inc. Propeller Education Kit - Counters & Circuits Lab 
'' SquareWave.spin 
'' Can be used to make either or both of a given cog's counter modules transmit square 
'' waves.

''It's weird that we dont have to declare a counter module to use CTRMODE as in other examples.
''Also, it's weird that we don't have to use ctrA or ctrB specifically and that instead we use just ctr.
 
PUB Freq(Module, Pin, Frequency) | s, d, ctr
 
                                                        '' Determine CTR settings for synthesis of 0..128 MHz in 1 Hz steps 
                                                        '' 
                                                        '' Pin is the  pin to output frequency on 
                                                        '' Freq = actual Hz to synthesize 
                                                        '' 
                                                        '' ctr and frq hold ctra/ctrb and frqa/frqb values 
                                                        '' 
                                                        '' Uses NCO mode %00100 for 0..499_999 Hz 
                                                        '' Uses PLL mode %00010 for 500_000..128_000_000 Hz 
                                                        ''

  Frequency := Frequency #> 0 <# 128_000_000                     'limit frequency range between 0 and 128M 
  if Frequency < 500_000                                         'if 0 to 499_999 Hz, 
    ctr := constant(%00100 << 26)                                'set counter module to NCO mode and all other bits to 0.
                                                                 'The << 26 sets all other bits to zero
     
    s := 1                                                       'shift = 1
    
  else                                                           'if 500_000 to 128_000_000 Hz, 
    ctr := constant(%00010 << 26)                                '..set PLL mode 
    d := >|((Frequency - 1) / 1_000_000)                         'determine PLLDIV 
    s := 4 - d                                                   'determine shift 
    ctr |= d << 23                                              
                                                                 'set PLLDIV 
  spr[10 + module] := fraction(Frequency, CLKFREQ, s)            'Compute frqa/frqb value 
  ctr |= Pin                                                     'set PINA to complete ctra/ctrb value 
                                                                 'This is a Bitwise OR operation. It is a short form of ctr := ctr | Pin.  
                                                                 'I think it that if either ctr or Pin is a 1, then a 1 gets stored in ctr. Pg165 propManual
  spr[8 + module] := ctr                                                                
  dira[pin]~~
 
PUB NcoFrqReg(frequency) : frqReg
 
                                                        {{ 
                                                        Returns frqReg = frequency × (2³² ÷ clkfreq) calculated with binary long 
                                                        division. This is faster than the floating point library, and takes less 
                                                        code space. This method is an adaptation of the CTR object's fraction 
                                                        method. 
                                                        }}
 
frqReg := fraction(frequency, clkfreq, 1)

PRI fraction(a, b, shift) : f
 
  if shift > 0                                       'if shift, pre-shift a or b left 
    a <<= shift                                      'to maintain significant bits while 
  if shift < 0                                       'insuring proper result 
    b <<= -shift
 
repeat 32                                           'perform long division of a/b 
  f <<= 1 
  if a => b 
    a -= b 
    f++ 
  a <<= 1