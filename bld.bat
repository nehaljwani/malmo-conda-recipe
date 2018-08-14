@echo On

xcopy %RECIPE_DIR%\extra_files\xs3p.xsl %SRC_DIR%\Schemas
xcopy /s /y /i %SRC_DIR%\Schemas %PREFIX%\Schemas

set "MALMO_XSD_PATH=%PREFIX%\Schemas\"

cd %SRC_DIR%
mkdir build
cd build

cmake -G"%CMAKE_GENERATOR%" ^
  -DBUILD_MOD=On ^
  -DSTATIC_BOOST=On ^
  -DINCLUDE_JAVA=OFF ^
  -DINCLUDE_CSHARP=Off ^
  -DBUILD_DOCUMENTATION=Off ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DBOOST_PYTHON_NAME=python%CONDA_PY% ^
  ..

cmake --build . --target INSTALL -- /p:Configuration=Release

REM Copy over Minecraft to env root
xcopy /s /y /i %SRC_DIR%\build\install\Minecraft %PREFIX%\Minecraft
REM Copy over Schemas Directory to env root
xcopy /s /y /i %SRC_DIR%\build\install\Schemas %PREFIX%\MalmoSchemas

REM Install the python package
cd %SRC_DIR%\scripts\python-wheel\package\
xcopy %SRC_DIR%\build\install\Python_Examples\MalmoPython.lib malmo
xcopy %SRC_DIR%\build\install\Python_Examples\MalmoPython.pyd malmo
xcopy %SRC_DIR%\build\install\Python_Examples\malmoutils.py malmo
xcopy %SRC_DIR%\build\install\Python_Examples\run_mission.py malmo
xcopy %SRC_DIR%\Minecraft\launch_minecraft_in_background.py malmo
python setup.py install --single-version-externally-managed --record record.txt

REM Copy Over env vars setup scripts
mkdir %PREFIX%\etc\conda\activate.d
mkdir %PREFIX%\etc\conda\deactivate.d
copy %RECIPE_DIR%\extra_files\env_setup\env_activate.bat %PREFIX%\etc\conda\activate.d\malmo.bat
copy %RECIPE_DIR%\extra_files\env_setup\env_deactivate.bat %PREFIX%\etc\conda\deactivate.d\malmo.bat
REM This sets the MALMO_XSD_PATH path variable and any other required variables
