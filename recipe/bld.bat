setlocal EnableDelayedExpansion

if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN% || exit 1
if not exist %LIBRARY_LIB% mkdir %LIBRARY_LIB% || exit 1
if not exist %LIBRARY_INC% mkdir %LIBRARY_INC% || exit 1

:: Even if we do this it still doesn't help to fix the PMP version mismatch error
:: (https://github.com/conda-forge/msmpi-feedstock/issues/2). But, this will make
:: -installroot work later!
:: echo "check installed programs..."
:: wmic product get name  || exit 1
echo "remove MPI from the image..."
wmic product where name="Microsoft MPI (7.1.12437.25)" call uninstall || exit 1

echo "check pwd..."
dir /s /b

mkdir temp
mkdir License
mkdir Tests
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

echo "Installing MS-MPI Runtime..."
:: We must run (not extract!) the installer to generate the correct dlls (yes, it would write to the dlls!)
"%cd%\msmpisetup.exe" -unattend -force -full -installroot "%PREFIX%\Library" -verbose -log "%cd%\log.txt" || exit 1
echo "printing log..."
type "%cd%\log.txt" || exit 1
del log.txt || exit 1

move "C:\Windows\System32\msmpi.dll" %LIBRARY_BIN% || exit 1
move "C:\Windows\System32\msmpires.dll" %LIBRARY_BIN% || exit 1
move "%PREFIX%\Library\Benchmarks\*" "%cd%\Tests" || exit 1
rmdir "%PREFIX%\Library\Benchmarks" || exit 1
move "%PREFIX%\Library\License\*" "%cd%\License" || exit 1
rmdir "%PREFIX%\Library\License" || exit 1

:: note: conda-build would copy the two folders below for us
echo "checking License..."
dir /s /b "%cd%\License"
echo "checking Tests..."
copy "%RECIPE_DIR%\tests\*" .\Tests || exit 1
dir /s /b "%cd%\Tests"

echo "copy the [de]activate scripts..."
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat || exit 1
)

echo "patching mpi.h..."
:: add --binary to handle the CRLF line ending
patch --binary "%LIBRARY_INC%\mpi.h" "%RECIPE_DIR%\MSMPI_VER.diff" || exit 1

echo "checking source dir..."
dir /s /b
echo "DONE!"
