#!/usr/bin/env bash
set -e

# common settings
echo "Executing preliminary setup"
# build settings
. ./scripts/settings.sh || exit 1
# version info
echo "-> Loading version info"
. ./scripts/versions.sh || exit 1
# set up and create directories
echo "-> Setting up directories"
. ./scripts/directories.sh || exit 1

# Projects to be built, in the right order
PREGCC_STEPS="mingw-w64-headers
              binutils
              gmp mpfr mpc
              ppl cloog"
POSTGCC_STEPS="cleanup
               licenses
               zipping"
cd $BUILD_DIR
mkdir -p $PREGCC_STEPS
mkdir -p gcc
mkdir -p mingw-w64-crt
mkdir -p winpthreads32 winpthreads64
mkdir -p $POSTGCC_STEPS
cd $TOP_DIR

# prepare for GCC
for step in $PREGCC_STEPS
do
    echo "-> $step"
    cd $BUILD_DIR/$step
    . $SCRIPTS/$step.sh || exit 1
done
# point PATH to new tools
export PATH=$PREFIX/bin:$PATH
# build GCC C compiler
echo "-> GCC: C compiler"
cd $BUILD_DIR/gcc
. $SCRIPTS/gcc-c.sh || exit 1
# build mingw-w64 crt
echo "-> MinGW-w64 CRT"
cd $BUILD_DIR/mingw-w64-crt
. $SCRIPTS/mingw-w64-crt.sh || exit 1
# build winpthreads
echo "-> Winpthreads"
if [ "$TARGET_ARCH" == "x86_64" ]
then
  . $SCRIPTS/winpthreads64multi.sh || exit 1
else
  . $SCRIPTS/winpthreads32multi.sh || exit 1
fi
# build the rest of GCC
echo "-> GCC: Full compiler suite"
cd $BUILD_DIR/gcc
. $SCRIPTS/gcc.sh || exit 1
# build the rest
for step in $POSTGCC_STEPS
do
  echo "-> $step"
  cd $BUILD_DIR/$step
  . $SCRIPTS/$step.sh || exit 1
done
