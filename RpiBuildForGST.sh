#https://gist.github.com/sphaero/02717b0b35501ad94863
# https://gist.github.com/ea4b7a4739ca8c859bd7c3c3d8b087e6.git
#export GST_VERSION=1.0
#export RPI_ROOT=/home/pi/RPI_ROOT
#export TOOLCHAIN_ROOT=/opt/cross/bin
#export PLATFORM_OS=Linux
#export PLATFORM_ARCH=armv6l
#export PKG_CONFIG_PATH=$RPI_ROOT/usr/lib/arm-linux-gnueabihf/pkgconfig:$RPI_ROOT/usr/share/pkgconfig:$RPI_ROOT/usr/lib/pkgconfig
#export PKG_CONFIG_SYSROOT_DIR=$RPI_ROOT
#!/bin/bash --debugger
export MAKEFLAGS="-j4"
set -e

CROSS_COMPILING=$CROSS_COMPILING
UPDATE=0
INSTALL=1
TOP_BUILD_DIR=$RPI_ROOT/home/pi/src/GST


STATUS="\nModules :\n*******\n"

BRANCH="master"

if grep -q BCM2 /proc/cpuinfo; then
    echo "RPI BUILD!"
    RPI="1"
fi
RPI=5


if [[ $CROSS_COMPILING -eq 1 ]]; then RPI_ROOT=/opt/Rpi3DevRootfs;
else RPI_ROOT=""
fi
echo "RPI_ROOT  = $RPI_ROOT"
echo CROSS_COMPILING=$CROSS_COMPILING
#[ -n "$1" ] && BRANCH=$1

# Create a log file of the build as well as displaying the build on the tty as it runs
#exec > >(tee build_gstreamer.log)
#exec 2>&1

if [[ $UPDATE -eq 1 ]]; then echo "UPDATE  = $UPDATE So We run this tasks..."
# Update and Upgrade, otherwise the build may fail due to inconsistencies

sudo apt-get update && sudo apt-get upgrade -y --force-yes

# Get the required libraries
sudo apt-get install -y --force-yes build-essential autotools-dev automake autoconf \
                                    libtool autopoint libxml2-dev zlib1g-dev libglib2.0-dev \
                                    pkg-config bison flex python3 git gtk-doc-tools libasound2-dev \
                                    libgudev-1.0-dev libxt-dev libvorbis-dev libcdparanoia-dev \
                                    libpango1.0-dev libtheora-dev libvisual-0.4-dev iso-codes \
                                    libgtk-3-dev libraw1394-dev libiec61883-dev libavc1394-dev \
                                    libv4l-dev libcairo2-dev libcaca-dev libspeex-dev libpng-dev \
                                    libshout3-dev libjpeg-dev libaa1-dev libflac-dev libdv4-dev \
                                    libtag1-dev libwavpack-dev libpulse-dev libsoup2.4-dev libbz2-dev \
                                    libcdaudio-dev libdc1394-22-dev ladspa-sdk libass-dev \
                                    libcurl4-gnutls-dev libdca-dev libdirac-dev libdvdnav-dev \
                                    libexempi-dev libexif-dev libfaad-dev libgme-dev libgsm1-dev \
                                    libiptcdata0-dev libkate-dev libmimic-dev libmms-dev \
                                    libmodplug-dev libmpcdec-dev libofa0-dev libopus-dev \
                                    librsvg2-dev librtmp-dev libschroedinger-dev libslv2-dev \
                                    libsndfile1-dev libsoundtouch-dev libspandsp-dev libx11-dev \
                                    libxvidcore-dev libzbar-dev libzvbi-dev liba52-0.7.4-dev \
                                    libcdio-dev libdvdread-dev libmad0-dev libmp3lame-dev \
                                    libmpeg2-4-dev libopencore-amrnb-dev libopencore-amrwb-dev \
                                    libsidplay1-dev libtwolame-dev libx264-dev libusb-1.0 \
                                    python-gi-dev yasm python3-dev libgirepository1.0-dev

fi

#cd $HOME

#[ ! -d src ] && mkdir src
#cd src

