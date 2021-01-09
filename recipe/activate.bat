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

set MSMPI_BIN=%LIBRARY_BIN%
set MSMPI_INC=%LIBRARY_INC%
set MSMPI_LIB64=%LIBRARY_LIB%
