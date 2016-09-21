{Lesson 6 AKA Output.spin. This is the code from lesson 6}
Var
  long Stack[9]
  byte Cog

Pub Start(Pin, Delay, Count): Success

  Stop
  Success := (Cog := cognew(Toggle(Pin, Delay, Count), @stack) +1)
Pub Stop

  if Cog
    cogstop(Cog~ -1)

Pub Active: YesNo

  YesNo := Cog > 0

Pub Toggle(Pin, Delay, Count)

  dira[Pin]~~
  repeat
    !outa[Pin]
    waitcnt(Delay +cnt)
  while Count := --Count #> -1
  Cog~        
    
  