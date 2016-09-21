'' Send text messages stored in the DAT block to Parallax Serial Terminal.
''The thing about this code is that is makes use of the data declared in the data block rather than having to repeat the typing of the data each time you want to use it.


CON 
_clkmode = xtal1 + pll16x 
_xinfreq = 5_000_000 
OBJ 
pst : "Parallax Serial Terminal" 
PUB TestDatMessages | value, counter 
''Send messages stored in the DAT block. 
pst.Start(115_200) 
repeat 
  pst.Str(@MyString)                                                                     ''Data is called with an @ symbol
  pst.Dec(counter++) 
  pst.Str(@MyOtherString) 
  pst.Str(@BlankLine) 
  waitcnt(clkfreq + cnt) 
DAT 
MyString byte "This is test message number: ", 0                                         ''The string stops when it reaches a 0
MyOtherString byte ", ", pst#NL, "...and this is another line of text.", 0 
BlankLine byte pst#NL, pst#NL, 0