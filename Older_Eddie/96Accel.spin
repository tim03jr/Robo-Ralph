                                                           ''Next steps:  Have motors start gradually instead of full throttle immediately.
''          
''             Have the motors turn at different speeds in reverse to turn depending on which side the object is on.
''             Insert a start button to start the code.             



Obj
   ping : "Ping"
   
Con
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  led = 10
Var
  long range
  long range1
  long range2
  long totrange
  long Stack  [36]
  long Stack1 [36]
  long Stack2 [36]
  long Stack3 [36]
  long Stack4 [36]
  
 
Pub  Main 




 repeat
   {{ range  := ping.Inches(0)
    WaitCnt(ClkFreq / 40 + Cnt)
     }}
    
    range1 := ping.Inches(1)
    WaitCnt(ClkFreq / 2 + Cnt)


     {{
    range2 := ping.Inches(2)
    WaitCnt(ClkFreq / 40 + Cnt)
     }}
    {{
     if range and range1 and range2 > 2
     cognew(WheelForward(19,20,21,22,23,24), @Stack3)
     WaitCnt(ClkFreq / 40 + Cnt)    }}
      
    {{ if range < 2
      cognew(WheelStop(19,20,21,22,23,24), @Stack4)
      waitcnt(clkfreq + cnt)
    }}

      
     if range1 < 2
       cognew(WheelStop(19,20,21,22,23,24), @Stack4)
       waitcnt(clkfreq + cnt)
     else
       WheelForward(19,20,21,22,23,24)
       ''cognew(WheelForward(19,20,21,22,23,24), @Stack3)
       waitCnt(ClkFreq / 2 + Cnt)
      {{
     if range2 < 2
      cognew(WheelStop(19,20,21,22,23,24), @Stack4)
      waitcnt(clkfreq + cnt)
      }}

                                                    ''These pauses keep the code from stopping after wheelstop
     
Pub WheelForward  (LReverse,LPWM,LForward,RReverse,RPWM,RForward) | j, i    


   dira[10]~~ 
 '' repeat                                                      ''Motors move forward while range > 2

       
  
    !outa[10]
    waitcnt (clkfreq + cnt)
    !outa[10]
   '' waitcnt (clkfreq + cnt)
'' while range1 {{and range1 and range2}} > 2
        {{ j:= 100
        repeat i from 400 to 1                                ''Motors climb to top speed slowly
         
         i := i - 1
         dira [LReverse..RForward]~~
         outa [LForward]~~
         outa [RForward]~~
         outa[LPWM]~~
         outa[RPWM]~~
         waitcnt(clkfreq / i + cnt )
         outa [LForward]~
         outa [RForward]~
          outa[LPWM]~
          outa[RPWM]~
          waitcnt(clkfreq / j + cnt)
        repeat i from 1 to 400
          i := i + 1                                      ''Motors decelerate slowly
          outa [LForward]~~
          outa [RForward]~~
          outa[LPWM]~~
          outa[RPWM]~~
          waitcnt(clkfreq / i + cnt )
          outa [LForward]~
          outa [RForward]~
          outa[LPWM]~
          outa[RPWM]~
          waitcnt(clkfreq / j + cnt)    

          }}


        {{dira [LReverse..RForward]~~
         outa [Lforward]~~
         outa [Rforward]~~
         outa[LPWM]~~
         outa[RPWM]~~  }}
         

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
         