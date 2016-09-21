on                                        {{Declaring constants. _clkmode is the clockspeed which in this case uses the external
                                            crystal at 16x it's speed}}
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000                     {{Tells what the speed of the external crystal is.}}

  ping_pin = 4                             'I/O pin for Ping {{The pin is a constant that cannot be changed}}

Var
  long range                               {{Declaring range to be a Long variable. A long variable is pretty much any number(32 bits)}}

Pub Freq

dira[0]~~
outa[0]~~
repeat
  !outa[0]
  waitcnt(clkfreq/440  + cnt)



