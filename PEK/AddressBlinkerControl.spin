'' Enter LED states into Parallax Serial Terminal and send to Propeller chip via 
'' Parallax Serial Terminal.
''This program works with the "AddressBlinker" object. 


 
CON 
_clkmode = xtal1 + pll16x 
_xinfreq = 5_000_000

OBJ 
pst : "Parallax Serial Terminal" 
AddrBlnk: "AddressBlinker"
 
VAR 
long pin, rateDelay                                  ''32 bit


PUB UpdateVariables
 
                                                     '' Update variables that get watched by AddressBlinker object. 
pst.Start(115_200) 
pin := 16                                            ''Buadrate
rateDelay := 10_000_000                              ''initial rate delay
AddrBlnk.Start(@pin, @rateDelay)                     ''Calls start method of the "AddressBlinker" object
dira[16..21]~~

repeat 
  pst.Str(String("Enter pin number: "))              ''Prints this
  pin := pst.DecIn                                   ''sends pin through DecIn method
  pst.Str(String("Enter delay clock ticks:")) 
  rateDelay := pst.DecIn 
  pst.Str(String(pst#NL)) 