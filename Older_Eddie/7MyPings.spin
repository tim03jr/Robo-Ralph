{{This code causes the right wheel to turn. The PWM is sent to 22 although I'm not sure what the frequency is.}}





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
    if range < 2
      ''dira[10]~~
      dira [21]~~
      outa [21]~~
      dira [22]~~
      outa [22]~~
      dira [23]~~
      outa [23]~~
      repeat
         !outa[22]
         waitcnt (600_000 + cnt)
         !outa[22]
         waitcnt (600_000 + cnt)



      
       ''!outa[10]
       ''waitcnt (30_000_000 + cnt)
       '' !outa[10]
       ''waitcnt (30_000_000 + cnt)