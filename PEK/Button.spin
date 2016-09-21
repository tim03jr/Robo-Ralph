''This object is to calculate the time that the button is pressed.


PUB Time(pin) : delta | time1, time2 
repeat until ina[pin] == 1 
time1 := cnt 
repeat until ina[pin] == 0 
time2 := cnt 
delta := time2 - time1 