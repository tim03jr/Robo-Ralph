{{Display pushbutton states with Parallax Serial Terminal.

Pushbuttons 
───────────────────────────────────────────────────────────────────
        3.3 V           3.3 V           3.3 V 
                                        
          │               │               │
         ┤Pushbutton    ┤Pushbutton    ┤Pushbutton 
          │               │               │
P21 ───┫     P22 ───┫     P23 ───┫
     100  │          100  │          100  │
          │               │               │
          10 k           10 k           10 k                                                                                                                                                                                                                       ω
          │               │               │
                                        
         GND             GND             GND 
───────────────────────────────────────────────────────────────────
}}

{{Since I'm using the Quickstart board instead of the board of education,
the pins that the PEK uses will be different than the ones I'm using here:

Their pin 4 = my pin 16
Their pin 5 = my pin 17
Their pin 6 = my pin 18       These are the leds
Their pin 7 = my pin 19
Their pin 8 = my pin 20
Their pin 9 = my pin 21

Their pin 21 = my pin 5
Their pin 22 = my pin 6       buttons
Their pin 23 = my pin 7
}}


  
CON 
_clkmode = xtal1 + pll16x 
_xinfreq = 5_000_000

OBJ 
pst : "Parallax Serial Terminal"

PUB TerminalPushbuttonDisplay

                                                                  ''Read P23 through P21 pushbutton states and display with Parallax Serial Terminal.
pst.Start(115_200) 
pst.Char(pst#CS) 
pst.Str(String("Pushbutton States", pst#NL)) 
pst.Str(String("-----------------", pst#NL))

repeat 
 pst.PositionX(0) 
 pst.Bin(ina[7..5], 3) 
 waitcnt(clkfreq/100 + cnt) 