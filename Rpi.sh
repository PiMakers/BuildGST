###############################################################################
# CONFIGURE CORE PLATFORM MAKEFILE
#   This file is where we make platform and architecture specific
#   configurations. This file can be specified for a generic architecture or can
#   be defined as variants. For instance, normally this file will be located in
#   a platform specific subpath such as
#
#        $OF_ROOT/libs/openFrameworksComplied/linux64
#
#   This file will then be a generic platform file like:
#
#        configure.linux64.default.make
#
#   Or it can specify a specific platform variant like:
#
#        configure.linuxarmv6l.raspberrypi.make
#
################################################################################

################################################################################
# include common rules
#
#   all linux systems have several rules in common so most of them are included
#   from the following file
#
################################################################################

#source $OF_SHARED_MAKEFILES_PATH/config.linux.common.mk

################################################################################
# PLATFORM DEFINES
#   Create a list of DEFINES for this platform. An example of fully
#   qualified flag might look something like this: -DTARGET_OPENGLES2
#
#   DEFINES are used throughout the openFrameworks code, especially when making
#   #if $decisions for cross-platform compatibility.  For instance, when
#   choosing a video playback framework, the openFrameworks base classes look at
#   the DEFINES to determine what source files to include or what default player
#   to use.
#
#   Note: Leave a leading space when adding list items with the+=operator
################################################################################
#HW_PLATFORM=Rpi1
case "$HW_PLATFORM" in
        Rpi1)
            echo "Complieing for raspberrypi1"
            ;;
         
        Rpi2)
            stop
            ;;
        
        condrestart)
            if test "x`pidof anacron`" != x; then
                stop
                start
            fi
            ;;
         
        *)
            echo "HW_PLATFORM NOT SPECIFIED!!!!"
            return 1
 
esac

# defines used inside openFrameworks libs.
PLATFORM_DEFINES="-DTARGET_RASPBERRY_PI"

# TODO many of these are not relevant to openFrameworks were just pasted from hello_pi examples
# from raspberry pi examples
PLATFORM_DEFINES+=" -DSTANDALONE"
PLATFORM_DEFINES+=" -DPIC"
PLATFORM_DEFINES+=" -D_REENTRANT"
PLATFORM_DEFINES+=" -D_LARGEFILE64_SOURCE"
PLATFORM_DEFINES+=" -D_FILE_OFFSET_BITS=64"
PLATFORM_DEFINES+=" -D__STDC_CONSTANT_MACROS"
PLATFORM_DEFINES+=" -D__STDC_LIMIT_MACROS"
PLATFORM_DEFINES+=" -DTARGET_POSIX"
PLATFORM_DEFINES+=" -DHAVE_LIBOPENMAX=2"
PLATFORM_DEFINES+=" -DOMX"
PLATFORM_DEFINES+=" -DOMX_SKIP64BIT"
PLATFORM_DEFINES+=" -DUSE_EXTERNAL_OMX"
PLATFORM_DEFINES+=" -DHAVE_LIBBCM_HOST"
PLATFORM_DEFINES+=" -DUSE_EXTERNAL_LIBBCM_HOST"
PLATFORM_DEFINES+=" -DUSE_VCHIQ_ARM"

################################################################################
# PLATFORM CFLAGS
#   This is a list of fully qualified CFLAGS required when compiling for this
#   platform. These flags will always be added when compiling a project or the
#   core library.  These flags are presented to the compiler AFTER the
#   PLATFORM_OPTIMIZATION_CFLAGS below.
#
#   Note: Leave a leading space when adding list items with the+=operator
################################################################################

PLATFORM_CFLAGS+=" -march=armv6"
PLATFORM_CFLAGS+=" -mfpu=vfp"
PLATFORM_CFLAGS+=" -mfloat-abi=hard"
PLATFORM_CFLAGS+=" -fPIC"
PLATFORM_CFLAGS+=" -ftree-vectorize"
PLATFORM_CFLAGS+=" -Wno-psabi"
PLATFORM_CFLAGS+=" -pipe"


