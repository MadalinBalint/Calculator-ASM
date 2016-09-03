tasm.exe /la /r /q io.asm
tasm.exe /la /r /q string.asm
tasm.exe /la /r /q %1.asm

tlink.exe /3 %1.obj io.obj string.obj
%1