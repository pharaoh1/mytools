cmd_/opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/linux/can/.install := /bin/bash scripts/headers_install.sh /opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/linux/can ./include/uapi/linux/can bcm.h error.h gw.h netlink.h raw.h; /bin/bash scripts/headers_install.sh /opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/linux/can ./include/linux/can ; /bin/bash scripts/headers_install.sh /opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/linux/can ./include/generated/uapi/linux/can ; for F in ; do echo "\#include <asm-generic/$$F>" > /opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/linux/can/$$F; done; touch /opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/linux/can/.install
