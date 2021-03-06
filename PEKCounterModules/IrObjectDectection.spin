'' IrObjectDetection.spin 
'' Detect objects with IR LED and receiver and display with Parallax Serial Terminal.
''Whe infrared light is detected, the IR reciever lets current pass to an input pin.

CON

_clkmode = xtal1 + pll16x ' System clock →80 MHz 
_xinfreq = 5_000_000

OBJ

pst : "ParallaxSerialTerminal" 
SqrWave : "SquareWave"
 
PUB IrDetect | state

                                    ' This block Starts 38 kHz square wave 
SqrWave.Freq(0, 1, 38000)                     ' 38 kHz signal →P1
                                               'I guess the counter module is 0??

 
dira[1]~                                      ' Set pin 1 to input when no signal needed 
                                              
pst.Start(115_200)                            ' Start Parallax Serial Terminal. Baudrate = 115,200
repeat 
                                    ' This block detects an object. 
  dira[1]~~                                   ' Pin 1 is set to output to transmit 38 kHz squarewave 
  waitcnt(clkfreq/1000 + cnt)                 ' Wait 1 ms 
  state := ina[0]                             ' Store input from I/R detector in the state variable 
  dira[1]~                                    ' Pin 1 is set to input to stop signal
   
                                    ' This block Displays detection (0 detected, 1 not detected) 
  pst.Str(String(pst#HM, "State = "))         ' Uses the PST to print on serial monitor
  pst.Dec(state)                              ' Prints the value of state.
  pst.Str(String(pst#NL, "Object "))          ' Prints the word object.

  if state == 1                               'If state = 1, print the word "not."
   pst.Str(String("not "))                    
  pst.str(String("detected.", pst#CE)) 
  waitcnt(clkfreq/10 + cnt)