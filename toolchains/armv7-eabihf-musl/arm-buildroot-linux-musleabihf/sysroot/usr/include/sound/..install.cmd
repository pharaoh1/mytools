cmd_/opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/sound/.install := /bin/bash scripts/headers_install.sh /opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/sound ./include/uapi/sound asequencer.h asound.h asound_fm.h compress_offload.h compress_params.h emu10k1.h firewire.h hdsp.h hdspm.h sb16_csp.h sfnt_info.h; /bin/bash scripts/headers_install.sh /opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/sound ./include/sound ; /bin/bash scripts/headers_install.sh /opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/sound ./include/generated/uapi/sound ; for F in ; do echo "\#include <asm-generic/$$F>" > /opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/sound/$$F; done; touch /opt/armv7-eabihf--musl--stable-2018.02-2/arm-buildroot-linux-musleabihf/sysroot/usr/include/sound/.install
