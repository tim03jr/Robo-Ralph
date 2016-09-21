''



CON 
_clkmode = xtal1 + pll16x 
_xinfreq = 5_000_000

OBJ 
pst : "Parallax Serial Terminal"                                      ''Object declaration



{{
PUB TestMessages                                                      ''This program sends the phase "Test message" to the serial terminal...............................................................

''Send test messages to Parallax Serial Terminal. 
pst.Start(115_200)                                                    ''Object call. The start method of Pst extablishes a connection.

repeat 

 pst.Str(string("This is a test message!"))                           ''Pst is called and prints the phrase
 Pst.NewLine 
 waitcnt(clkfreq + cnt)
}}






PUB TestMessages | counter                                            ''This program sends the phase "counter = number" to the serial terminal.  Where the value of counter gets incremented each time through.

''Send test messages to Parallax Serial Terminal. 
pst.Start(115_200)                                                    ''Object call. The start method of Pst extablishes a connection.


repeat
 pst.Str(String("counter= "))
 pst.Dec(counter++)
 pst.NewLine
 waitcnt(clkfreq+5 + cnt) 