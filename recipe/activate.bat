if defined CONDA_BUILD_STATE (
    @echo on
)

:: Backup environment variables (only if the variables are set)
if defined MSMPI_BIN (
    set "MSMPI_BIN_CONDA_BACKUP=%MSMPI_BIN%"
)
if defined MSMPI_INC (
    set "MSMPI_INC_CONDA_BACKUP=%MSMPI_INC%"
)
if defined MSMPI_LIB64 (
    set "MSMPI_LIB64_CONDA_BACKUP=%MSMPI_LIB64%"
)
if defined MSMPI_LIB32 (
    set "MSMPI_LIB32_CONDA_BACKUP=%MSMPI_LIB32%"
)

set MSMPI_BIN=%LIBRARY_BIN%
set MSMPI_INC=%LIBRARY_INC%
set MSMPI_LIB64=%LIBRARY_LIB%
set MSMPI_LIB32=""

:: echo "check registry..."
:: REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MPI" || exit 1

echo "edit registry..."
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MPI" /t REG_SZ /v Version /d 10.1.2 /f || exit 1
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MPI" /t REG_SZ /v InstallRoot /d "%PREFIX%\Library" /f || exit 1
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MPI" /t REG_SZ /v MSPMSProvider /d "%PREFIX%\Library\bin\msmpi.dll" /f || exit 1

echo "check registry..."
REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MPI" || exit 1
