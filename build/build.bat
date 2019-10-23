:: Standalone build
curl -fsSL -o k.h https://github.com/KxSystems/kdb/raw/master/c/c/k.h     || goto :error
curl -fsSL -o q.lib https://github.com/KxSystems/kdb/raw/master/w64/q.lib || goto :error
::keep original PATH, PATH may get too long otherwise
set OP=%PATH%
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
mkdir w64
cl /LD /DKXVER=3 /Fep.dll /O2 py.c q.lib                                  || goto :error
move p.dll w64
set PATH=%OP%

:: Conda build
set PATH=C:\Miniconda3-x64;C:\Miniconda3-x64\Scripts;%PATH%
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86_amd64
:: install conda build requirements (use version < 3.12 to avoid warning about verify in output file)
conda install -y "conda-build<3.12"                                       || goto :error
conda install -y anaconda-client conda=4.7.1                              || goto :error
:: set up kdb+ if available
if defined QLIC_KC ( echo|set /P=%QLIC_KC% > kc.lic.enc & certutil -decode kc.lic.enc kc.lic & set QLIC=%CD%)
if "%APPVEYOR_REPO_TAG%"=="true" ( set EMBEDPY_VERSION=%APPVEYOR_REPO_TAG_NAME% )
conda build --output conda-recipe > packagenames.txt                      || goto :error
conda build -c kx conda-recipe                                            || goto :error
set PATH=%OP%;C:\Miniconda3-x64;C:\Miniconda3-x64\Scripts
exit /b 0

:error
exit /b %errorLevel%
