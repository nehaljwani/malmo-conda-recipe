#!/bin/bash

set -euxo pipefail

cp ${RECIPE_DIR}/extra_files/xs3p.xsl ${SRC_DIR}/Schemas/
cp -r ${SRC_DIR}/Schemas/ ${PREFIX}/Schemas/

cp ${RECIPE_DIR}/extra_files/FindBoost.cmake ${SRC_DIR}/cmake/

export MALMO_XSD_PATH=${PREFIX}/Schemas/

echo "XSD_PATH = ${MALMO_XSD_PATH}"
export TERM=${TERM:-dumb} #Dummy $TERM variable to make gradle happy

cd ${SRC_DIR}
mkdir -p build
cd build

cmake \
  -DBUILD_MOD=On \
  -DSTATIC_BOOST=On \
  -DINCLUDE_JAVA=OFF \
  -DINCLUDE_CSHARP=Off \
  -DBUILD_DOCUMENTATION=Off \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DBOOST_PYTHON_NAME=python${CONDA_PY} \
  -DCMAKE_INSTALL_RPATH="$PREFIX/lib:$SP_DIR" \
  ../

make VERBOSE=1
make install

# Copy over Minecraft to env root
cp -r ${SRC_DIR}/build/install/Minecraft ${PREFIX}/Minecraft
# Copy over Schemas Directory to env root
cp -r ${SRC_DIR}/build/install/Schemas ${PREFIX}/MalmoSchemas

# Install the python package
cd $SRC_DIR/scripts/python-wheel/package/
cp $SRC_DIR/build/install/Python_Examples/MalmoPython.so malmo
cp $SRC_DIR/build/install/Python_Examples/malmoutils.py malmo
cp $SRC_DIR/build/install/Python_Examples/run_mission.py malmo
cp $SRC_DIR/Minecraft/launch_minecraft_in_background.py malmo
python setup.py install --single-version-externally-managed --record record.txt
ln -s $SP_DIR/malmo/MalmoPython.so $SP_DIR/MalmoPython.so

# Copy Over env vars setup scripts
mkdir -p ${PREFIX}/etc/conda/activate.d
mkdir -p ${PREFIX}/etc/conda/deactivate.d
cp ${RECIPE_DIR}/extra_files/env_setup/env_activate.sh ${PREFIX}/etc/conda/activate.d/malmo.sh
cp ${RECIPE_DIR}/extra_files/env_setup/env_deactivate.sh ${PREFIX}/etc/conda/deactivate.d/malmo.sh
# This sets the MALMO_XSD_PATH path variable and any other required variables