################################################################################
# PLATFORM LIBRARIES
#   These are library names/paths that are platform specific and are specified
#   using names or paths.  The library flag i.e. -l is prefixed automatically.
#
#   PLATFORM_LIBRARIES are libraries that can be found in the library search
#       paths.
#   PLATFORM_STATIC_LIBRARIES is a list of required static libraries.
#   PLATFORM_SHARED_LIBRARIES is a list of required shared libraries.
#   PLATFORM_PKG_CONFIG_LIBRARIES is a list of required libraries that are
#       under system control and are easily accesible via the package
#       configuration utility i.e. pkg-config
#
#   See the helpfile for the -l flag here for more information:
#       http://gcc.gnu.org/onlinedocs/gcc/Link-Options.html
#
#   Note: Leave a leading space when adding list items with the+=operator
################################################################################

# raspberry pi specific
PLATFORM_LIBRARIES+=" -lGLESv2"
PLATFORM_LIBRARIES+=" -lGLESv1_CM"
PLATFORM_LIBRARIES+=" -lEGL"
PLATFORM_LIBRARIES+=" -lopenmaxil"
PLATFORM_LIBRARIES+=" -lbcm_host"
PLATFORM_LIBRARIES+=" -lvcos"
PLATFORM_LIBRARIES+=" -lvchiq_arm"
PLATFORM_LIBRARIES+=" -lpcre"
PLATFORM_LIBRARIES+=" -lrt"
PLATFORM_LIBRARIES+=" -lX11"
PLATFORM_LIBRARIES+=" -ldl"


PLATFORM_LDFLAGS+=" -pthread"


################################################################################
# PLATFORM HEADER SEARCH PATHS
#   These are header search paths that are platform specific and are specified
#   using fully-qualified paths.  The include flag i.e. -I is prefixed
#   automatically. These are usually not required, but may be required by some
#   experimental platforms such as the raspberry pi or other other embedded
#   architectures.
#
#   Note: Leave a leading space when adding list items with the+=operator
################################################################################

# Broadcom hardware interface library
PLATFORM_HEADER_SEARCH_PATHS="-I$RPI_ROOT/opt/vc/include/interface/vcos/pthreads"
PLATFORM_HEADER_SEARCH_PATHS+=" -I$RPI_ROOT/opt/vc/include"
PLATFORM_HEADER_SEARCH_PATHS+=" -I$RPI_ROOT/opt/vc/include/IL"
PLATFORM_HEADER_SEARCH_PATHS+=" -I$RPI_ROOT/opt/vc/include/interface/vmcs_host"
PLATFORM_HEADER_SEARCH_PATHS+=" -I$RPI_ROOT/opt/vc/include/interface/vmcs_host/linux"

##########################################################################################
# PLATFORM LIBRARY SEARCH PATH
#   These are special libraries assocated with the above header search paths
#   Do not use full flag syntax, that will be added automatically later
#   These paths are ABSOLUTE.
#   Simply use space delimited paths.
#   Note: Leave a leading space when adding list items with the+=operator
##########################################################################################

PLATFORM_LIBRARY_SEARCH_PATHS="-L$RPI_ROOT/opt/vc/lib"


