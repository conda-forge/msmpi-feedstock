if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN% || exit 1
if not exist %LIBRARY_LIB% mkdir %LIBRARY_LIB% || exit 1
if not exist %LIBRARY_INC% mkdir %LIBRARY_INC% || exit 1

:: echo "check x64..."
:: dir /s /b "C:\Program Files\Microsoft MPI"
:: echo "check x86..."
:: dir /s /b "C:\Program Files (x86)\Microsoft SDKs\MPI\"

echo "check pwd..."
dir /s /b

mkdir temp
mkdir License
echo "Installing MS-MPI SDK..." 
msiexec.exe /quiet /qn /a "%cd%\msmpisdk.msi" TARGETDIR="%cd%\temp" || exit 1

echo "moving files..."
move "%cd%\temp\PFiles\Microsoft SDKs\MPI\Lib\*.lib" %LIBRARY_LIB% || exit 1
echo "moving files..."
move "%cd%\temp\PFiles\Microsoft SDKs\MPI\Include\*.h" %LIBRARY_INC% || exit 1
echo "moving files..."
move "%cd%\temp\PFiles\Microsoft SDKs\MPI\Include\*.f90" %LIBRARY_INC% || exit 1
echo "making new folder..."
mkdir %LIBRARY_INC%\x64 || exit 1
echo "moving files..."
move "%cd%\temp\PFiles\Microsoft SDKs\MPI\Include\x64\*.h" %LIBRARY_INC%\x64 || exit 1
echo "moving files..."
move "%cd%\temp\PFiles\Microsoft SDKs\MPI\License\*" "%cd%\License" || exit 1

echo "check pwd..."
dir /s /b
echo "check target dir..."
dir /s /b "%cd%\temp"
rmdir /q /s temp || exit 1

:: echo "check x64..."
:: dir /s /b "C:\Program Files\Microsoft MPI"
:: echo "check x86..."
:: dir /s /b "C:\Program Files (x86)\Microsoft SDKs\MPI\"

mkdir temp
mkdir test
echo "Installing MS-MPI Runtime..."
:: this does not work because it keeps installing to C:\Program Files\Microsoft MPI\ ...
:: "%cd%\msmpisetup.exe" -unattend -force -full -installroot "%cd%\temp" -verbose -log "%cd%\log.txt" || exit 1
:: echo "printing log..."
:: type "%cd%\log.txt"
7z x msmpisetup.exe -o"%cd%\temp" || exit 1

move "%cd%\temp\*.dll" %LIBRARY_BIN% || exit 1
move "%cd%\temp\mpiexec.exe" %LIBRARY_BIN% || exit 1
move "%cd%\temp\mpitrace.man" %LIBRARY_BIN% || exit 1
move "%cd%\temp\msmpilaunchsvc.exe" %LIBRARY_BIN% || exit 1
move "%cd%\temp\smpd.exe" %LIBRARY_BIN% || exit 1
move "%cd%\temp\*.exe" "%cd%\test" || exit 1
move "%cd%\temp\*" "%cd%\License" || exit 1

echo "checking installroot..."
dir /s /b "%cd%\temp"
rmdir "%cd%\temp" || exit 1
echo "checking License..."
dir /s /b "%cd%\License"
echo "checking test..."
dir /s /b "%cd%\test"

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

echo "copy the [de]activate scripts..."
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
)

dir /s /b
