if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN% || exit 1
if not exist %LIBRARY_LIB% mkdir %LIBRARY_LIB% || exit 1
if not exist %LIBRARY_INC% mkdir %LIBRARY_INC% || exit 1

start "Install MS-MPI SDK" /wait msiexec.exe /quiet /qn /i msmpisdk.msi || exit 1

dir /s /b

mkdir xxxxx
start "Install MS-MPI Runtime" /wait msmpisetup.exe -unattend -installroot %cd%\xxxxx -verbose

dir /s /b xxxxx

exit 1
:: if "%ARCH%"=="32" (
::     set PLATFORM=Win32
:: ) else (
::     set PLATFORM=x64
:: )
:: 
:: msbuild.exe /p:Platform=%PLATFORM% /p:Configuration=Release
:: 
:: for /r %SRC_DIR%\out\Release-%PLATFORM% %%f in (*.exe) do @copy "%%f" %LIBRARY_BIN%
:: for /r %SRC_DIR%\out\Release-%PLATFORM% %%f in (*.dll) do @copy "%%f" %LIBRARY_BIN%
:: for /r %SRC_DIR%\out\Release-%PLATFORM% %%f in (*.lib) do @copy "%%f" %LIBRARY_LIB%
:: for /r %SRC_DIR%\out\Release-%PLATFORM% %%f in (*.f90) do @copy "%%f" %LIBRARY_INC%
:: for /r %SRC_DIR%\out\Release-%PLATFORM% %%f in (*.h) do @copy "%%f" %LIBRARY_INC%
:: 
:: rem ensure the correct header for the platform is added 
:: if "%ARCH%"=="32" (
::     copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\x86\mpifptr.h %LIBRARY_INC%\mpifptr.h
:: ) else (
::     copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\x64\mpifptr.h %LIBRARY_INC%\mpifptr.h
:: )
 
setlocal EnableDelayedExpansion

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
)

dir /s /b
