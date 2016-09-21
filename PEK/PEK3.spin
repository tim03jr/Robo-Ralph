{{pg 72 - 80 }}

{{Since I'm using the Quickstart board instead of the board of education,
the pins that the PEK uses will be different than the ones I'm using here:

Their pin 4 = my pin 16
Their pin 5 = my pin 17
Their pin 6 = my pin 18       These are the leds
Their pin 7 = my pin 19
Their pin 8 = my pin 20
Their pin 9 = my pin 21

Their pin 21 = my pin 5
Their pin 22 = my pin 6
Their pin 23 = my pin 7
}}



{{
VAR 
long stack[30]                                          ''This is an array that we named stack. It has 30 slots each able to contain 1 "long" variable.......................................................

PUB LaunchBlinkCogs                                     ''Cog 0 launches all three cognew calls and goes to sleep
cognew(Blink(16, clkfreq/3, 9), @stack[0])              ''Cog 1 passes said parameters to the Blink method. Temperary data is stored in 0 - 9 stack array slots.
cognew(Blink(17, clkfreq/7, 21), @stack[10])            ''Cogs just go to sleep when done
cognew(Blink(18, clkfreq/11, 33), @stack[20])           ''Can launch a specific cog via coginit command.
 
PUB Blink( pin, rate, reps) 
dira[pin]~~ 
outa[pin]~ 
repeat reps * 2 
 waitcnt(rate/2 + cnt) 
 !outa[pin]
}}



{{
VAR                                                  ''Here we stop the cogs mid method with cogstop.......................................................................................................
long stack[30] 


PUB LaunchBlinkCogs 
cognew(Blink(16, clkfreq/3, 1_000_000), @stack[0]) 
cognew(Blink(17, clkfreq/7, 1_000_000), @stack[10]) 
cognew(Blink(18, clkfreq/11, 1_000_000), @stack[20]) 
waitcnt(clkfreq * 3 + cnt) 
cogstop(1) 
waitcnt(clkfreq + cnt) 
cogstop(2) 
waitcnt(clkfreq + cnt) 
cogstop(3)

PUB Blink( pin, rate, reps) 
dira[pin]~~ 
outa[pin]~ 
repeat reps * 2 
 waitcnt(rate/2 + cnt) 
 !outa[pin]
}}




{{
VAR                                                  ''Does the same thing as above in a different way......................................................................................................
long stack[30] 

PUB LaunchBlinkCogs | index

repeat index from 16 to 18 
 cognew(Blink(index , clkfreq/(index/3), 1_000_000), @stack[index * 10])         ''Calls all three cogs to run Blink method right away
  
waitcnt(clkfreq * 3 + cnt)                                                       ''Waits 3 seconds

repeat index from 1 to 3                                                         ''Shuts cogs down at 1 second intervals
 cogstop(index) 
 waitcnt(clkfreq + cnt)

PUB Blink( pin, rate, reps) 
dira[pin]~~ 
outa[pin]~ 
repeat reps * 2 
 waitcnt(rate/2 + cnt) 
 !outa[pin]
 }}




{{
PUB Main | time                                    ''Here we're blinking the light at a rate that is equal to the amount of time the button is pressed.......................................................
 Repeat 
   time := ButtonTime(7)                                                    ''A variable set equal to the return value of a method
   Blink(16, time , 10)                                                      ''After the ButtonTime method finishes, Blink starts where it sets the rate of blinking equal to the return of ButtonTime.
   
PUB Blink(pin, rate , reps)                                                  
  dira[pin]~~                                                                 ''pin variable is output
  outa[pin]~                                                                  ''pin variable is set off initially.

   repeat reps * 2 
    waitcnt(rate + cnt)                                                     ''pin blinks on and off for reps repititions.
    !outa[pin]
  
PUB ButtonTime(pin) | t1, t2                                                

 repeat until ina[pin]                                                      ''loop sticks here until button is pushed.
 t1 := cnt                                                                  ''When button is pushed, t1 is set to the value of the counter.
 repeat while ina[pin]                                                     ''Loop stays here while button is being pushed.
 t2 := cnt                                                                  ''When button is let go, t2 is set to the value of the counter.
 result := t2 - t1                                                          ''result = the time the button was being pushed.
 waitcnt(clkfreq/2 + cnt)
 }}
                                                                       ''That's what it's supposed to do anyway, but the light starts before even letting the button up.




VAR 
long stack[60] 
PUB ButtonBlinkTime | time, index, cog[6]                     ''supposed to blink a new led each time the button is pressed but all the leds just light up and blink randomly.................................

    repeat
     
     repeat index from 0 to 5                                                             ''repeats the loop 6 times
      time := ButtonTime(7)                                                               ''ButtonTime method gets called(delta gets set to equal time)
      cog[index] := cognew(Blink(index + 16, time, 1_000_000), @stack[index * 10])        ''the cognew command returns an id which gets stored to index.
      
     repeat index from 5 to 0 
      ButtonTime(7) 
      cogstop(cog[index])
  
PUB Blink( pin, rate, reps)

    dira[pin]~~ 
    outa[pin]~
    
    repeat reps * 2 
     waitcnt(rate/2 + cnt) 
     !outa[pin]
     
PUB ButtonTime(pin) : delta | time1, time2

    repeat until ina[pin] == 1
     time1 := cnt
     waitcnt(clkfreq/10 +cnt)                                                                      ''Maybe there's something wrong with the onboard button I'm using because the lights immidiately turn on when I 
    repeat until ina[pin] == 0                                                         ''push the button. I think that the lights are supposed to go on once I've let my finger off the button.
      time2 := cnt                                                                     ''Adding a pause ater the time1:= cnt line helps a lot.
       waitcnt(clkfreq/10 +cnt)
      delta := time2 - time1                                                               