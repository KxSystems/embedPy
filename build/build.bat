:: Standalone build
curl -fsSL -o k.h https://github.com/KxSystems/kdb/raw/master/c/c/k.h     || goto :error
curl -fsSL -o q.lib https://github.com/KxSystems/kdb/raw/master/w64/q.lib || goto :error

::keep original PATH, PATH may get too long otherwise
set OP=%PATH%
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"

if "%APPVEYOR_REPO_TAG%"=="true" (
 set EMBEDPY_VERSION=%APPVEYOR_REPO_TAG_NAME%
) else (
 set EMBEDPY_VERSION=%APPVEYOR_REPO_BRANCH%_%APPVEYOR_REPO_COMMIT%
)
set PATH=C:\Perl;%PATH%
perl -p -i.bak -e s/EMBEDPYVERSION/`\$\"%EMBEDPY_VERSION%\"/g p.q

mkdir w64
cl /LD /DKXVER=3 /Fep.dll /O2 py.c q.lib                                  || goto :error
move p.dll w64
set PATH=%OP%
:: Conda build
set PATH=C:\Miniconda3-x64;C:\Miniconda3-x64\Scripts;%PATH%
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86_amd64
conda install -y "conda-build"                                       || goto :error
conda install -y anaconda-client conda                               || goto :error
:: set up kdb+ if available
if defined QLIC_KC ( echo|set /P=%QLIC_KC% > kc.lic.enc & certutil -decode kc.lic.enc kc.lic & set QLIC=%CD%)
if "%APPVEYOR_REPO_TAG%"=="true" ( set EMBEDPY_VERSION=%APPVEYOR_REPO_TAG_NAME% )
conda build --output conda-recipe > packagenames.txt                      || goto :error
conda build -c kx conda-recipe                                            || goto :error
set PATH=%OP%;C:\Miniconda3-x64;C:\Miniconda3-x64\Scripts
exit /b 0
:error
exit /b %errorLevel%
