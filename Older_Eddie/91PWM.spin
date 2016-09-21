''This code fades the Led in and out

Con
Led = 10


{{Pub FadeLightHightoLow | i, j                            ''Fades light in and out starting high
 repeat
  
   repeat until i => 1_600
     i := i + 10
     j :=  100
     
     dira[Led]~~
     outa[Led]~~
     waitcnt(clkfreq / i + cnt )
     outa[Led]~
     waitcnt(clkfreq / j + cnt)
   
  
  repeat until i =< 10
        i := i - 10
         
       dira[Led]~~
        outa[Led]~~
        waitcnt(clkfreq / i + cnt )
        outa[Led]~
        waitcnt(clkfreq / j + cnt)  

        }}
        
Pub Fadelightlowtohigh | i, j
 j :=  100 
 repeat 
         
   repeat i from 1_600 to 10         
        i := i - 10
        dira[Led]~~
        outa[Led]~~
        waitcnt(clkfreq / i + cnt )                           ''Fades light in and out starting low
        outa[Led]~
        waitcnt(clkfreq / j + cnt) 
   
  repeat i from 10 to 1_600
       i := i + 10
       dira[Led]~~
       outa[Led]~~
       waitcnt(clkfreq / i + cnt )
       outa[Led]~
       waitcnt(clkfreq / j + cnt) 
  





 
{{     
repeat i from 1 to 800                 ''This part sets the Led very dim
  dira[Led]~~
  outa[Led]~~
  waitcnt(clkfreq / 1_600 + cnt )
  outa[Led]~
  waitcnt(clkfreq / 100 + cnt)

         }}