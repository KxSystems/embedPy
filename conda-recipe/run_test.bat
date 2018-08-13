if not defined QLIC (
 goto :nokdb
)
conda install -y -q --file tests\requirements.txt
q test.q -q || goto :error
exit /b 0

:error
exit /b %errorLevel%

:nokdb
echo no kdb
exit /b 0
