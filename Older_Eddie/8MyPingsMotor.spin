''This code causes the motors to spin forward when an object is within 2 inches of the Ping sensors.

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
  
Pub Cogs
   cognew(Pingmethod(1), @Stack1)
     
   cognew(Pingmethod(2), @Stack2)
     
   Pingmethod(0)

Pub  Pingmethod(ping_pin)
  repeat
    range := ping.Inches(ping_pin)
    WaitCnt(ClkFreq / 4 + Cnt)
    if range < 2

      dira [19..24]~~
      outa [19..24] := %011011                        ''The left three digits after the % sign are for the left motor and the right are for the right.
                                                      ''Where the center of each group of three is the pwm and the digits to the right and left of the center control the directions.
                                                      ''Left digit = reverse          Right digit = forward
    
      {{ repeat
         
         !outa[20]
         !outa[23]                                    ''This part has no effect. The motors are basically getting full power.
         waitcnt (800_000 + cnt)                      ''Changing the wait time does affect the smoothness of the motors.
         
         
         !outa[20]
         !outa[23]
         waitcnt (800_000 + cnt)  }}
      
      