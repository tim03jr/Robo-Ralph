Obj
   ping : "Ping"
Con
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
Var
  long range
  long Stack[36]
  long Stack1[36]
  long Stack2[36]
  long Stack3[36]
  long Stack4[36]
  long Stack5[36]
Pub Cogs
   cognew(Pingmethod(1), @Stack1)
     
   cognew(Pingmethod(2), @Stack2)
     
   Pingmethod(0)

Pub  Pingmethod(ping_pin)
  repeat
    range := ping.Inches(ping_pin)
    WaitCnt(ClkFreq / 4 + Cnt)
    if range < 10
       repeat
        dira[10]~~
        !outa[10]
        waitcnt (79_985_000 + Cnt)
        outa[10]~ 
   
    
      