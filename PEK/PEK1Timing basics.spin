pub pin high and output
        ''Here are a few ways to set a pin as an output and high:
        
 dira[4] := 1
 outa[4] := 1

      ''is the same as...

 dira[4]~~
 outa[4]~~

      ''is the same as...

 dira[4] := outa[4] := 1







 
Pub button equals led state

          ''If using an input to control something:

 dira[4] := 1
 dira[5] := 0

 repeat
  outa[4] := ina[5]





  


Pub what waitcnt is

 waitcnt (clkfreq + cnt)      ''This waits until the system counter reaches the value in parenthesis
                              ''In this case the the wait time is 1 second.



  waitcnt (clkfreq/4*3 + cnt)  ''The wait time here is 3/4 of a second





  
  

pub adds one to the value outa[9..4] each time through.
''So the first is 00000 the second is 00001 the third is 00010 etc going through all the permutations.

dira[9..4]~~ 
outa[9..4]~ 
repeat 
 waitcnt(clkfreq/2 + cnt) 'change to (clkfreq + cnt) to slow down the loop 
 outa[9..4] := outa[9..4] ++





 


 
pub increment in the repeat loop

 repeat until outa[4]++ == 19                       ''counts to 20. the value of outa is evaluated before being incremented.

  waitcnt (clkfreq + cnt)

''Can do the same thing with while







Pub Creating a shift pattern

  repeat 
    if outa[9..4] == 0 
     outa[9..4] := %100000 
      waitcnt(clkfreq/10 + cnt)                     ''The shift operator >>= moves the pins in the outa [9..4] := %100000 command over a said amount. Here the pins move over by one each time
      outa[9..4] >>= 1                              ''So the %100000 becomes %010000 etc.







Pub   The Limit Minimum “#>”and Limit Maximum “<#” Operators


 if ina[22] == 1                                    ''Keeps the variable "divide" below or equal to a maximum of 254
    divide ++ 
    divide <#= 254







Pub  keeping code stuck in loop until condition is met



repeat until ina[23]                              ''Code repeats until ina [23] equals something other than 0