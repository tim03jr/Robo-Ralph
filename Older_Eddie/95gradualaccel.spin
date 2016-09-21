''In this code I was trying to scale the speeds up and down.
''
''
''Next steps:  Have motors start gradually instead of full throttle immediately.
''             I think that I need a seperate cog to control ramping
''             Have the motors turn at different speeds in reverse to turn depending on which side the object is on.
''             Insert a start button to start the code.             



Obj
   ping : "Ping"
   
Con
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  
Var
  long range
  long range1
  long range2
  long Stack  [36]
  long Stack1 [36]
  long Stack2 [36]
  long Stack3 [36]
  long Stack4 [36] 
 
Pub  Main 
 repeat
    range  := ping.Inches(0)
    WaitCnt(ClkFreq / 400 + Cnt)

    range1 := ping.Inches(1)
    WaitCnt(ClkFreq / 400 + Cnt)

    range2 := ping.Inches(2)
    WaitCnt(ClkFreq / 400 + Cnt)
 
    
      
     if range < 2
      WheelStop (19,20,21,22,23,24)
      cognew(WheelReverse(19,20,21,22,23,24), @Stack4)
      waitcnt(clkfreq + cnt)

     if range1 < 2
      WheelStop (19,20,21,22,23,24)
      cognew(WheelReverse(19,20,21,22,23,24), @Stack4)
      waitcnt(clkfreq + cnt)

     if range2 < 2
      WheelStop (19,20,21,22,23,24)
      cognew(WheelReverse(19,20,21,22,23,24), @Stack4)
      waitcnt(clkfreq + cnt)

    If range and range1 and range2 > 2
      
      cognew(WheelForward(19,20,21,22,23,24), @Stack3)
      WaitCnt(ClkFreq / 400 + Cnt)                                                    ''These pauses keep the code from stopping after wheelstop
      

        
Pub WheelForward  (LReverse,LPWM,LForward,RReverse,RPWM,RForward) | i   

 
 
                                                          ''Motors move forward while range > 2
         dira [LReverse..RForward]~~
         outa [Lforward]~~
         outa [Rforward]~~
         outa[LPWM]~~
         outa[RPWM]~~
         
 
  
  
  
   
   

Pub WheelStop (LReverse,LPWM,LForward,RReverse,RPWM,RForward) | i 
    
                                                                          
         
         outa [LReverse..RForward]~                                            ''Motors stop
          

         Waitcnt(Clkfreq + cnt)                                               ''Waits 2 seconds
      
                                                                                  
   

Pub WheelReverse  (LReverse,LPWM,LForward,RReverse,RPWM,RForward) | i
      
                                                                                  ''Motors reverse 
          dira [LReverse..RForward]~~
          outa [LReverse]~~
          outa [RReverse]~~
          outa[LPWM]~~
          outa[RPWM]~~

         waitcnt(Clkfreq + cnt)                                              ''Waits for a second
          
          dira [LReverse..RForward]~~                                             ''Motors stop
          outa [LReverse]~
          outa [RReverse]~
          outa[LPWM]~
          outa[RPWM]~

          Waitcnt(Clkfreq + cnt)
        