#[ ! -d GST ] && mkdir GST
#cd GST

[ ! -d $TOP_BUILD_DIR ] && mkdir -p $TOP_BUILD_DIR
cd $TOP_BUILD_DIR

#from OF
################################################################################
# PLATFORM DEFINES
#   Create a list of DEFINES for this platform.  The list will be converted into
#
#   Note: Leave a leading space when adding list items with the += operator
################################################################################

	# defines used inside openFrameworks libs.
	PLATFORM_DEFINES='-DTARGET_RASPBERRY_PI'
	PLATFORM_DEFINES+=' -DSTANDALONE'
	PLATFORM_DEFINES+=' -DPIC'
	PLATFORM_DEFINES+=' -D_REENTRANT'
	PLATFORM_DEFINES+=' -D_LARGEFILE64_SOURCE'
	PLATFORM_DEFINES+=' -D_FILE_OFFSET_BITS=64'
	PLATFORM_DEFINES+=' -D__STDC_CONSTANT_MACROS'
	PLATFORM_DEFINES+=' -D__STDC_LIMIT_MACROS'
	PLATFORM_DEFINES+=' -DTARGET_POSIX'
	PLATFORM_DEFINES+=' -DHAVE_LIBOPENMAX=2'
	PLATFORM_DEFINES+=' -DOMX'
	PLATFORM_DEFINES+=' -DOMX_SKIP64BIT'
	PLATFORM_DEFINES+=' -DUSE_EXTERNAL_OMX'
	PLATFORM_DEFINES+=' -DHAVE_LIBBCM_HOST'
	PLATFORM_DEFINES+=' -DUSE_EXTERNAL_LIBBCM_HOST'
	PLATFORM_DEFINES+=' -DUSE_VCHIQ_ARM'


################################################################################
# PLATFORM CFLAGS
#   This is a list of fully qualified CFLAGS required when compiling for this
#   platform. These flags will always be added when compiling a project or the
#   core library.  These flags are presented to the compiler AFTER the
#   PLATFORM_OPTIMIZATION_CFLAGS below.
#
#   Note: Leave a leading space when adding list items with the += operator
################################################################################

# RPI2 -mcpu=cortex-a7  -mfpu=neon-vfpv4
# RPI3 -mcpu=cortex-a53  -mfpu=neon-fp-armv8 #-march=armv8-a -mfloat-abi=hard -mfpu=neon-vfpv4 -funsafe-math-optimizations

	# from omxplayer
	PLATFORM_CFLAGS='-march=armv6zk'       #instead of PLATFORM_CFLAGS += -march=armv6
	PLATFORM_CFLAGS+=' -mcpu=arm1176jzf-s'
	PLATFORM_CFLAGS+=' -fomit-frame-pointer'
	PLATFORM_CFLAGS+=' -mabi=aapcs-linux'
	PLATFORM_CFLAGS+=' -mtune=arm1176jzf-s'
	PLATFORM_CFLAGS+=' -mno-apcs-stack-check'
	PLATFORM_CFLAGS+=' -mstructure-size-boundary=32'
	PLATFORM_CFLAGS+=' -mno-sched-prolog'

	# orig from "default.mk"
	PLATFORM_CFLAGS+=' -mfpu=vfp'
	PLATFORM_CFLAGS+=' -mfloat-abi=hard'
	PLATFORM_CFLAGS+=' -fPIC'
	PLATFORM_CFLAGS+=' -ftree-vectorize'
	PLATFORM_CFLAGS+=' -Wno-psabi'
	PLATFORM_CFLAGS+=' -pipe'

# Error flags (for GST)
PLATFORM_CFLAGS+=' -Wno-error'
PLATFORM_CFLAGS+=' -Wno-redundant-decls'

