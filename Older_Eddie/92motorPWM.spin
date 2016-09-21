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
     

Pub Wheelpower(LReverse,LPWM,LForward,RReverse,RPWM,RForward) | i , j
    
  {{  repeat i from 1 to 25_000                         ''Motors reverse for 25000 clock cycles
       dira [LReverse..RForward]~~
      outa [LReverse]~~
      outa [RReverse]~~
      outa[LPWM]~~
      outa[RPWM]~~ }}




 j :=  100 
  
 repeat        
   repeat i from 200 to 1                                ''Motors climb to top speed slowly
        i := i - 1
        dira [LReverse..RForward]~~
        outa [LReverse]~~
        outa [RReverse]~~
        outa[LPWM]~~
        outa[RPWM]~~
        waitcnt(clkfreq / i + cnt )
        outa [LReverse]~
        outa [RReverse]~
        outa[LPWM]~
        outa[RPWM]~
        waitcnt(clkfreq / j + cnt) 
   
  repeat i from 1 to 200
       i := i + 1                                      ''Motors decelerate slowly
        outa [LReverse]~~
        outa [RReverse]~~
        outa[LPWM]~~
        outa[RPWM]~~
        waitcnt(clkfreq / i + cnt )
        outa [LReverse]~
        outa [RReverse]~
        outa[LPWM]~
        outa[RPWM]~
        waitcnt(clkfreq / j + cnt)  


