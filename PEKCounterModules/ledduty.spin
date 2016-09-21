''Sets the duty mode to 25%

pub CounterModules

ctra [30..26] := %00110               ''single ended duty mode
ctra [5..0]   := 4                    ''APIN is set to 4

dira[4]~~
repeat
 frqa := 1_073_741_824                ''the number is 1/4 of 2^32 (25% duty cycle)

 waitcnt (clkfreq/128 + cnt)