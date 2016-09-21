'This is just to test the voltage on the AUX power ports connected to pins 16 17 18
'The AUX power ports are what powers the EL_tape on the Robo_Ralph.


CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

PUB power
  dira[16..18]~~ 
  repeat
     !outa[16..18]'~
     waitcnt(clkfreq/5 + cnt)
   