if [ $CROSS_COMPILING == 1 ]; then
echo "detected cross compiling $CROSS_COMPILING"
	#You have specified TOOLCHAIN_ROOT with an environment variable
    if [ ! -n $TOOLCHAIN_ROOT ]; then
    	TOOLCHAIN_ROOT=/opt/cross/bin
	fi
    #You have specified GCC_PREFIX with an environment variable
	if [ ! -n $GCC_PREFIX ]; then
	    GCC_PREFIX=arm-linux-gnueabihf
	fi

    PLATFORM_CXX=$TOOLCHAIN_ROOT/bin/$GCC_PREFIX-g++
	PLATFORM_CC=$TOOLCHAIN_ROOT/bin/$GCC_PREFIX-gcc
	PLATFORM_AR=$TOOLCHAIN_ROOT/bin/$GCC_PREFIX-ar
	PLATFORM_LD=$TOOLCHAIN_ROOT/bin/$GCC_PREFIX-ld

	SYSROOT=$RPI_ROOT

	PLATFORM_CFLAGS+=" --sysroot=$SYSROOT"

	PLATFORM_HEADER_SEARCH_PATHS+=" -I$SYSROOT/usr/include/c++/4.9"
	PLATFORM_HEADER_SEARCH_PATHS+=" -I$SYSROOT/usr/include/$GCC_PREFIX/c++/4.9"

	PLATFORM_LIBRARY_SEARCH_PATHS+=" -L$SYSROOT/usr/lib/$GCC_PREFIX"
	PLATFORM_LIBRARY_SEARCH_PATHS+=" -L$SYSROOT/usr/lib/gcc/$GCC_PREFIX/4.9"

	PLATFORM_LDFLAGS+=" --sysroot=$SYSROOT"
	PLATFORM_LDFLAGS+=" -Xlinker -rpath-link=$SYSROOT/usr/lib/$GCC_PREFIX"
	PLATFORM_LDFLAGS+=" -Xlinker -rpath-link=$SYSROOT/lib/$GCC_PREFIX"
	PLATFORM_LDFLAGS+=" -Xlinker -rpath-link=$SYSROOT/opt/vc/lib"
	PLATFORM_LDFLAGS+=" -Xlinker -rpath-link=$SYSROOT/usr/lib/arm-linux-gnueabihf/pulseaudio"

	PKG_CONFIG_LIBDIR=$SYSROOT/usr/lib/pkgconfig:$SYSROOT/usr/lib/$GCC_PREFIX/pkgconfig:$SYSROOT/usr/share/pkgconfig

    export PATH="$TOOLCHAIN_ROOT/bin:$PATH"

else echo Compiling nativ RPI; sleep 5
fi
	export PATH=$TOOLCHAIN_ROOT/bin:$PATH	
	echo "PATH = $PATH"

#From http://gstreamer-devel.966125.n4.nabble.com/Lates-Gstreamer-on-Raspberry-PI-td4678758.html
# this helps plugins to find gstreamer
	export PKG_CONFIG_PATH=/opt/Rpi3DevRootfs/opt/GST/lib/pkgconfig:$RPI_ROOT/opt/vc/lib/pkgconfig:$RPI_ROOT/usr/lib/pkgconfig:$RPI_ROOT/usr/lib/$GCC_PREFIX/pkgconfig:$RPI_ROOT/usr/share/pkgconfig
	export PKG_CONFIG_SYSROOT_DIR=$RPI_ROOT
	echo -ne "PKG_CONFIG_SYSROOT_DIR = $PKG_CONFIG_SYSROOT_DIR \n$PKG_CONFIG_PATH = $PKG_CONFIG_PATH"

	export LD_LIBRARY_PATH="$TOP_BUILD_DIR/Buid/lib:$RPI_ROOT/opt/vc/lib $RPI_ROOT/usr/local/lib/:$RPI_ROOT/usr/lib/$GCC_PREFIX:$RPI_ROOT/lib/$GCC_PREFIX:$RPI_ROOT/usr/lib/$GCC_PREFIX/pulseaudio:$RPI_ROOT/usr/lib/$GCC_PREFIX:$RPI_ROOT/usr/lib/gcc/$GCC_PREFIX/4.9:/usr/lib/$GCC_PREFIX:/opt/vc/lib:/usr/local/lib/:/lib/$GCC_PREFIX:/usr/lib/$GCC_PREFIX/pulseaudio:/home/pimaker/src/GST/Build"
	echo -ne"LD_LIBRARY_PATH = $LD_LIBRARY_PATH"

	export CFLAGS="$PLATFORM_CFLAGS $PLATFORM_DEFINES $PLATFORM_HEADER_SEARCH_PATHS"
	export CPPFLAGS="$CFLAGS"
	echo -ne "\nPLATFORM_CFLAGS = ${PLATFORM_CFLAGS}\n"

	export LIBS="$PLATFORM_LIBRARIES"
	echo -ne "\nLIBS = ${LIBS}\n"

	export LDFLAGS="$PLATFORM_LIBRARY_SEARCH_PATHS $PLATFORM_LDFLAGS $LIBS"	
	echo -ne "\nLDFLAGS = ${LDFLAGS}\n"

	export PYTHON=/usr/bin/python3
	echo -ne "\nPYTHON = ${PYTHON}\n"
