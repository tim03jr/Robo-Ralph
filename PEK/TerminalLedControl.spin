{{Enter LED states into Parallax Serial Terminal. Propeller chip receives the states and lights the corresponding LEDs. 


LED SCHEMATIC 
──────────────────────
     (all) 
      100   LED 
P16 ──────────┐
                   │
P17 ──────────┫
                   │
P18 ──────────┫
                   │
P19 ──────────┫
                   │
P20 ──────────┫
                   │
P21 ──────────┫
                   
                  GND 
──────────────────────

}}
 
CON 
_clkmode = xtal1 + pll16x 
_xinfreq = 5_000_000

OBJ 
pst : "Parallax Serial Terminal"

PUB TerminalLedControl

''Set/clear I/O pin output states based binary patterns 
''entered into Parallax Serial Terminal. 
pst.Start(115_200) 
pst.Char(pst#CS) 
dira[16..21]~~

repeat 
 pst.Str(String("Enter 6-bit binary pattern: ")) 
 outa[16..21] := pst. BinIn