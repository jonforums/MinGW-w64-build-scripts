#!/usr/bin/env bash
set -e

if [ -f configure.marker ]
then
    echo "--> Already configured"
else
    echo "--> Configuring"
    sh $SRC_DIR/ppl-$PPL_VERSION/configure --host=$HOST --build=$BUILD --prefix=$PREREQ_INSTALL \
                                           --disable-shared --enable-static \
                                           --disable-watchdog --disable-ppl_lcdd --disable-ppl_lpsol --disable-ppl_pips \
                                           CPPFLAGS="$HOST_CPPFLAGS -I$PREREQ_INSTALL/include" LDFLAGS="$HOST_LDFLAGS -L$PREREQ_INSTALL/lib" \
                                           > $LOG_DIR/ppl_configure.log 2>&1 || exit 1
    echo "--> Configured"
fi
touch configure.marker

if [ -f build.marker ]
then
    echo "--> Already built"
else
    echo "--> Building"
    make $MAKE_OPTS > $LOG_DIR/ppl_build.log 2>&1 || exit 1
fi
touch build.marker

if [ -f install.marker ]
then
    echo "--> Already installed"
else
    echo "--> Installing"
    make $MAKE_OPTS install > $LOG_DIR/ppl_install.log 2>&1 || exit 1
fi
touch install.marker