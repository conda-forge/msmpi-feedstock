setlocal EnableDelayedExpansion

if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN% || exit 1
if not exist %LIBRARY_LIB% mkdir %LIBRARY_LIB% || exit 1
if not exist %LIBRARY_INC% mkdir %LIBRARY_INC% || exit 1

dir "C:\Program Files\Microsoft MPI\" || exit 1

echo "check registry..."
REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MPI" || exit 1

:: Even if we do this it still doesn't help to fix the PMP version mismatch error
:: (https://github.com/conda-forge/msmpi-feedstock/issues/2), so we rely on the
:: installer to force updating it for testing...
:: echo "check installed programs..."
:: wmic product get name  || exit 1
:: echo "remove MPI from the image..."
:: wmic product where name="Microsoft MPI (7.1.12437.25)" call uninstall || exit 1

echo "edit registry..."
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MPI" /t REG_SZ /v Version /d 10.1.2 /f || exit 1
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MPI" /t REG_SZ /v InstallRoot /d "%PREFIX%\Library" /f || exit 1
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MPI" /t REG_SZ /v MSPMSProvider /d "%LIBRARY_BIN%\msmpi.dll" /f || exit 1
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MPI" /v RedistPath /f || exit 1

echo "check registry..."
:: REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\HPC" || exit 1
:: REG QUERY "HKEY_CURRENT_USER\Software\Microsoft\MPI" || exit 1
REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MPI" || exit 1
:: echo "hunt down smpd..."
:: tasklist /v  
:: del /f /q C:\Windows\System32\msmpi.dll || exit 1
:: del /f /q C:\Windows\System32\msmpires.dll || exit 1
:: where msmpi.dll
:: where msmpires.dll
:: exit 1

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
:: "%cd%\msmpisetup.exe" -unattend -force -full -installroot "%cd%\temp" -verbose -log "%cd%\log.txt" || exit 1
:: echo "printing log..."
:: type "%cd%\log.txt" || exit 1
:: del log.txt || exit 1
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
copy "%RECIPE_DIR%\tests\*" .\Tests || exit 1

echo "checking source dir..."
dir /s /b
echo "DONE!"
