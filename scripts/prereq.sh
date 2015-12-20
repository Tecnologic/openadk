#!/bin/sh
# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

# resolve prerequisites for OpenADK build

topdir=$(pwd)
target="$@"
flags="$MAKEFLAGS"
out=0

mirror=http://distfiles.openadk.org
makever=4.1
bashver=4.3.30

# detect operating system
os=$(env uname)
osver=$(env uname -r)
printf " --->  $os $osver for build detected.\n"

# check if the filesystem is case sensitive
rm -f foo
echo >FOO
if [ -e foo ]; then
  printf "ERROR: OpenADK cannot be built in a case-insensitive file system."
  case $os in
    CYG*)
      printf "Building OpenADK on $os needs a small registry change."
      printf "http://cygwin.com/cygwin-ug-net/using-specialnames.html"
      ;;
    Darwin*)
      printf "Building OpenADK on $os needs a case-sensitive disk partition."
      printf "For Snow Leopard and above you can use diskutil to resize your existing disk."
      printf "Example: sudo diskutil resizeVolume disk0s2 90G 1 jhfsx adk 30G"
      printf "For older versions you might consider to use a disk image:"
      printf "hdiutil create -type SPARSE -fs 'Case-sensitive Journaled HFS+' -size 30g ~/openadk.dmg"
      ;;
  esac
  rm -f FOO
  exit 1
fi
rm -f FOO

# do we have a download tool?
tools="curl wget"
for tool in $tools; do
  printf " --->  checking if $tool is installed.. "
  if which $tool >/dev/null; then
    printf "found\n"
    case $tool in
      curl)
        FETCHCMD="$(which $tool) -L -k -f -s -o "
        ;;
      wget)
        FETCHCMD="$(which $tool) --no-check-certificate -q -O "
        ;;
    esac
    break
  else
    printf "not found\n"
    continue
  fi
done
if [ -z "$FETCHCMD" ]; then
  printf "ERROR: no download tool found. Fatal error.\n"
  exit 1
fi

# do we have a checksum tool?
tools="sha256sum sha256 cksum shasum"
for tool in $tools; do
  printf " --->  checking if $tool is installed.. "
  if which $tool >/dev/null 2>/dev/null; then
    printf "found\n"
    # check if cksum is usable
    case $tool in
      sha256sum)
        SHA256=$(which $tool)
        ;;
      sha256)
        SHA256="$(which $tool) -q"
        ;;
      cksum)
        if cksum -q >/dev/null 2>/dev/null; then
          SHA256="$(which $tool) -q -a sha256"
        else
          continue
        fi
        ;;
      shasum)
        SHA256="$(which $tool) -a 256"
        ;;
    esac
    break
  else
    printf "not found\n"
    continue
  fi
done
if [ -z "$SHA256" ]; then
  printf "ERROR: no checksum tool found. Fatal error.\n"
  exit 1
fi

# create download dir
if [ ! -d $topdir/dl ]; then
  mkdir -p $topdir/dl
fi

# check for c compiler
compilerbins="clang cc gcc"
for compilerbin in $compilerbins; do
  printf " --->  checking if $compilerbin is installed.. "
  if which $compilerbin >/dev/null; then
    printf "found\n"
    CC=$compilerbin
    break
  else
    printf "not found\n"
    continue
  fi
done

# check for c++ compiler
compilerbins="clang++ c++ g++"
for compilerbin in $compilerbins; do
  printf " --->  checking if $compilerbin is installed.. "
  if which $compilerbin >/dev/null; then
    printf "found\n"
    CXX=$compilerbin
    break
  else
    printf "not found\n"
    continue
  fi
done

gnu_host_name=$(${CC} -dumpmachine)

# relocation of topdir?
olddir=$(grep "^ADK_TOPDIR" prereq.mk 2>/dev/null |cut -d '=' -f 2)
newdir=$(pwd)

if [ ! -z "$olddir" ]; then
  if [ "$olddir" != "$newdir" ]; then
    printf " --->  adk directory was relocated, fixing .."
    sed -i -e "s#$olddir#$newdir#g" $(find target_* -name \*.pc|xargs) 2>/dev/null
    sed -i -e "s#$olddir#$newdir#g" $(find host_${gnu_host_name} -type f|xargs) 2>/dev/null
    sed -i -e "s#$olddir#$newdir#g" $(find target_*/scripts -type f|xargs) 2>/dev/null
    sed -i -e "s#$olddir#$newdir#" target_*/etc/ipkg.conf 2>/dev/null
    sleep 2
    printf "done\n"
  fi
