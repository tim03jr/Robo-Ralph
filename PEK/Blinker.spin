''An object to be referenced by other objects

{{
SCHEMATIC 
───────────────────────────────
       100 ωLED 
pin ──────────┐
                   
                  GND 
───────────────────────────────
}}

 
VAR 
long stack[10]                                                                           'Cog stack space 
byte cog                                                                                 'Cog ID 

PUB Start(pin, rate, reps) : success                                                     'the ": success" means that the return value for the start method gets stored as success.

{{Start new blinking process in new cog; return True if successful. 
Parameters:                                                                              ''EVERY OBJECT THAT HAS A COGNEW COMMAND SHOULD HAVE A "START" AND "STOP" METHOD.
                                                                                         ''COGNEW CAN ONLY CALL METHODS WITHIN THE SAME OBJECT.
pin - the I/O connected to the LED circuit →see schematic                                ''IT'S BEST TO KEEP COGNEW COMMANDS IN "START" METHODS.
rate - On/off cycle time is defined by the number of clock ticks 
reps - the number of on/off cycles 
}}

Stop                                                                                     'Any currently running cog gets stoped (Except for the one reading stop I guess.)
success := (cog := cognew(Blink(pin, rate, reps), @stack) + 1)                           'The return value "success" gets set to the return value of the blink method. Here success = cog I think. 


PUB Stop 
                                                                                        ''Stop blinking process, if any. 
if cog                                                                                  ''If cog = something other than 0, cogstop...
 cogstop(cog~ - 1)                                                                      ''The ~ after cog means that the cog variable will be set to 0 after the operation(not before).



PUB Blink(pin, rate, reps)                                                              ''This method blinks the led
 
{{Blink an LED circuit connected to pin at a given rate for reps repetitions. 
Parameters: 
pin - the I/O connected to the LED circuit →see schematic 
rate - On/off cycle time is defined by the number of clock ticks 
reps - the number of on/off cycles 
}}
 
dira[pin]~~ 
outa[pin]~

repeat reps * 2 
 waitcnt(rate/2 + cnt) 
 !outa[pin] 