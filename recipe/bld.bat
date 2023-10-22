if "%ARCH%"=="32" (
    set PLATFORM=Win32
) else (
    set PLATFORM=x64
)

msbuild.exe /p:Platform=%PLATFORM% /p:Configuration=Release
if errorlevel 1 exit 1

for /r %SRC_DIR%\out\Release-%PLATFORM% %%f in (*.exe) do @copy "%%f" %LIBRARY_BIN%
for /r %SRC_DIR%\out\Release-%PLATFORM% %%f in (*.dll) do @copy "%%f" %LIBRARY_BIN%
for /r %SRC_DIR%\out\Release-%PLATFORM% %%f in (*.lib) do @copy "%%f" %LIBRARY_LIB%
for /r %SRC_DIR%\out\Release-%PLATFORM% %%f in (*.f90) do @copy "%%f" %LIBRARY_INC%
for /r %SRC_DIR%\out\Release-%PLATFORM% %%f in (*.h) do @copy "%%f" %LIBRARY_INC%

rem ensure the correct header for the platform is added 
if "%ARCH%"=="32" (
    copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\x86\mpifptr.h %LIBRARY_INC%\mpifptr.h
) else (
    copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\x64\mpifptr.h %LIBRARY_INC%\mpifptr.h
)

echo "patching mpi.h..."
:: add --binary to handle the CRLF line ending
patch --binary "%LIBRARY_INC%\mpi.h" "%RECIPE_DIR%\MSMPI_VER.diff" || exit 1
if errorlevel 1 exit 1

echo "Building wrappers..."
mkdir build
mkdir build\bin
mkdir build\include
mkdir build\lib

cd build
copy %LIBRARY_INC%\mpi.h include\
copy %LIBRARY_INC%\mpif.h include\
copy %LIBRARY_INC%\mpi.f90 include\
copy %LIBRARY_INC%\mpifptr.h include\

dlltool -k -d %SRC_DIR%\src\msys2\msmpi.def -l lib\libmsmpi.dll.a
if errorlevel 1 exit 1

set mpic=%SRC_DIR%\src\msys2\mpi.c
set cflags=-s -O2 -DNDEBUG

gcc %cflags% -o bin\mpicc.exe -DCC %mpic%
if errorlevel 1 exit 1
gcc %cflags% -o bin\mpicxx.exe -DCXX %mpic%
if errorlevel 1 exit 1
copy bin\mpicxx.exe "bin\mpic++.exe"
gcc %cflags% -o bin\mpifort.exe -DFC %mpic%
if errorlevel 1 exit 1
copy bin\mpifort.exe bin\mpif77.exe
copy bin\mpifort.exe bin\mpif90.exe
bin\mpifort -c -Jinclude .\include\mpi.f90
if errorlevel 1 exit 1
del mpi.o
if errorlevel 1 exit 1

cd ..
xcopy /e/y build %LIBRARY_PREFIX%

setlocal EnableDelayedExpansion

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat || exit 1
)

dir /s /b
