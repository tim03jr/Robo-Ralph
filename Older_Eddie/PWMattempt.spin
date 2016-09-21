''This is an attempt to ramp the motors up and down using the counter modules.
''As of now, the motors skip. Maybe it would be better to send a pwm signal to the pwm pins rather than try to use duty cycle.



scale= 16_777_216


Pub MotorDuty  | duty

ctra[30..26] := %00110
ctrb[30..26] := %00110

ctra[5..0] := 20
ctrb[5..0] := 23

frqa := duty * scale
frqb := duty * scale

dira [19..24]~~ 
repeat  
  repeat duty from 0 to 255
       
         outa [21]~~      ''LForward
         outa [24]~~      ''RForward
   frqa := duty * scale
   frqb := duty * scale 
   waitcnt(clkfreq/128 + cnt)

   repeat duty from 255 to 0
       
         outa [21]~~      ''LForward
         outa [24]~~      ''RForward
   frqa := duty * scale
   frqb := duty * scale 
   waitcnt(clkfreq/128 + cnt)



 
 {{ outa [19..24]~ 
  waitcnt(clkfreq + cnt)
   
  repeat duty from 255 to 0
         outa [21]~      ''LForward
         outa [24]~      ''RForward
         outa [19]~~      ''LReverse
         outa [22]~~      ''RReverse
   frqa := duty * scale
   frqb := duty * scale 
   waitcnt(clkfreq/64 + cnt)
   }}