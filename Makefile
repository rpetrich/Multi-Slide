include theos/makefiles/common.mk

TWEAK_NAME = multislide
multislide_FILES = Tweak.xm
multislide_FRAMEWORKS= UIKit Foundation
multislide_PRIVATE_FRAMEWORKS = TelephonyUI

include $(THEOS_MAKE_PATH)/tweak.mk