################################################################################
# PLATFORM LIBRARIES
#   These are library names/paths that are platform specific and are specified
#   using names or paths.  The library flag (i.e. -l) is prefixed automatically.
#
#   PLATFORM_LIBRARIES are libraries that can be found in the library search
#       paths.
#   PLATFORM_STATIC_LIBRARIES is a list of required static libraries.
#   PLATFORM_SHARED_LIBRARIES is a list of required shared libraries.
#   PLATFORM_PKG_CONFIG_LIBRARIES is a list of required libraries that are
#       under system control and are easily accesible via the package
#       configuration utility (i.e. pkg-config)
#
#   See the helpfile for the -l flag here for more information:
#       http://gcc.gnu.org/onlinedocs/gcc/Link-Options.html
#
#   Note: Leave a leading space when adding list items with the += operator
################################################################################

	# raspberry pi specific
	PLATFORM_LIBRARIES=' -lGLESv2'
	PLATFORM_LIBRARIES+=' -lGLESv1_CM'
	PLATFORM_LIBRARIES+=' -lEGL'
	PLATFORM_LIBRARIES+=' -lopenmaxil'
	PLATFORM_LIBRARIES+=' -lbcm_host'
	PLATFORM_LIBRARIES+=' -lvcos'
	PLATFORM_LIBRARIES+=' -lvchiq_arm'
	PLATFORM_LIBRARIES+=' -lpcre'
	PLATFORM_LIBRARIES+=' -lrt'
	PLATFORM_LIBRARIES+=' -lX11'
	PLATFORM_LIBRARIES+=' -ldl'

#ffmpeg
PLATFORM_LIBRARIES+=' -lsmbclient'
PLATFORM_LIBRARIES+=' -lssh'


PLATFORM_LDFLAGS='-pthread'

################################################################################
# PLATFORM HEADER SEARCH PATHS
#   These are header search paths that are platform specific and are specified
#   using fully-qualified paths.  The include flag (i.e. -I) is prefixed
#   automatically. These are usually not required, but may be required by some
#   experimental platforms such as the raspberry pi or other other embedded
#   architectures.
#
#   Note: Leave a leading space when adding list items with the += operator
################################################################################

	# Broadcom hardware interface library
	PLATFORM_HEADER_SEARCH_PATHS="-I$RPI_ROOT/opt/vc/include"
	PLATFORM_HEADER_SEARCH_PATHS+=" -I$RPI_ROOT/opt/vc/include/IL"
	PLATFORM_HEADER_SEARCH_PATHS+=" -I$RPI_ROOT/opt/vc/src/hello_pi/libs/ilclient"
	PLATFORM_HEADER_SEARCH_PATHS+=" -I$RPI_ROOT/opt/vc/include/interface/vcos/pthreads"
	PLATFORM_HEADER_SEARCH_PATHS+=" -I$RPI_ROOT/opt/vc/include/interface/vmcs_host/linux"


	PLATFORM_HEADER_SEARCH_PATHS+=" -I$RPI_ROOT/usr/include/samba-4.0"
	PLATFORM_HEADER_SEARCH_PATHS+=" -I$RPI_ROOT/usr/include/libssh"

