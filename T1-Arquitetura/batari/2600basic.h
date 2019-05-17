 processor 6502
 include "vcs.h"
 include "macro.h"
 include "2600basic_variable_redefs.h"

player0x = $80
player1x = $81
missile0x = $82
missile1x = $83
ballx = $84

objecty = $85
player0y = $85
player1y = $86
missile0y = $87
missile1y = $88
bally = $89

player0pointer = $8A ;uses $8A-$8B
player1pointer = $8C ; $8C-$8D

player0height = $8E
player1height = $8F
missile0height = $90
missile1height = $91
ballheight = $92

score = $93 ; $93-$95
scorepointers = $96 ; $96-$A1 = 12 bytes
rand = $A2
scorecolor = $A3

playfield = $A4 ; $A4-$D3 = 48 bytes
temp1 = $D4 ;used by kernel.  can be used in program too, but
temp2 = $D5 ;are obliterated when drawscreen is called.
temp3 = $D6
temp4 = $D7
temp5 = $D8
temp6 = $D9

;$DA is unused

playfieldpos = $DB

A = $dc
a = $dc
B = $dd
b = $dd
C = $de
c = $de
D = $df
d = $df
E = $e0
e = $e0
F = $e1
f = $e1
G = $e2
g = $e2
H = $e3
h = $e3
I = $e4
i = $e4
J = $e5
j = $e5
K = $e6
k = $e6
L = $e7
l = $e7
M = $e8
m = $e8
N = $e9
n = $e9
O = $ea
o = $ea
P = $eb
p = $eb
Q = $ec
q = $ec
R = $ed
r = $ed
S = $ee
s = $ee
T = $ef
t = $ef
U = $f0
u = $f0
V = $f1
v = $f1
W = $f2
w = $f2
X = $f3
x = $f3
Y = $f4
y = $f4
Z = $f5
z = $f5


; stack = F6-F7, F8-F9, FA-FB, FC-FD, FE-FF
