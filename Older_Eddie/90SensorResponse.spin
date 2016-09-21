{{This program moves the wheels for 25000 clock cycles and then starts sensing again.}}


Obj
   ping : "Ping"
   
Con
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  
Var
  long range
  long Stack  [36]
  long Stack1 [36]
  long Stack2 [36]
  long Stack3 [36]
  
  
Pub Cogs
   cognew(Pingmethod(1), @Stack1)
     
   cognew(Pingmethod(2), @Stack2)
     
   Pingmethod(0)

Pub  Pingmethod(ping_pin)
 
 repeat
    range := ping.Inches(ping_pin)
    WaitCnt(ClkFreq / 4 + Cnt)

    if range < 2
     cognew(Wheelpower(19,20,21,22,23,24), @Stack3)
    ''else if range > 2
     

Pub Wheelpower(LReverse,LPWM,LForward,RReverse,RPWM,RForward) | i 
    
    repeat i from 1 to 25_000
       dira [LReverse..RForward]~~
      outa [LReverse]~~
      outa [RReverse]~~
      outa[LPWM]~~
      outa[RPWM]~~
                                
     {{ waitcnt (800_000 + cnt)
      !outa[LPWM]
      !outa[RPWM]
      waitcnt (800_000 + cnt) }}
    