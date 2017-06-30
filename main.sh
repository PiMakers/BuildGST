#!/bin/bash

set -e

#echo -ne "hello\n"

# For later use (Keep everything portable)
HOME_DIR=$PWD

SCRIPT_FOLDER=/mnt/LinuxData/Scripts
export CROSS_COMPILING=1

# Why not?
SAVED_PATH=$PATH

# Specify target HW (if Cross Complie)
HW_PLATFORM=Rpi1 # Rpi0 (armv6), Rpi1 (armv6), Rpi2 (armv7), Rpi3 (cortex A8), TODO: Generic & other Platforms
export HW_PLATFORM=$HW_PLATFORM

# set BRANCH to e.g. "1.2" to track the stable 1.2 branch instead of master
export BRANCH="master"

# set to "ssh" if you have a developer account and ssh access
GIT_ACCESS="anongit"

# extra clone options
#CLONE_OPTS="--depth=1 --no-single-branch"

# re-use and reference local master branch checkout if one already exists
# (saves network bandwidth)
REUSE_EXISTING_MASTER_CHECKOUT="tfalse"

# git modules to clone
MODULES="orc gstreamer gst-plugins-base gst-plugins-good gst-plugins-ugly gst-plugins-bad gst-libav"

# any (top_build_root)
UNINSTALLED_ROOT=/mnt/LinuxData/src/GST_uninstalled/$HW_PLATFORM

export GST_UNINSTALLED_ROOT=$UNINSTALLED_ROOT/$BRANCH
echo -ne "GST_UNINSTALLED_ROOT=$GST_UNINSTALLED_ROOT\n\n"


echo "==========================================================================================="
echo "Creating new GStreamer uninstalled environment for branch $BRANCH in $UNINSTALLED_ROOT ... "
echo -ne "===========================================================================================\n"

mkdir -p $UNINSTALLED_ROOT $UNINSTALLED_ROOT/$BRANCH $UNINSTALLED_ROOT/$BRANCH/prefix
#mkdir -p $UNINSTALLED_ROOT/$BRANCH
#mkdir -p $UNINSTALLED_ROOT/$BRANCH/prefix

echo -ne "\nChecking basic build tools and dependencies are installed...\n"

if ! pkg-config --version 2>/dev/null >/dev/null; then
  DEPS_OK="no"
elif ! pkg-config --exists glib-2.0 orc-0.4 2>/dev/null >/dev/null; then
  DEPS_OK="no"
elif ! bison --version 2>/dev/null >/dev/null; then
  DEPS_OK="no"
elif ! flex --version 2>/dev/null >/dev/null; then
  DEPS_OK="no"
elif ! git --version 2>/dev/null >/dev/null; then
  DEPS_OK="no"
else
  DEPS_OK="yes"
fi

if test "$DEPS_OK" != "yes"; then
echo -ne "===========================================================================================\n\n"
echo -ne "  Some very basic build tools or dependencies are missing.\n\n"
echo -ne "  Please install the following tools: pkg-config, bison, flex, git\n\n"
echo -ne "  and the following libraries: GLib (libglib2.0-dev or glib2-devel)"
echo -ne "                           and Orc  (liborc-0.4-dev or orc-devel)\n\n"
echo "==========================================================================================="
exit 1
fi

cd $UNINSTALLED_ROOT/$BRANCH

#DownLoad &/or Update Everything
for m in $MODULES
do
  REF=""
  if test "$BRANCH" != "master" \
    -a "x$REUSE_EXISTING_MASTER_CHECKOUT" = "xtrue" \
    -a -d ../master/$m; then
      REF="--reference=../master/$m"
  fi
	if [ ! -d "$m/.git" ]; then
	  if test "$GIT_ACCESS" = "ssh"; then
	    git clone $CLONE_OPTS $REF ssh://git.freedesktop.org/git/gstreamer/$m &
	  else
	    git clone $CLONE_OPTS $REF https://anongit.freedesktop.org/git/gstreamer/$m &
	  fi
    CURRENT_PID="$!"
	  PIDS="$PIDS $CURRENT_PID"
	fi
done

wait $PIDS

for m in $MODULES
do
  cd $m
  if test "$BRANCH" != "master"; then
    git checkout -b $BRANCH origin/$BRANCH
  fi
  git checkout -b $BRANCH origin/$BRANCH
  git submodule init && git submodule update &
  cd ..
  PIDS="$yPIDS $!"
done
wait $PIDS

cd $UNINSTALLED_ROOT
if [ ! -f gst-$BRANCH ]; then
  echo -ne "\n****************\n All DownLoaded\n****************\n"
  #ln -s $BRANCH/gstreamer/scripts/gst-uninstalled gst-$BRANCH
  #ln -sf /mnt/LinuxData/Scripts/GST/Pgst-uninstalled gst-$BRANCH
  #chmod +x gst-$BRANCH
fi

#source ./gst-$BRANCH
#export OF_SHARED_MAKEFILES_PATH=/mnt/LinuxData/openframeworks/libs/openFrameworksCompiled/project/makefileCommon/
#sed -e 's|include \$|\#source $|' -e 's|(||g' -e 's|)||g' -e 's| += |+=|g' -e 's| = |=|g' -e 's|ifdef |if $|g' \
#-e 's|ifeq \$CROSS_COMPILING,1|\if \[ CROSS_COMPILING -eq 1 \]|' -e 's|endif|fi|g' \
sed -e 's|\" $shell|\"|' $BRANCH/gstreamer/scripts/gst-uninstalled > $HOME_DIR/Pgst-uninstalled.sh

#ls $HOME_DIR
#cat $OF_SHARED_MAKEFILES_PATH/config.linux.common.mk
source $HOME_DIR/Rpi.sh

echo -ne "\ninfo: PLATFORM_DEFINES = $PLATFORM_DEFINES\n"
echo -ne "\ninfo: PLATFORM_LIBRARY_SEARCH_PATHS = $PLATFORM_LIBRARY_SEARCH_PATHS\n"
echo -ne "\ninfo: LDFLAGS = \"$PLATFORM_LDFLAGS\"\n"
echo -ne "\ninfo: LIBS = $PLATFORM_LIBRARIES\n"
echo -ne "\ninfo: INCLUDES = $PLATFORM_HEADER_SEARCH_PATHS\n"
echo -ne "\ninfo: PLATFORM_CFLAGS = ${PLATFORM_CFLAGS}\n"

cd $GST_UNINSTALLED_ROOT

echo -ne "\n*************************** \n  All Done!\n***************************\n"

echo "$PWD $GST_UNINSTALLED_ROOT"

#$SHELL -c 
test $(source $GST_UNINSTALLED_ROOT/gstreamer/scripts/git-update.sh)
cat $GST_UNINSTALLED_ROOT/gstreamer/config.log
cat $ERROR_LOG