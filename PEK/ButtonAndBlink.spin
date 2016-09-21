''This is the object that other files call







Pub ButtonTime(pin): delta | time1, time2                        ''calculates the button time

  repeat until ina[pin] == 1
  time1 := cnt
  repeat until ina[pin] == 0
  time2 := cnt
  delta := time2 - time1












Pub Blink (pin, rate, reps)                                      ''Blinks the led at the rate that the button was pressed.

  dira[pin]~~
  outa[pin]~

  repeat reps * 2
    waitcnt (rate/2 + cnt)
    !outa[pin]  