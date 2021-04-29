@echo off
if defined CONDA_BUILD_STATE (
    @echo on

    :: We should ensure the pre-installed MS-MPI v7 is erased
    :: so that downstream packages do not need to worry about
    :: how to run MPI tests.
    if not "%PKG_NAME%"=="msmpi" (
      echo "remove MPI from the image..."
      wmic product where name="Microsoft MPI (7.1.12437.25)" call uninstall || exit 1
      del /f /q "C:\Windows\System32\msmpi.dll" || exit 1
      del /f /q "C:\Windows\System32\msmpires.dll" || exit 1
    )
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
