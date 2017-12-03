If you appreciate this project, you can support me on Patreon !
[![Patreon !](https://raw.githubusercontent.com/Miouyouyou/RockMyy/master/.img/button-patreon.png)](https://www.patreon.com/Miouyouyou)

[![Pledgie !](https://pledgie.com/campaigns/32702.png)](https://pledgie.com/campaigns/32702)
[![Tip with Altcoins](https://raw.githubusercontent.com/Miouyouyou/Shapeshift-Tip-button/9e13666e9d0ecc68982fdfdf3625cd24dd2fb789/Tip-with-altcoin.png)](https://shapeshift.io/shifty.html?destination=16zwQUkG29D49G6C7pzch18HjfJqMXFNrW&output=BTC)

# About

This example demonstrates how to :

* assemble a library written with the ARMv8-A 64 bits GNU ASsembly syntax
* call a native procedure, included in this library, from an Android
app using the JNI.

The called procedure will then call back a Java method, defined in the
Android Application, using the JNI helpers.

# Building
## Building using GNU Make

### Requirements

* GNU AS (aarch64)
* Gold linker (aarch64)
* An ARMv8-A 64 bits Android phone/emulator on which you have installation privileges

### Build

Run `make` from this folder

#### Manually

Run the following commands :

```
# cross compiler prefix. Remove if you're assembling from an ARM machine
export PREFIX="aarch64-linux-gnu"
export APP_DIR="./apk"
export LIBNAME="libarcane.so"
${PREFIX}-as -o decypherArcane.o decypherArcane.s
${PREFIX}-ld.gold -shared --dynamic-linker=/system/bin/linker -shared --hash-style=sysv -o $LIBNAME decypherArcane.o
mkdir -p $APP_DIR/app/src/main/jniLibs/arm64-v8a
cp $LIBNAME $APP_DIR/app/src/main/jniLibs/arm64-v8a
```

## Building using Android ndk-build

### Requirements

* The Android NDK path in your system's PATH directory

### Build

* On Windows, run 'mkbuild.bat'
* On Linux, run 'mkbuild.sh'

# Installing the prepared APK

* Connect your ARMv8-A 64 bits Android phone/emulator
* open a shell or a "command window"
* `cd` to the **apk** folder

Then :
* On Windows run `gradlew installDebug`.
* On Linux run `./gradlew installDebug`

