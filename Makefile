GO_EASY_ON_ME=1
<<<<<<< HEAD
SYSROOT=/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.3.sdk
=======
SYSROOT=/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.0.sdk
>>>>>>> ac86c8c9b9c2af6ae9f5c2dce447e98afcf0454f
include theos/makefiles/common.mk

TWEAK_NAME = multislide
multislide_FILES = Tweak.xm
multislide_FRAMEWORKS= UIKit Foundation
multislide_PRIVATE_FRAMEWORKS = TelephonyUI

include $(THEOS_MAKE_PATH)/tweak.mk