##########################################################################################
# PLATFORM LIBRARY SEARCH PATH
#   These are special libraries assocated with the above header search paths
#   Do not use full flag syntax, that will be added automatically later
#   These paths are ABSOLUTE.
#   Simply use space delimited paths.
#   Note: Leave a leading space when adding list items with the += operator
##########################################################################################

	PLATFORM_LIBRARY_SEARCH_PATHS="-L$RPI_ROOT/opt/vc/lib"
	PLATFORM_LIBRARY_SEARCH_PATHS+=" -L$RPI_ROOT/usr/lib/$GCC_PREFIX"
	PLATFORM_LIBRARY_SEARCH_PATHS+=" -L$RPI_ROOT/usr/lib/$GCC_PREFIX"

	if [[ $CROSS_COMPILING -eq 1 ]]; then echo -ne "\nCrossCompiling...\n";

		if [[ ! -n $TOOLCHAIN_ROOT ]]; then TOOLCHAIN_ROOT="/opt/cross"; fi

		if [[ ! -n $GCC_PREFIX ]]; then GCC_PREFIX="arm-linux-gnueabihf"; fi

		PLATFORM_CXX="$TOOLCHAIN_ROOT/bin/$GCC_PREFIX-g++"
		PLATFORM_CC="$TOOLCHAIN_ROOT/bin/$GCC_PREFIX-gcc"
		PLATFORM_AR="$TOOLCHAIN_ROOT/bin/$GCC_PREFIX-ar"
		PLATFORM_LD="$TOOLCHAIN_ROOT/bin/$GCC_PREFIX-ld"

		SYSROOT="$RPI_ROOT"

		PLATFORM_CFLAGS+=" --sysroot=$SYSROOT"

		PLATFORM_HEADER_SEARCH_PATHS+=" -I$SYSROOT/usr/include/c++/4.9"
		PLATFORM_HEADER_SEARCH_PATHS+=" -I$SYSROOT/usr/include/$GCC_PREFIX/c++/4.9/bits"
		PLATFORM_HEADER_SEARCH_PATHS+=" -I$SYSROOT/usr/include/$GCC_PREFIX/c++/4.9/ext"

		PLATFORM_LIBRARY_SEARCH_PATHS+=" -L$SYSROOT/lib/$GCC_PREFIX"
		PLATFORM_LIBRARY_SEARCH_PATHS+=" -L$SYSROOT/usr/lib/$GCC_PREFIX"
		PLATFORM_LIBRARY_SEARCH_PATHS+=" -L$SYSROOT/usr/lib/gcc/$GCC_PREFIX/4.9"

		PLATFORM_LDFLAGS+=" --sysroot=$SYSROOT"
		PLATFORM_LDFLAGS+=" -Wl,-rpath -Wl,$SYSROOT/usr/lib/$GCC_PREFIX"
		PLATFORM_LDFLAGS+=" -Wl,-rpath -Wl,$SYSROOT/lib/$GCC_PREFIX"
		PLATFORM_LDFLAGS+=" -Wl,-rpath -Wl,$SYSROOT/opt/vc/lib"
		PLATFORM_LDFLAGS+=" -Wl,-rpath -Wl,$SYSROOT/usr/lib/arm-linux-gnueabihf/pulseaudio"

		PKG_CONFIG_LIBDIR="$SYSROOT/usr/lib/pkgconfig:$SYSROOT/usr/lib/$GCC_PREFIX/pkgconfig:$SYSROOT/usr/share/pkgconfig:$SYSROOT/opt/vc/lib/pkgconfig"

	fi


echo -ne "\ninfo: PLATFORM_DEFINES = $PLATFORM_DEFINES\n"
echo -ne "\ninfo: PLATFORM_LIBRARY_SEARCH_PATHS = $PLATFORM_LIBRARY_SEARCH_PATHS\n"
echo -ne "\ninfo: LDFLAGS = \"$PLATFORM_LDFLAGS\"\n"
echo -ne "\ninfo: LIBS = $PLATFORM_LIBRARIES\n"
echo -ne "\ninfo: INCLUDES = $PLATFORM_HEADER_SEARCH_PATHS\n"
echo -ne "\ninfo: PLATFORM_CFLAGS = ${PLATFORM_CFLAGS}\n"

if [[ $RPI -eq 5 ]]; then

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

	export LDFLAGS="$PLATFORM_LIBRARY_SEARCH_PATHS $PLATFORM_LDFLAGS $LIBS"	
	echo -ne "\nLDFLAGS = ${LDFLAGS}\n"

	export LIBS="$PLATFORM_LIBRARIES"
	echo -ne "\nLIBS = ${LIBS}\n"

	export PYTHON=/usr/bin/python3
	echo -ne "\nPYTHON = ${PYTHON}\n"

fi

EXTRA_CONFIGURE="--prefix=$RPI_ROOT/opt/GST"
#EXTRA_CONFIGURE+=" --with-pkg-config-path=$PKG_CONFIG_PATH"
#EXTRA_CONFIGURE+=' --enable-static'
EXTRA_CONFIGURE+=' --disable-gtk-doc'
EXTRA_CONFIGURE+=' --disable-silent-rules'
EXTRA_CONFIGURE+=' --disable-fatal-warnings'
EXTRA_CONFIGURE+=' --enable-introspection=no'

