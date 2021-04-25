setlocal EnableDelayedExpansion

if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN% || exit 1
if not exist %LIBRARY_LIB% mkdir %LIBRARY_LIB% || exit 1
if not exist %LIBRARY_INC% mkdir %LIBRARY_INC% || exit 1

:: This takes too long, let's worry about it later
:: echo "check existing mpi.h..."
:: where /r c:\ mpi.h
:: 
:: echo "check existing msmpi.dll..."
:: where /r c:\ msmpi.dll

echo "check pwd..."
dir /s /b

mkdir temp
mkdir License
echo "Installing MS-MPI SDK..."
:: note: it has to be /a, not /i
msiexec.exe /quiet /qn /a "%cd%\msmpisdk.msi" TARGETDIR="%cd%\temp" || exit 1

move "%cd%\temp\PFiles\Microsoft SDKs\MPI\Lib\x64\*.lib" %LIBRARY_LIB% || exit 1
move "%cd%\temp\PFiles\Microsoft SDKs\MPI\Include\*.h" %LIBRARY_INC% || exit 1
move "%cd%\temp\PFiles\Microsoft SDKs\MPI\Include\*.f90" %LIBRARY_INC% || exit 1
move "%cd%\temp\PFiles\Microsoft SDKs\MPI\Include\x64\*.h" %LIBRARY_INC% || exit 1
move "%cd%\temp\PFiles\Microsoft SDKs\MPI\License\*" "%cd%\License" || exit 1

echo "check pwd..."
dir /s /b
echo "check target dir..."
dir /s /b "%cd%\temp"
rmdir /q /s temp || exit 1

mkdir temp
mkdir Tests
echo "Installing MS-MPI Runtime..."
:: this does not work because it insists on installing to C:\Program Files\Microsoft MPI\, not to our custom path;
:: however, we still need this to overwrite the vm image's built-in installation so that we can run tests
"%cd%\msmpisetup.exe" -unattend -force -full -installroot "%cd%\temp" -verbose -log "%cd%\log.txt" || exit 1
echo "printing log..."
type "%cd%\log.txt" || exit 1
:: this extraction does the real work for the purpose of packaging
7z x msmpisetup.exe -o"%cd%\temp" || exit 1

move "%cd%\temp\*.dll" %LIBRARY_BIN% || exit 1
move "%cd%\temp\mpiexec.exe" %LIBRARY_BIN% || exit 1
move "%cd%\temp\mpitrace.man" %LIBRARY_BIN% || exit 1
move "%cd%\temp\msmpilaunchsvc.exe" %LIBRARY_BIN% || exit 1
move "%cd%\temp\smpd.exe" %LIBRARY_BIN% || exit 1
move "%cd%\temp\*.exe" "%cd%\Tests" || exit 1
move "%cd%\temp\*" "%cd%\License" || exit 1

echo "checking installroot..."
dir /s /b "%cd%\temp"
rmdir "%cd%\temp" || exit 1
:: note: conda-build would copy the two folders below for us
echo "checking License..."
dir /s /b "%cd%\License"
echo "checking Tests..."
dir /s /b "%cd%\Tests"

echo "copy the [de]activate scripts..."
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat || exit 1
)

echo "patching mpi.h..."
patch "%LIBRARY_INC%\mpi.h" "%RECIPE_DIR%\MSMPI_VER.diff" || exit 1
copy "%RECIPE_DIR%\get_mpi_ver.c" . || exit 1

echo "checking source dir..."
dir /s /b
echo "DONE!"
