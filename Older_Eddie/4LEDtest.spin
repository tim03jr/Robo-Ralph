Pub LEDtest
  dira[10]~~
  repeat
    !outa[10]
    waitcnt (3_000_000 + cnt)
    !outa[10]
    waitcnt (3_000_000 + cnt)
