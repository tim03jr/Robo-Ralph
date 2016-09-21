{{PEK labs pg 69 - 72 }}

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
Pub ledtest                                ''Blinks led when pin 4 button is pressed. ................................................................................................................

dira [23]~~

repeat
   outa [23] := ina [4]  
  
  waitcnt(clkfreq / 50 + cnt)
}}


{{
Pub Main                                ''Calling a method when button is pressed..................................................................................................................

  repeat
   outa[21] := dira[21] := 1            ''Turns pin 21 led on to let us know that the button is ready to be pressed
   repeat until ina[7]                  ''The code stays right here until the pin 7 button = something other than 0
   outa[21] := 0                        ''pin 21 led turns off and the blink method is called
   Blink 
   waitcnt(clkfreq/2*3 + cnt)              ''After the blink method, there is a 3/2 of a second pause

Pub Blink | pin, rate, reps              ''Defining a method's behavior with local variables

  pin := 16                                     
  rate := clkfreq/3 
  reps := 9 
  dira[pin]~~ 
  outa[pin]~ 
  repeat reps * 2                       ''The light blinks 9 times even though the repeat loops 18 times.
   waitcnt(rate/2 + cnt)                ''Since the outa part only changes to on or off, we need 18 cycles
   !outa[pin]
}}



{{
Pub BlinkTest                          ''The idea here is that we can pass paramaters that are difined in the call rather than in the method itself............................................

Blink(16, clkfreq/3, 9)                ''Here are the parameters

PUB Blink( pin, rate, reps)            ''This is where the parameters get assigned

dira[pin]~~ 
outa[pin]~
                                         ''Same Blink function as in the method above
repeat reps * 2 
 waitcnt(rate/2 + cnt) 
 !outa[pin]
 }}



Pub BlinkTest2 | led                ''This part sends a changing variable to the blink method. The leds go through the Blink method in order then repeat............................................

   repeat                            
    repeat led from 16 to 21         ''repeats from 16 to 21 and back to 16
      outa[21] := dira[21] := 1      ''Led on pin 21 gets set high
      
      repeat until ina[7]            ''code stays here until pin 7 button = something other than 0
      outa[21] := 0                  ''Pin 21 led gets turned off here
      Blink(led, clkfreq/3, 9)       ''Blink method is called. Led value has already been asigned.
      waitcnt(clkfreq/2*3 + cnt)

PUB Blink( pin, rate, reps)            ''This is where the parameters get assigned

dira[pin]~~ 
outa[pin]~
                                         ''Same Blink function as in the method above
repeat reps * 2 
 waitcnt(rate/2 + cnt) 
 !outa[pin]      