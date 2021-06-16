if defined CONDA_BUILD_STATE (
    @echo on
)

if exist "C:\Windows\System32\msmpi.dll" (
    echo "You seem to have a system wide installation of MSMPI. "
    echo "Due to the way DLL loading works on windows, system wide installation "
    echo "will probably overshadow the conda installation. Uninstalling "
    echo "the system wide installation and forced deleting C:\Windows\System32\msmpi*.dll"
    echo "will help, but may break other software using the system wide installation."
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

set MSMPI_BIN=%PREFIX%\Library\bin
set MSMPI_INC=%PREFIX%\Library\include
set MSMPI_LIB64=%PREFIX%\Library\lib
set MSMPI_LIB32=""