fi


case :$PATH: in
  (*:$topdir/host_${gnu_host_name}/bin:*) ;;
  (*) export PATH=$topdir/host_${gnu_host_name}/bin:$PATH ;;
esac

# check for GNU make
makebins="gmake make"
for makebin in $makebins; do
  printf " --->  checking if $makebin is installed.. "
  if which $makebin >/dev/null 2>/dev/null; then
    printf "found\n"
    printf " --->  checking if it is GNU make.. "
    $makebin --version 2>/dev/null| grep GNU >/dev/null
    if [ $? -eq 0 ]; then
      printf "yes\n"
      MAKE=$(which $makebin)
      break
    else
      # we need to build GNU make
      printf "no\n"
      printf " --->  compiling missing GNU make.. "
      cd dl
      $FETCHCMD make-${makever}.tar.gz $mirror/make-${makever}.tar.gz
      if [ $? -ne 0 ]; then
        printf "ERROR: failed to download make from $mirror\n"
        exit 1
      fi
      cd ..
      mkdir tmp
      cd tmp
      tar xzf ../dl/make-${makever}.tar.gz
      cd make-$makever
      ./configure --prefix=$topdir/host_$gnu_host_name/
      make
      make install
      cd ..
      cd ..
      rm -rf tmp
      MAKE=$topdir/host_$gnu_host_name/bin/make
      makebin=$topdir/host_$gnu_host_name/bin/make
      printf " done\n"
    fi
  else
    printf "not found\n"
    continue
  fi
done

# check for bash
printf " --->  checking if bash is installed.. "
if which bash >/dev/null; then
  printf "found\n"
  printf " --->  checking if it is bash 4.x.. "
  bash --version 2>/dev/null| grep "Version 4" >/dev/null
  if [ $? -eq 0 ]; then
    printf "yes\n"
  else
    # we need to build GNU bash 4.x
    printf "not found\n"
    printf " --->  compiling missing GNU bash.. "
    cd dl
    $FETCHCMD bash-${bashver}.tar.gz $mirror/bash-${bashver}.tar.gz
    if [ $? -ne 0 ]; then
      printf "ERROR: failed to download make from $mirror\n"
      exit 1
    fi
    cd ..
    mkdir tmp
    cd tmp
    tar xzf ../dl/bash-${bashver}.tar.gz
    cd bash-${bashver}
    ./configure --prefix=$topdir/host_$gnu_host_name/
    make
    make install
    cd ..
    cd ..
    rm -rf tmp
    printf " done\n"
  fi
fi

# skip the script if distclean / cleandir
if [ "$target" = "distclean" -o "$target" = "cleandir" ]; then
  touch prereq.mk
  $makebin ADK_TOPDIR=$topdir -s -f Makefile.adk $flags $target
  exit 0
fi

printf " --->  checking if strings is installed.. "
if ! which strings >/dev/null 2>&1; then
  echo You must install strings to continue.
  echo
  out=1
  printf "not found\n"
fi
printf "found\n"

printf " --->  checking if perl is installed.. "
if ! which perl >/dev/null 2>&1; then
  echo You must install perl to continue.
  echo
  out=1
  printf "not found\n"
fi
printf "found\n"

# creating prereq.mk
echo "ADK_TOPDIR:=$(readlink -nf . 2>/dev/null || pwd -P)" > $topdir/prereq.mk
echo "BASH:=$(which bash)" >> $topdir/prereq.mk
echo "SHELL:=$(which bash)" >> $topdir/prereq.mk
echo "GMAKE:=$MAKE" >> $topdir/prereq.mk
echo "MAKE:=$MAKE" >> $topdir/prereq.mk
echo "FETCHCMD:=$FETCHCMD" >> $topdir/prereq.mk
echo "SHA256:=$SHA256" >> $topdir/prereq.mk
echo "GNU_HOST_NAME:=${gnu_host_name}" >> $topdir/prereq.mk
echo "OS_FOR_BUILD:=${os}" >> $topdir/prereq.mk
echo "ARCH_FOR_BUILD:=$(${CC} -dumpmachine | sed \
    -e 's/x86_64-linux-gnux32/x32/' \
    -e s'/-.*//' \
    -e 's/sparc.*/sparc/' \
    -e 's/armeb.*/armeb/g' \
    -e 's/arm.*/arm/g' \
    -e 's/m68k.*/m68k/' \
    -e 's/sh[234]/sh/' \
    -e 's/mips-.*/mips/' \
    -e 's/mipsel-.*/mipsel/' \
    -e 's/i[3-9]86/x86/' \
    )" >>prereq.mk

