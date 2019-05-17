@echo off
2600bas.exe<%1>%1.obj
copy /y /a 2600basic.asm +%1.obj +2600basicfooter.asm %1.asm>nul
dasm %1.asm -f3 -o%1.bin
pause
