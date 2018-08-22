set ZIPNAME=
if "%APPVEYOR_REPO_TAG%"=="true" (
 set ZIPNAME=embedPy_windows-%APPVEYOR_REPO_TAG_NAME%.zip
) else (
 set ZIPNAME=embedPy_windows-%APPVEYOR_REPO_BRANCH%-%APPVEYOR_BUILD_VERSION%.zip
)
7z a %ZIPNAME% p.q p.k test.q tests w64/p.dll LICENSE README.md || goto :error
appveyor PushArtifact %ZIPNAME%                                 || goto :error
exit /b 0
:error
exit /b %errorLevel%