if [ "$CC" = "clang" ]; then
  echo "HOST_CC:=${CC} -fbracket-depth=1024" >> $topdir/prereq.mk
else
  echo "HOST_CC:=${CC}" >> $topdir/prereq.mk
fi
if [ "$CXX" = "clang++" ]; then
  echo "HOST_CXX:=${CXX} -fbracket-depth=1024" >> $topdir/prereq.mk
else
  echo "HOST_CXX:=${CXX}" >> $topdir/prereq.mk
fi

echo 'LANGUAGE:=C' >> $topdir/prereq.mk
echo 'LC_ALL:=C' >> $topdir/prereq.mk
echo "_PATH:=$PATH" >> $topdir/prereq.mk
echo "PATH:=${topdir}/scripts:/usr/sbin:$PATH" >> $topdir/prereq.mk
echo "GIT:=$(which git 2>/dev/null)" >> $topdir/prereq.mk
echo "export ADK_TOPDIR GIT SHA256 BASH SHELL" >> $topdir/prereq.mk

# check if compiler works
cat >Makefile.tmp <<'EOF'
include ${ADK_TOPDIR}/prereq.mk
all: test

test: test.c
	@${HOST_CC} ${HOST_CFLAGS} -o $@ $^ ${LDADD}
EOF
cat >test.c <<-'EOF'
	#include <stdio.h>
	int
	main()
	{
		printf("YES");
		return (0);
	}
EOF

$MAKE --no-print-directory ADK_TOPDIR=$topdir -f Makefile.tmp 2>&1
X=$(./test)
if [ $X != YES ]; then
  echo "$X" | sed 's/^/| /'
  echo Cannot compile a simple test programme.
  echo You must install a host make and C compiler.
  echo
  out=1
fi
rm test.c test Makefile.tmp 2>/dev/null

# error out on any required prerequisite
if [ $out -ne 0 ]; then
  exit $out
fi

host_build_bc=0
if which bc >/dev/null 2>&1; then
  if ! echo quit|bc -q 2>/dev/null >/dev/null; then
    host_build_bc=1
  else 
    if bc -v 2>&1| grep -q BSD >/dev/null 2>&1; then
      host_build_bc=1
    fi 
  fi
else
  host_build_bc=1
fi

host_build_bison=0
if ! which bison >/dev/null 2>&1; then
  host_build_bison=1
fi

host_build_bzip2=0
if ! which bzip2 >/dev/null 2>&1; then
  host_build_bzip2=1
fi

host_build_file=0
if ! which file >/dev/null 2>&1; then
  host_build_file=1
fi

host_build_flex=0
if ! which flex >/dev/null 2>&1; then
  host_build_flex=1
fi

host_build_m4=0
if ! which m4 >/dev/null 2>&1; then
  host_build_m4=1
fi

host_build_mksh=0
if ! which mksh >/dev/null 2>&1; then
  host_build_mksh=1
fi

host_build_patch=0
if ! which patch >/dev/null 2>&1; then
  host_build_patch=1
fi

host_build_pkgconf=0
if ! which pkgconf >/dev/null 2>&1; then
  host_build_pkgconf=1
fi

host_build_tar=0
if which tar >/dev/null 2>&1; then
  if ! tar --version 2>/dev/null|grep GNU >/dev/null;then
    host_build_tar=1
  fi
else
  host_build_tar=1
fi

host_build_findutils=0
if which xargs >/dev/null 2>&1; then
  if ! xargs --version 2>/dev/null|grep GNU >/dev/null;then
    host_build_findutils=1
  fi
fi

if which find >/dev/null 2>&1; then
  if ! find --version 2>/dev/null|grep GNU >/dev/null;then
    host_build_findutils=1
  fi
fi

host_build_grep=0
if which grep >/dev/null 2>&1; then
  if ! grep --version 2>/dev/null|grep GNU >/dev/null;then
    host_build_grep=1
  fi
