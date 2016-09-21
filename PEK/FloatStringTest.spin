''Solve a floating point math problem and display the result with Parallax Serial 
''Terminal. 




CON 
_clkmode = xtal1 + pll16x 
_xinfreq = 5_000_000


OBJ 
pst : "Parallax Serial Terminal" 
fMath : "FloatMath" 
fString : "FloatString"


PUB TestFloat | a, b, c

                                                                 '' Solve a floating point math problem and display the result. 
pst.Start(115_200) 
a := 1.5 
b := pi                                                          ''Sends the assigned values for a and b to the FloatMath object.
c := fmath.FAdd(a, b) 
pst.Str(String("1.5 + Pi = "))                                   ''Displays the part in red.
pst.Str(fstring.FloatToString(c))                                ''Displays the answer to the problem.