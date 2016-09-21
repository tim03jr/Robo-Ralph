'This object is to test the IR sensor on the Robo-Ralph
'The range that the IR sensors yield is from about 2500(close) and about 200(far). 1500 = about 5 inches


'For the Eddi board:
'  P25 = cs
'  P26 = DIO
'  P27 = CLK

''   dpin  = pin connected to both DIN and DOUT on MCP3208
''   cpin  = pin connected to CLK on MCP3208
''   spin  = pin connected to CS on MCP3208
''   mode  = channel enables in bits 0..7, diff mode enables in bits 8..15

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  'BitsRead = 12
  chipSel = 25  
  chipDIO = chipSel+1
  chipClk = chipSel+2 

OBJ
  ADC : "MCP3208"
  pst : "Parallax_Serial_Terminal"
  
VAR
  long stack2[25]
  word SensorReading
  word DataRead
  
PUB Using_object
  pst.start(115200)
  ADC.start(chipDIO, chipCLK, chipSel, 255)                                  'start(dpin, cpin, spin, mode)

  repeat
     pst.Str(String(pst#cs, pst#NL, pst#HM, "adc channel 0= "))
     pst.dec(adc.in(0))
     pst.Str(String(pst#NL, "adc channel 1= "))
     pst.dec(adc.in(1))
     pst.Str(String(pst#NL, "adc channel 2= "))
     pst.dec(adc.in(2))
     pst.Str(String(pst#NL, "adc channel 3= "))
     pst.dec(adc.in(3))
     pst.Str(String(pst#NL, "adc channel 4= "))
     pst.dec(adc.in(4))
     pst.Str(String(pst#NL, "adc channel 5= "))
     pst.dec(adc.in(5))
     pst.Str(String(pst#NL, "adc channel 6= "))
     pst.dec(adc.in(6))
     pst.Str(String(pst#NL, "adc channel 7= "))
     pst.dec(adc.in(7))
     waitcnt(clkfreq/10 + cnt)        '10Hz screen refresh

  
{PUB Pg_120
  pst.start(115200)
  cognew(Display, @stack2)
  DIRA[0..7]~                 ''''''''''''???????????????
  DIRA[chipSel]~~
  DIRA[chipDIO]~~             ''''''''''''Remember to later make this an input
  DIRA[chipClk]~~ 
  repeat
    DataRead:=0
    outa[chipSel]~~
    outa[chipSel]~

    outa[chipClk]~
    outa[ChipDIO]~~
    outa[chipClk]~~

    outa[chipClk]~
    outa[ChipDIO]~~
    outa[chipClk]~~

    outa[chipClk]~
    outa[ChipDIO]~
    outa[chipClk]~~
    
    outa[chipClk]~
    outa[ChipDIO]~~
    outa[chipClk]~~

    outa[chipClk]~
    outa[ChipDIO]~
    outa[chipClk]~~

    repeat BitsRead
      DataRead <<= 1

      outa[chipClk]~
      DataRead:=DataRead+ina[chipDIO]      ''''''''Need to make an input before this
      outa[chipClk]~~
    outa[chipSel]~~
    SensorReading:=DataRead
      

PRI Display
    


    }