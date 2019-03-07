FROM fassnacht/raspbian-sysroot:stretch-lite-2018-11-13-upgraded-qt5-dependencies

#install dependencies
RUN apt-get update \
    && apt-get install -y \
        gcc g++ build-essential cmake curl git \
        bzip2 zip python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

# get tools
RUN git clone https://github.com/raspberrypi/tools

# choose Qt version
ENV QT_VERSION_MAJOR 5.9
ENV QT_VERSION 5.9.7

ENV QT_BASE_SRC https://download.qt.io/official_releases/qt/"$QT_VERSION_MAJOR"/"$QT_VERSION"/single/qt-everywhere-opensource-src-"$QT_VERSION".tar.xz
ENV QT_BASE_DIR /qt-everywhere-opensource-src-"$QT_VERSION"
ADD raspbian-stretch-qt5-device.patch /patches/
RUN curl -sSL $QT_BASE_SRC | tar xJ \
    && patch -p0 < /patches/raspbian-stretch-qt5-device.patch \
    && cd $QT_BASE_DIR \
    && rm -rf qtwebengine \
    && rm -rf qtscript \
    && rm -rf qtpurchasing \
    && bash ./configure --help \
    && bash ./configure -opensource -confirm-license -no-compile-examples -nomake examples -nomake tools -no-use-gold-linker -opengl es2 -device linux-rasp-pi3-g++ -device-option CROSS_COMPILE=/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf- -sysroot /sysroot -v -prefix /usr/local/qt5pi -extprefix /qt5pi -hostprefix /qt5 \
    && make -j6 \
    && make install \
    && rm -rf $QT_BASE_DIR
#put qt executables into paths
ENV PATH $QT_HOST_PREFIX/bin:$PATH

# run build.sh script by default
CMD ["bash", "/build.sh"]