fi

host_build_gawk=0
if ! which gawk >/dev/null 2>&1; then
  host_build_gawk=1
fi

host_build_sed=0
if which sed >/dev/null 2>&1; then
  if ! sed --version 2>/dev/null|grep GNU >/dev/null;then
    host_build_sed=1
  fi
fi

host_build_xz=0
if ! which xz >/dev/null 2>&1; then
  host_build_xz=1
fi

# optional
host_build_cdrtools=0
if ! which mkisofs >/dev/null 2>&1; then
  host_build_cdrtools=1
fi

host_build_ccache=0
if ! which ccache >/dev/null 2>&1; then
  host_build_ccache=1
fi

host_build_genext2fs=0
if ! which genext2fs >/dev/null 2>&1; then
  host_build_genext2fs=1
fi

host_build_lzma=0
if ! which lzma >/dev/null 2>&1; then
  host_build_lzma=1
fi

host_build_lz4=0
if ! which lz4c >/dev/null 2>&1; then
  host_build_lz4=1
fi

host_build_lzop=0
if ! which lzop >/dev/null 2>&1; then
  host_build_lzop=1
fi

host_build_qemu=0
if ! which qemu-img >/dev/null 2>&1; then
  host_build_qemu=1
fi

host_build_coreutils=0
if which tr >/dev/null 2>&1; then
  if ! tr --version 2>/dev/null|grep GNU >/dev/null;then
    host_build_coreutils=1
  fi
fi

echo "config ADK_HOST_BUILD_TOOLS" > $topdir/target/config/Config.in.prereq
printf "\t%s\n" "bool" >> $topdir/target/config/Config.in.prereq
printf "\t%s\n" "default y" >> $topdir/target/config/Config.in.prereq
# always required
if [ $host_build_bc -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_BC" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_bison -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_BISON" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_bzip2 -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_BZIP2" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_file -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_FILE" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_flex -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_FLEX" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_gawk -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_GAWK" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_grep -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_GREP" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_m4 -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_M4" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_mksh -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_MKSH" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_patch -eq 1 ]; then 
  printf "\t%s\n" "select ADK_HOST_BUILD_PATCH" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_pkgconf -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_PKGCONF" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_findutils -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_FINDUTILS" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_sed -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_SED" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_tar -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_TAR" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_xz -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_XZ" >> $topdir/target/config/Config.in.prereq
fi
# optional
if [ $host_build_ccache -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_CCACHE if ADK_HOST_NEED_CCACHE" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_cdrtools -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_CDRTOOLS if ADK_HOST_NEED_CDRTOOLS" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_genext2fs -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_GENEXT2FS if ADK_HOST_NEED_GENEXT2FS" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_lzma -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_LZMA if ADK_HOST_NEED_LZMA" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_lz4 -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_LZ4 if ADK_HOST_NEED_LZ4" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_lzop -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_LZOP if ADK_HOST_NEED_LZOP" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_qemu -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_QEMU if ADK_HOST_NEED_QEMU" >> $topdir/target/config/Config.in.prereq
fi
if [ $host_build_coreutils -eq 1 ]; then
  printf "\t%s\n" "select ADK_HOST_BUILD_COREUTILS if ADK_HOST_NEED_COREUTILS" >> $topdir/target/config/Config.in.prereq
fi

# create Host OS symbols
case $os in
  Linux)
    printf "\nconfig ADK_HOST_LINUX\n" >> $topdir/target/config/Config.in.prereq
    printf "\tbool\n" >> $topdir/target/config/Config.in.prereq
    printf "\tdefault y\n" >> $topdir/target/config/Config.in.prereq
    ;;
  Darwin)
    printf "\nconfig ADK_HOST_DARWIN\n" >> $topdir/target/config/Config.in.prereq
    printf "\tbool\n" >> $topdir/target/config/Config.in.prereq
    printf "\tdefault y\n" >> $topdir/target/config/Config.in.prereq
    ;;
  OpenBSD)
    printf "\nconfig ADK_HOST_OPENBSD\n" >> $topdir/target/config/Config.in.prereq
    printf "\tbool\n" >> $topdir/target/config/Config.in.prereq
    printf "\tdefault y\n" >> $topdir/target/config/Config.in.prereq
    ;;
  FreeBSD)
    printf "\nconfig ADK_HOST_FREEBSD\n" >> $topdir/target/config/Config.in.prereq
    printf "\tbool\n" >> $topdir/target/config/Config.in.prereq
    printf "\tdefault y\n" >> $topdir/target/config/Config.in.prereq
    ;;
  NetBSD)
    printf "\nconfig ADK_HOST_NETBSD\n" >> $topdir/target/config/Config.in.prereq
    printf "\tbool\n" >> $topdir/target/config/Config.in.prereq
    printf "\tdefault y\n" >> $topdir/target/config/Config.in.prereq
    ;;
  MirBSD)
    printf "\nconfig ADK_HOST_MIRBSD\n" >> $topdir/target/config/Config.in.prereq
    printf "\tbool\n" >> $topdir/target/config/Config.in.prereq
    printf "\tdefault y\n" >> $topdir/target/config/Config.in.prereq
    ;;
  Cygwin*)
    printf "\nconfig ADK_HOST_CYGWIN\n" >> $topdir/target/config/Config.in.prereq
    printf "\tbool\n" >> $topdir/target/config/Config.in.prereq
    printf "\tdefault y\n" >> $topdir/target/config/Config.in.prereq
    ;;