EXTRA_CONFIGURE+=' --disable-arm-iwmmxt'	
#EXTRA_CONFIGURE+=' --disable-maintainer-mode'
EXTRA_CONFIGURE+=' --with-included-modules' 		#pango
EXTRA_CONFIGURE+=' --enable-static'
EXTRA_CONFIGURE+=' --with-omx-target=rpi'
#Plagins-good
EXTRA_CONFIGURE+=' --enable-orc'
#EXTRA_CONFIGURE+=" --with-sysroot=$RPI_ROOT"
[ $CROSS_COMPILING -eq 1 ] && EXTRA_CONFIGURE+=" --host=$GCC_PREFIX"

EXTRA_CONFIGURE+=' --enable-shared'
EXTRA_CONFIGURE+=" --with-pkg-config-path=$PKG_CONFIG_PATH"
EXTRA_CONFIGURE+=" --disable-examples"
EXTRA_CONFIGURE+=" --disable-direct3d"
EXTRA_CONFIGURE+=" --enable-dispmanx=yes"			#pluginBadˇˇˇˇˇ
EXTRA_CONFIGURE+=" --with-gtk=3.0" 
EXTRA_CONFIGURE+=" --with-player-tests" 
EXTRA_CONFIGURE+=" --enable-opengl=no" 
EXTRA_CONFIGURE+=" --disable-x11"
EXTRA_CONFIGURE+=" --enable-egl"
EXTRA_CONFIGURE+=" --enable-gles2=yes" 
EXTRA_CONFIGURE+=" --enable-extra-checks" 
EXTRA_CONFIGURE+=" --enable-opengl=no" 
EXTRA_CONFIGURE+=" --enable-dispmanx"
EXTRA_CONFIGURE+=" --enable-dependency-tracking"
EXTRA_CONFIGURE+=" --disable-glx"
export EXTRA_CONFIGURE=$EXTRA_CONFIGURE

#  --enable-gtk-doc-html=no 
#Plagins-good
PLAGINS_GOOD_EXTRA_CONFIGURE=
PLAGINS_GOOD_EXTRA_CONFIGURE+='  --enable-orc' 	#use Orc if installed
#PLAGINS_GOOD_EXTRA_CONFIGURE +=' --disable-Bsymbolic     avoid linking with -Bsymbolic'
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-alpha         disable dependency-less alpha plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-apetag        disable dependency-less apetag plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-audiofx       disable dependency-less audiofx plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-audioparsers  disable dependency-less audioparsers plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-auparse       disable dependency-less auparse plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-autodetect    disable dependency-less autodetect plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-avi           disable dependency-less avi plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-cutter        disable dependency-less cutter plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-debugutils    disable dependency-less debugutils plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-deinterlace   disable dependency-less deinterlace plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-dtmf          disable dependency-less dtmf plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-effectv       disable dependency-less effectv plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-equalizer     disable dependency-less equalizer plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-flv           disable dependency-less flv plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-flx           disable dependency-less flx plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-goom          disable dependency-less goom plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-goom2k1       disable dependency-less goom2k1 plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-icydemux      disable dependency-less icydemux plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-id3demux      disable dependency-less id3demux plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-imagefreeze   disable dependency-less imagefreeze plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-interleave    disable dependency-less interleave plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-isomp4        disable dependency-less isomp4 plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-law           disable dependency-less law plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-level         disable dependency-less level plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-matroska      disable dependency-less matroska plugin
PLAGINS_GOOD_EXTRA_CONFIGURE+='  --enable-monoscope=yes' 	#disable dependency-less monoscope plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-multifile     disable dependency-less multifile plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-multipart     disable dependency-less multipart plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-replaygain    disable dependency-less replaygain plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-rtp           disable dependency-less rtp plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-rtpmanager    disable dependency-less rtpmanager plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-rtsp          disable dependency-less rtsp plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-shapewipe     disable dependency-less shapewipe plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-smpte         disable dependency-less smpte plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-spectrum      disable dependency-less spectrum plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-udp           disable dependency-less udp plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-videobox      disable dependency-less videobox plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-videocrop     disable dependency-less videocrop plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-videofilter   disable dependency-less videofilter plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-videomixer    disable dependency-less videomixer plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-wavenc        disable dependency-less wavenc plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-wavparse      disable dependency-less wavparse plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-y4m           disable dependency-less y4m plugin
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-directsound        disable DirectSound plug-in: directsoundsink
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-waveform           disable Win32 WaveForm: waveformsink
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-oss                disable OSS audio: ossaudio
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-oss4               disable Open Sound System 4: oss4
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-sunaudio           disable Sun Audio: sunaudio
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-osx_audio          disable OSX audio: osxaudio
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-osx_video          disable OSX video: osxvideosink
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-gst_v4l2           disable Video 4 Linux 2: video4linux2

