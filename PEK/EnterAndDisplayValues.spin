''This code uses the serial terminal to communicate with the chip.


CON 
 _clkmode = xtal1 + pll16x 
 _xinfreq = 5_000_000
 
OBJ

pst : "Parallax Serial Terminal"

Var                                                               ''Can make value a local variable if pst.Bin(value, 32) instead of 16
word  value


PUB TwoWayCom                                                      ''Type in value and pst returns hex and binary............................................................................................

''Test Parallax Serial Terminal number entry and display. 
pst.Start(115_200) 
pst.Clear

repeat 
  pst.Str(String("Enter a decimal value: ")) 
  value := pst.DecIn 
  pst.Str(String(pst#NL, "You Entered", pst#NL, "--------------")) 
  pst.Str(String(pst#NL, "Decimal: ")) 
  pst.Dec(value) 
  pst.Str(String(pst#NL, "Hexadecimal: ")) 
  pst.Hex(value, 8) 
  pst.Str(String(pst#NL, "Binary: ")) 
  pst.Bin(value, 16) 
  repeat 2 
   pst.NewLine




   