''Enter frequencies to play on the piezospeaker and display the frq register values 
''with Parallax Serial Terminal. 


CON 
_clkmode = xtal1 + pll16x ' System clock →80 MHz 
_xinfreq = 5_000_000 


OBJ 
pst : "ParallaxSerialTerminal"                                ' Parallax Serial Terminal display object 


PUB Init 
                                                               'Configure ctra module. 
ctra[30..26] := %00100                                         ' Set ctra for "NCO single-ended" 
ctra[5..0] := 8                                                ' Set APIN to P8 
frqa := 0                                                      ' Don't send a tone yet. 
dira[8]~~                                                      ' I/O pin to output
 
                                'Start Parallax Serial Terminal object -launches serial driver into another cog.

pst.Start(115_200) 
Main                                                            ' Call main method. 


PUB Main | frequency, temp 
repeat 
  pst.Str(String("Enter a frequency: ")) 
  frequency := pst.DecIn 
  temp := NcoFrqReg(frequency) 
  pst.Str(String("frqa = ")) 
  pst.Dec(temp) 
  pst.NewLine
  
                               'Broadcast the signal for 1 s
  
  frqa := temp 
  waitcnt(clkfreq + cnt) 
  frqa~


PUB NcoFrqReg(frequency) : frqReg 
{{ 
Returns frqReg = frequency × (2³² ÷ clkfreq) calculated with binary long 
division. This is faster than the floating point library, and takes less 
code space. This method is an adaptation of the CTR object's fraction 
method. 
}}
 
repeat 33
 
  frqReg <<= 1 
  if frequency => clkfreq 
    frequency -= clkfreq 
    frqReg++ 
  frequency <<= 1 