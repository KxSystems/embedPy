set QHOME=%PREFIX%\q
mkdir %QHOME%
move p.q %QHOME% || goto :error
move p.k %QHOME% || goto :error

set QBIN=%QHOME%\w64
mkdir QBIN
cl /LD /DKXVER=3 /Fep.dll /O2 py.c q.lib || goto :error
move p.dll %QBIN% || goto :error
exit 0
:error
exit %errorlevel%

