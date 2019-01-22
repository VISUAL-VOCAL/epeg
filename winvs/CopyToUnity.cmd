@echo off
setlocal

set UNITY_LIBEPEG_DIR=%1

if not exist %UNITY_LIBEPEG_DIR% (
    echo Unity libepeg folder not found.
    goto done
)

if not exist %UNITY_LIBEPEG_DIR%\Windows\Desktop32\Debug mkdir %UNITY_LIBEPEG_DIR%\Windows\Desktop32\Debug
if not exist %UNITY_LIBEPEG_DIR%\Windows\Desktop32\Release mkdir %UNITY_LIBEPEG_DIR%\Windows\Desktop32\Release
if not exist %UNITY_LIBEPEG_DIR%\Windows\Desktop64\Debug mkdir %UNITY_LIBEPEG_DIR%\Windows\Desktop64\Debug
if not exist %UNITY_LIBEPEG_DIR%\Windows\Desktop64\Release mkdir %UNITY_LIBEPEG_DIR%\Windows\Desktop64\Release
if not exist %UNITY_LIBEPEG_DIR%\Windows\UWP32\Debug mkdir %UNITY_LIBEPEG_DIR%\Windows\UWP32\Debug
if not exist %UNITY_LIBEPEG_DIR%\Windows\UWP32\Release mkdir %UNITY_LIBEPEG_DIR%\Windows\UWP32\Release
if not exist %UNITY_LIBEPEG_DIR%\Windows\UWP64\Debug mkdir %UNITY_LIBEPEG_DIR%\Windows\UWP64\Debug
if not exist %UNITY_LIBEPEG_DIR%\Windows\UWP64\Release mkdir %UNITY_LIBEPEG_DIR%\Windows\UWP64\Release

copy ..\build\Windows\Desktop32\Debug\lib\libepegd.dll %UNITY_LIBEPEG_DIR%\Windows\Desktop32\Debug
copy ..\build\Windows\Desktop32\Debug\lib\libepegd.pdb %UNITY_LIBEPEG_DIR%\Windows\Desktop32\Debug

copy ..\build\Windows\Desktop32\Release\lib\libepeg.dll %UNITY_LIBEPEG_DIR%\Windows\Desktop32\Release
copy ..\build\Windows\Desktop32\Release\lib\libepeg.pdb %UNITY_LIBEPEG_DIR%\Windows\Desktop32\Release

copy ..\build\Windows\Desktop64\Debug\lib\libepegd.dll %UNITY_LIBEPEG_DIR%\Windows\Desktop64\Debug
copy ..\build\Windows\Desktop64\Debug\lib\libepegd.pdb %UNITY_LIBEPEG_DIR%\Windows\Desktop64\Debug

copy ..\build\Windows\Desktop64\Release\lib\libepeg.dll %UNITY_LIBEPEG_DIR%\Windows\Desktop64\Release
copy ..\build\Windows\Desktop64\Release\lib\libepeg.pdb %UNITY_LIBEPEG_DIR%\Windows\Desktop64\Release

copy ..\build\Windows\UWP32\Debug\lib\libepegd.dll %UNITY_LIBEPEG_DIR%\Windows\UWP32\Debug
copy ..\build\Windows\UWP32\Debug\lib\libepegd.pdb %UNITY_LIBEPEG_DIR%\Windows\UWP32\Debug

copy ..\build\Windows\UWP32\Release\lib\libepeg.dll %UNITY_LIBEPEG_DIR%\Windows\UWP32\Release
copy ..\build\Windows\UWP32\Release\lib\libepeg.pdb %UNITY_LIBEPEG_DIR%\Windows\UWP32\Release

copy ..\build\Windows\UWP64\Debug\lib\libepegd.dll %UNITY_LIBEPEG_DIR%\Windows\UWP64\Debug
copy ..\build\Windows\UWP64\Debug\lib\libepegd.pdb %UNITY_LIBEPEG_DIR%\Windows\UWP64\Debug

copy ..\build\Windows\UWP64\Release\lib\libepeg.dll %UNITY_LIBEPEG_DIR%\Windows\UWP64\Release
copy ..\build\Windows\UWP64\Release\lib\libepeg.pdb %UNITY_LIBEPEG_DIR%\Windows\UWP64\Release

:done
endlocal


