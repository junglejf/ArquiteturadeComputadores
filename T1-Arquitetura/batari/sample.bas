1 rem smartbranching on
10 x = 50 : y = 50 : w = 40 : v = 40
20 COLUPF = 90
30 COLUP0 = 120 : player0x = x : player0y = y
40 scorecolor = 10
45 player0:
 %01000010
 %11111111
 %11111111
 %01111110
 %00111100
 %00011000
 %00011000
 %00011000
end
46 player1:
 %00111100
 %00011000
 %00011000
 %00011000
 %11100111
 %10100101
 %10011001
 %00100100
end
47 a = a + 1 : if a < 3 then 59
49 a = 0
50 if v < y then v = v + 1
51 if v > y then v = v - 1
52 if w < x then w = w + 1
53 if w > x then w = w - 1
54 player1x = w : player1y = v
59 drawscreen
60 if joy0up then y = y - 1
80 if joy0down then y = y + 1
100 if joy0left then x = x - 1
120 if joy0right then x = x + 1
140 goto 30