esac

if [ "$target" = "defconfig" ]; then
  $makebin ADK_TOPDIR=$topdir --no-print-directory -f Makefile.adk $flags $target
  exit 0
fi

if [ ! -f $topdir/.config ]; then
    # create a config if no exist
    touch .firstrun
    $makebin ADK_TOPDIR=$topdir --no-print-directory -f Makefile.adk menuconfig
else
  # scan host-tool prerequisites of certain packages before building.
  . $topdir/.config
  if [ -n "$ADK_PACKAGE_KODI" ]; then
    NEED_JAVA="$NEED_JAVA kodi"
  fi

  if [ -n "$ADK_PACKAGE_ICU4C" ]; then
    NEED_STATIC_LIBSTDCXX="$NEED_STATIC_LIBSTDCXX icu4c"
  fi

  if [ -n "$ADK_PACKAGE_XKEYBOARD_CONFIG" ]; then
    NEED_XKBCOMP="$NEED_XKBCOMP xkeyboard-config"
  fi

  if [ -n "$ADK_PACKAGE_FONT_BITSTREAM_100DPI" ]; then
    NEED_MKFONTDIR="$NEED_MKFONTDIR font-bitstream-100dpi"
  fi

  if [ -n "$ADK_PACKAGE_FONT_BITSTREAM_75DPI" ]; then
    NEED_MKFONTDIR="$NEED_MKFONTDIR font-bitstream-75dpi"
  fi

  if [ -n "$ADK_PACKAGE_FONT_ADOBE_100DPI" ]; then
    NEED_MKFONTDIR="$NEED_MKFONTDIR font-adobe-100dpi"
  fi

  if [ -n "$ADK_PACKAGE_FONT_ADOBE_75DPI" ]; then
    NEED_MKFONTDIR="$NEED_MKFONTDIR font-adobe-75dpi"
  fi

  if [ -n "$NEED_MKFONTDIR" ]; then
    if ! which mkfontdir >/dev/null 2>&1; then
      printf "You need mkfontdir to build $NEED_MKFONTDIR"
      out=1
    fi
  fi

  if [ -n "$NEED_XKBCOMP" ]; then
    if ! which xkbcomp >/dev/null 2>&1; then
      printf "You need xkbcomp to build $NEED_XKBCOMP"
      out=1
    fi
  fi

  if [ -n "$NEED_JAVA" ]; then
    if ! which java >/dev/null 2>&1; then
      printf "You need java to build $NEED_JAVA"
      out=1
    fi
  fi

  if [ -n "$NEED_STATIC_LIBSTDCXX" ]; then
cat >test.c <<-'EOF'
	#include <stdio.h>
	int
	main()
	{
		return (0);
	}
EOF
    if ! $CXX -static-libstdc++ -o test test.c 2>/dev/null ; then
      printf "You need static version of libstdc++ installed to build $NEED_STATIC_LIBSTDCXX"
      out=1
      rm test test.c 2>/dev/null
    fi
  fi

  # error out
  if [ $out -ne 0 ]; then
    exit $out
  fi

  # start build
  $makebin ADK_TOPDIR=$topdir --no-print-directory -f Makefile.adk $flags $target
fi
