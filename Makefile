GO_EASY_ON_ME=1
SYSROOT=/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk
include theos/makefiles/common.mk

TWEAK_NAME = multislide
multislide_FILES = Tweak.xm
multislide_FRAMEWORKS= UIKit Foundation
multislide_PRIVATE_FRAMEWORKS = TelephonyUI

include $(THEOS_MAKE_PATH)/tweak.mk
