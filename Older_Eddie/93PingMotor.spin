''This code causes the motor to go forward immidiately then stop and reverse when the single ping connected to pin 0 senses an object within 2 inches.
''Next steps:  have motors start gradually instead of full throttle immediately.
''             Have multiple pings controlling the motors instead of just one.
''             Have the motors turn at different speeds in reverse to turn depending on which side the object is on.
''             Insert a start button.             



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
  long Stack4 [36]
 

Pub  Pingmethod(ping_pin)
 
 repeat
    range := ping.Inches(0)
    WaitCnt(ClkFreq / 40 + Cnt)

    if range > 2
     cognew(WheelForward(19,20,21,22,23,24), @Stack3)
      
    if range < 2
     cognew(WheelStop(19,20,21,22,23,24), @Stack4)
     waitcnt(clkfreq + cnt)                                                        ''This pause seems to be the crucial bit that keeps the code from stopping after wheelstop
     
Pub WheelForward  (LReverse,LPWM,LForward,RReverse,RPWM,RForward)     
       repeat while range >= 2                                                     ''Motors move forward while range > 2
         dira [LReverse..RForward]~~
         outa [Lforward]~~
         outa [Rforward]~~
         outa[LPWM]~~
         outa[RPWM]~~
         

Pub WheelStop (LReverse,LPWM,LForward,RReverse,RPWM,RForward) | i 
    
      repeat i from 1 to 1                                                                            ''Motors stops 
         dira [LReverse..RForward]~~
         outa [LReverse]~
         outa [RReverse]~
         outa[LPWM]~
         outa[RPWM]~       

         Waitcnt(Clkfreq + cnt)                                               ''Waits 3 seconds
      
                                                                                  ''Motors reverse 
           dira [LReverse..RForward]~~
           outa [LReverse]~~
           outa [RReverse]~~
           outa[LPWM]~~
           outa[RPWM]~~
           
          waitcnt(Clkfreq + cnt)                                              ''Waits for 3 seconds
          
          dira [LReverse..RForward]~~                                             ''Motors stop
          outa [LReverse]~
          outa [RReverse]~
          outa[LPWM]~
          outa[RPWM]~
          
         Waitcnt(Clkfreq + cnt)  