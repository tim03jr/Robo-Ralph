'

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

Pin = 11
{
PUB Beep

  DIRA[Pin] := OUTA[Pin] := 1
  repeat 2
    repeat 350
      !OUTA[Pin]
      waitcnt(clkfreq/500 + cnt)

    waitcnt(clkfreq/2+ cnt)
  }

PUB Beeper | i, a
  DIRA[Pin] := OUTA[Pin] := 1
  
    repeat 2       
      repeat 300
        !OUTA[Pin]
        waitcnt(clkfreq/(500) + cnt)
      waitcnt(clkfreq/2+ cnt)
    repeat 1
      repeat 750
        !OUTA[Pin]
        waitcnt(clkfreq/(900) + cnt)
      waitcnt(clkfreq/2+ cnt)      

DIRA[Pin] := OUTA[Pin] := 0 