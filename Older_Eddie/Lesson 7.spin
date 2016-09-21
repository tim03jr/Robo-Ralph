{{Lesson 7 AKA blinker2. This code blinks a bunch of leds at different rates. This program calls the Lesson6 object, so you have
to have it open in the work tab on the left. }}
Con
  _clkmode  = xtal1 + pll4x
  _xinfreq = 5_000_000     {{This sets the internal clock to slow mode(20kHz)
                            Could use _Clkmode = Rcfast to put clock in fast mode(12MHz)
                            Could also use the internal clock by using _Clkmode = xtal1 in which case we
                            would also need to state the frequency of the crystal on the pin the the external crystal
                            is connected to. Ex) _xinfreq = 5_000_000 }}
  Maxleds = 6

Obj
  Led[Maxleds] : "Output"                    {{Object block. Define an array to have 6(maxleds) elements. This allows
                                               us to have six simultaneous processes running at the same time.}}
                                               
Pub Main

  dira[16..23]~~
  Led[NextObject].Start(16,   250, 0)       {These lines are are ones that run through the Lesson6 code}
  Led[NextObject].Start(17,   500, 0)
  Led[NextObject].Start(18,    50, 300)
  Led[NextObject].Start(19,   500, 40)
  Led[NextObject].Start(20,    29, 300)
  Led[NextObject].Start(21,   104, 250)
  Led[NextObject].Start(22,    63, 200)
  Led[NextObject].Start(23,    33, 160)
  Led[0].Start(20, 1000, 0)
  repeat                                            {repeat is here to keep the a cog alive}

Pub NextObject : Index                              {{don't really get what happening here.}}

  repeat
    repeat Index from 0 to Maxleds-1
      if not Led[Index].Active
        Quit
  while Index == Maxleds      