#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --enable-v4l2-probe     enable V4L2 plugin to probe devices [default=no]
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-x                  disable X libraries and plugins: ximagesrc
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-aalib              disable aalib ASCII Art library: aasink
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-aalibtest     do not try to compile and run a test AALIB program
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-cairo              disable Cairo graphics rendering and gobject bindings: cairo
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-flac               disable FLAC lossless audio: flac
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-gdk_pixbuf         disable GDK pixbuf: gdkpixbuf
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-jack               disable Jack: jack
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-jpeg               disable jpeg library: jpeg
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-libcaca            disable libcaca coloured ASCII art: cacasink
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-libdv              disable libdv DV demuxer/decoder: dv
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-libpng             disable Portable Network Graphics library: png
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-pulse              disable pulseaudio plug-in: pulseaudio
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-dv1394             disable raw1394 and avc1394 library: 1394
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-shout2             disable Shoutcast/Icecast client library: shout2
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-soup               disable soup http client plugin (2.4): souphttpsrc
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-speex              disable speex speech codec: speex
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-taglib             disable taglib tagging library: taglib
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-vpx                disable VPX decoder: vpx
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-wavpack            disable wavpack plug-in: wavpack
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-zlib               disable zlib support for qtdemux/matroska
#PLAGINS_GOOD_EXTRA_CONFIGURE +='  --disable-bz2                disable bz2 library for matroska



#gst-libav

#gst-libav -> ffmpeg
LIBAV_EXTRA_CONFIGURE="--enable-omx-rpi"
LIBAV_EXTRA_CONFIGURE+=" --enable-mmal"
[ $CROSS_COMPILING -eq 1 ] && LIBAV_EXTRA_CONFIGURE+=' --enable-cross-compile' && export cross_prefix="$GCC_PREFIX-"
#LIBAV_EXTRA_CONFIGURE+=' --extra-cflags="-mfpu=vfp -mfloat-abi=hard -mno-apcs-stack-check -mstructure-size-boundary=32 -mno-sched-prolog"'

LIBAV_EXTRA_CONFIGURE+=' --enable-static'
LIBAV_EXTRA_CONFIGURE+=' --arch=arm'
LIBAV_EXTRA_CONFIGURE+=' --cpu=arm1176jzf-s'
LIBAV_EXTRA_CONFIGURE+=' --target-os=linux'
LIBAV_EXTRA_CONFIGURE+=' --disable-hwaccels'
LIBAV_EXTRA_CONFIGURE+=' --enable-parsers'
LIBAV_EXTRA_CONFIGURE+=' --disable-muxers'
LIBAV_EXTRA_CONFIGURE+=' --disable-filters'
LIBAV_EXTRA_CONFIGURE+=' --disable-encoders'
LIBAV_EXTRA_CONFIGURE+=' --disable-devices'
LIBAV_EXTRA_CONFIGURE+=' --disable-doc'
LIBAV_EXTRA_CONFIGURE+=' --disable-postproc'
LIBAV_EXTRA_CONFIGURE+=' --enable-gpl'
LIBAV_EXTRA_CONFIGURE+=' --enable-version3'
LIBAV_EXTRA_CONFIGURE+=' --enable-protocols'
LIBAV_EXTRA_CONFIGURE+=' --enable-libsmbclient'
#LIBAV_EXTRA_CONFIGURE+=' --enable-libssh'	 #FIXME!!!!
LIBAV_EXTRA_CONFIGURE+=' --enable-nonfree'
LIBAV_EXTRA_CONFIGURE+=' --enable-openssl'
LIBAV_EXTRA_CONFIGURE+=' --enable-pthreads'
LIBAV_EXTRA_CONFIGURE+=' --enable-pic'
LIBAV_EXTRA_CONFIGURE+=' --disable-armv5te'
LIBAV_EXTRA_CONFIGURE+=' --disable-neon'
LIBAV_EXTRA_CONFIGURE+=' --enable-armv6t2'
LIBAV_EXTRA_CONFIGURE+=' --enable-armv6'
LIBAV_EXTRA_CONFIGURE+=' --enable-hardcoded-tables'
LIBAV_EXTRA_CONFIGURE+=' --disable-runtime-cpudetect'
LIBAV_EXTRA_CONFIGURE+=' --disable-debug'
LIBAV_EXTRA_CONFIGURE+=' --disable-crystalhd'
LIBAV_EXTRA_CONFIGURE+=' --disable-decoders'

