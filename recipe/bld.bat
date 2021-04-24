if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN% || exit 1
if not exist %LIBRARY_LIB% mkdir %LIBRARY_LIB% || exit 1
if not exist %LIBRARY_INC% mkdir %LIBRARY_INC% || exit 1

echo "check x64..."
dir /s /b "C:\Program Files\Microsoft MPI"
echo "check x86..."
dir /s /b "C:\Program Files (x86)\Microsoft SDKs\MPI\"

mkdir yyyyy
dir /s /b "%cd%\yyyyy"
echo "Installing MS-MPI SDK..." 
msiexec.exe /quiet /qn /a "%cd%\msmpisdk.msi" TARGETDIR="%cd%\yyyyy" || exit 1

echo "check pwd..."
dir /s /b
echo "check target dir..."
dir /s /b "%cd%\yyyyy"

echo "check x64..."
dir /s /b "C:\Program Files\Microsoft MPI"
echo "check x86..."
dir /s /b "C:\Program Files (x86)\Microsoft SDKs\MPI\"

mkdir xxxxx
echo "Installing MS-MPI Runtime..."
:: msmpisetup.exe /s /x /b"%cd%\xxxxx" /v"/qn" || exit 1
:: msmpisetup.exe -unattend -force
"%cd%\msmpisetup.exe" -unattend -force -full -installroot "%cd%\xxxxx" -verbose -log "%cd%\log.txt" || exit 1
echo "printing log..."
type "%cd%\log.txt"

echo "checking installroot..."
dir /s /b "%cd%\xxxxx"

echo "DONE!"
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
