{{pg 75 - }}


{{Since I'm using the Quickstart board instead of the board of education,
the pins that the PEK uses will be different than the ones I'm using here:

Their pin 4 = my pin 16
Their pin 5 = my pin 17
Their pin 6 = my pin 18       These are the leds
Their pin 7 = my pin 19
Their pin 8 = my pin 20
Their pin 9 = my pin 21

Their pin 21 = my pin 5
Their pin 22 = my pin 6       buttons
Their pin 23 = my pin 7
}}




{{
PUB Main | time
                                                                                    ''This code blinks at a rate similar to the time the button was held down.................................................
                                                                                     ''The reason that the code wasn't working was because the vss on the board is actually ground, so I had it wire backwards.

  Repeat 
   time := ButtonTime(7) 
   Blink(16, time/10, 10)
   
PUB Blink(pin, rate, reps)

  dira[pin]~~ 
  outa[pin]~
  
  repeat reps * 2 
    waitcnt(rate/2 + cnt) 
    !outa[pin]
    
PUB ButtonTime(pin) : dt | t1, t2

 repeat until ina[pin]
 t1 := cnt                                                             
 repeat while ina[pin]
 t2 := cnt 
 dt := t2 - t1
}}




{{
obj                                                              ''This practice in calling methods in other objects.........................................................................................

 pbLed : "ButtonandBlink"                                        ''The object ButtonandBlink gets named pbled

PUB Main | time                                                  ''This method is the top method that calls all of the other objects and methods

 repeat
                                                                 ''The return value of the ButtonTime method of the ButtonandBlink object is set to the local time variable 
   time := pbLed.ButtonTime(7)

   PbLed.Blink(16, time, 10 )                                     ''The Blink method of the ButtonandBlink object is called.
}}






OBJ
                                                           ''This is called "CogObjectExabple" in PEK
Blinker : "Blinker" 
Button : "Button"

PUB ButtonBlinkTime | time

repeat 
 time := Button.Time(7) 
 Blinker.Start(16, time, 20)   