LIBAV_EXTRA_CONFIGURE+=' --enable-decoder=mjpeg'
LIBAV_EXTRA_CONFIGURE+=' --enable-decoder=mjpegb'
LIBAV_EXTRA_CONFIGURE+=' --enable-decoder=mpeg4'
LIBAV_EXTRA_CONFIGURE+=' --enable-decoder=theora'
LIBAV_EXTRA_CONFIGURE+=' --enable-decoder=qtrle'
LIBAV_EXTRA_CONFIGURE+=' --enable-decoder=h264'
LIBAV_EXTRA_CONFIGURE+=' --enable-decoder=vc1'
LIBAV_EXTRA_CONFIGURE+=' --enable-decoder=wmv3'
LIBAV_EXTRA_CONFIGURE+=' --enable-decoder=vp6'
LIBAV_EXTRA_CONFIGURE+=' --enable-decoder=vp6f'
LIBAV_EXTRA_CONFIGURE+=' --enable-decoder=vp8'
LIBAV_EXTRA_CONFIGURE+=' --enable-decoder=mpegvideo'
LIBAV_EXTRA_CONFIGURE+=' --enable-decoder=mpeg1video'
LIBAV_EXTRA_CONFIGURE+=' --enable-decoder=mpeg2video'
LIBAV_EXTRA_CONFIGURE+=' --enable-decoder=opus'
LIBAV_EXTRA_CONFIGURE+=' --enable-libx264'
LIBAV_EXTRA_CONFIGURE+=' --enable-libopenh264'

clear
echo "LIBAV_EXTRA_CONFIGURE = $LIBAV_EXTRA_CONFIGURE"
export with_libav_extra_configure=$LIBAV_EXTRA_CONFIGURE

MODULES=
MODULES+="gstreamer"
MODULES+=" orc"
MODULES+=" gst-plugins-base"
MODULES+=" gst-plugins-good"
MODULES+=" gst-plugins-bad"
MODULES+=" gst-plugins-ugly"
MODULES+=" gst-omx"
MODULES+=" gst-python"
MODULES+=" gst-rtsp-server"
MODULES+=" gst-ffmpeg"
MODULES+=" gst-libav"

#Libraries have been installed in:
#   /opt/GST/lib
#
#If you ever happen to want to link against installed libraries
#in a given directory, LIBDIR, you must either use libtool, and
#specify the full pathname of the library, or use the '-LLIBDIR'
#flag during linking and do at least one of the following:
#   - add LIBDIR to the 'LD_LIBRARY_PATH' environment variable
#     during execution
#   - add LIBDIR to the 'LD_RUN_PATH' environment variable
#     during linking
#   - use the '-Wl,-rpath -Wl,LIBDIR' linker flag
#   - have your system administrator add LIBDIR to '/etc/ld.so.conf'
#
#See any operating system documentation about shared libraries for
#more information, such as the ld(1) and ld.so(8) manual pages.
