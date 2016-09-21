''This code is used for testing pings

{{This code reads the data from the ping sensor and then prints it to the serial monitor.}}








Obj
                                          {{The object block declares which objects are used and the object symbols that represent them}}
  pst : "FullDuplexSerial"                {{pst is the symbol name and the "FullDuplexSerial" is the name of the object which is
                                            being assigned. We can reference these objects in our Pub and Pri methods.
                                            An example is
                                                            Pub name
                                                            S := pst.start        Here, we're saying that S equals the start method that
                                                                                  is within the pst object.}}

                                             
  ping : "Ping"                            {{Again, defining ping to be an object(another file)}}

Con                                        {{Declaring constants. _clkmode is the clockspeed which in this case uses the external
                                            crystal at 16x it's speed}}
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000                     {{Tells what the speed of the external crystal is.}}

  ping_pin = 0                             'I/O pin for Ping {{The pin is a constant that cannot be changed}}

Var
  long range                               {{Declaring range to be a Long variable. A long variable is pretty much any number(32 bits)}}

Pub Go
  pst.start(31,30,0,115200)                {{We're naming our Public method Go. We are calling the object we previously defined in our
                                            Obj block. So, pst represents the object(another file) called FullDuplexSerial. Here we
                                            are referencing the start method of that object. The numbers in the parentheses after
                                             pst.start fill in the variable in the start method of the the FullDup.. object. the
                                             variables look like this: (rxPin, txPin, mode, baudrate). rxPin = receiving pin,
                                             txPin = transmitting pin, mode = explained in the FullDup(in library).. and the 115200 =
                                             Baudrate.}}

                                             
  waitcnt (ClkFreq + Cnt)                    {{waitcnt just causes the program to pause for a set amount of time specified in parentesis.
                                               If can be used in any pub, pri blocks. The ClkFreq in the parenthesis is the current is
                                               the current clock frequency (Hz or some quantity per second). The Cnt is the current
                                               system counter that apparently just keeps growing as time passes. When we add the
                                               current system frequency(#/sec) to the Cnt, we are essentially creating a time
                                               for the program to pause. In this case the time is 1 second. So we're saying "add one
                                               seconds worth of cycles to the current running total of cycles up to this point. We can
                                               also divide the ClkFreq by some number to get a specific time. Ex) clkfreq/ 10 etc. }}

  repeat                                'Repeat forever              
    range := ping.Inches(ping_pin)      'Get range in inches           {{We previously defined range to be a long variable. The := sign
                                                                       {{is the variable assignment operator. It is used to assign a
                                                                         value to a variable within a method(locallyPub or Pri blocks).
                                                                         Here we are assigning the value that ping.Inches(ping_pin) returns
                                                                         to the variable "range."
                                                                         The ping part is a variable that we assigned to the object
                                                                         "Ping" earlier in out Obj block. With the ping.Inches(ping_pin),
                                                                         we are using the Inches method of the Ping object. The Inches
                                                                         of the Ping object takes the reading from the pin that we
                                                                         noted in parenthesis(ping_pin) and converts that to an inches
                                                                         reading with some simple math.}}


   pst.dec(range)                      'Display result                 {{Here we are using the symbol pst that we previouly declared
                                                                       {{to be the object "FullDuplexSerial". We are using the "dec"
                                                                         method from that object which prints whatever we have in
                                                                         parenthesis on the serial monitor.}}
                                                                         
    pst.tx(13)                                                           {{Same as just above, except that we are using the tx method.
                                                                           The tx method transmits whatever we put in parethesis to the
                                                                           tx pin. I'm not sure why there is a 13 here or why we need
                                                                           to include this.}}
    WaitCnt(ClkFreq / 4 + Cnt)          'Short delay until next read