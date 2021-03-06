'' Test RC circuit decay measurements.
''This code needs explanations
 
CON 
_clkmode = xtal1 + pll16x                                                                          ' System clock →80 MHz 
_xinfreq = 5_000_000


OBJ 
pst : "ParallaxSerialTerminal"                                                               ' Use with Parallax Serial Terminal to 
                                                                                                   ' display values 



PUB Init 
                                                                                                   'Start Parallax Serial Terminal; waits 1 s for you to click Enable button 
pst.Start(115_200) 
                                                                                                   ' Configure counter module.                                                                                                  
ctra[30..26] := %01000                   ''ctra is set                                             ' Set mode to [30..26](ctrmode) and %01000(POS detector(Positive detector mode))


                                    ''The Ctr command deals with a cog's
                                    ''counter modules. Each cog has two counter
                                    ''modules, A and B.
                                    ''The way that they are used is as follows:
                                    
                                    ''ctra [#..#] := %#####

                                    ''The [#..#] is the resgister map that tells
                                    ''what the ctr is doing. A list of the options
                                    ''for the interior of these brackets is listed
                                    ''on page 96 of the propeller manual.

                                    ''The %##### is the mode designation.
                                    






                                          ''ctra starts monitoring pin 7. (It's actually storing the value of pin 7 to the ctra's APIN register)
ctra[5..0] := 7                                                                        ' Set APIN to 7 (P7) 
frqa := 1                                 ''frq gets added to phsa automatically       ' Increments phsa by 1 for each clock tick. frqa can also be set to other things such as waitcnt... 
main                                                                                   ' Call the Main method


PUB Main | time
                                        ''Repeatedly takes and displays P7 RC decay measurements. 
  repeat 
                                                                                                   ' Charge RC circuit. 
    dira[7] := outa[7] := 1                                                                        ' Set pin to output-high 
    waitcnt(clkfreq/100_000 + cnt)                                                                 ' Wait for capacitor to charge 
                                                                                                   ' Start RC decay measurement. It's automatic after this... 
    phsa~                               ''phsa~ triggers the module to start.                      ' Clear the phsa register 
    dira[7]~                            ''pin goes low and cap decays.                             ' Pin to input stops charging circuit 
                                                                                                   ' Optional - do other things during the measurement. 
    pst.Str(String(pst#NL, pst#NL, "Working on other tasks", pst#NL))                              ''I think that pst#NL is the cairage return command

     
    repeat 22 
     pst.Char(".") 
     waitcnt(clkfreq/60 + cnt) 
                                                                                                   ' Measurement has been ready for a while. Adjust ticks between phsa~ & dira[17]~. 
    time := (phsa - 624) #> 0 
                                                                                                   ' Display Result 
    pst.Str(String(pst#NL, "time = ")) 
    pst.Dec(time) 
    waitcnt(clkfreq/2 + cnt)





    ''The next part of the PEK uses ctrB to measure the decay of a second cap. Two caps being measured by the counter modules of one cog.
    ''There's various RC decay measurement objects in the PEK kit folder.