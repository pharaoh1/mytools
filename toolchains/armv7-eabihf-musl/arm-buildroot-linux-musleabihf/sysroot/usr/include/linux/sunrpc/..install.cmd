cmd_/opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/linux/sunrpc/.install := /bin/bash scripts/headers_install.sh /opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/linux/sunrpc ./include/uapi/linux/sunrpc debug.h; /bin/bash scripts/headers_install.sh /opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/linux/sunrpc ./include/linux/sunrpc ; /bin/bash scripts/headers_install.sh /opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/linux/sunrpc ./include/generated/uapi/linux/sunrpc ; for F in ; do echo "\#include <asm-generic/$$F>" > /opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/linux/sunrpc/$$F; done; touch /opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/linux/sunrpc/.install
