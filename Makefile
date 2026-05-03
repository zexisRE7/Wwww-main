ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

THEOS_PACKAGE_SCHEME = rootless
THEOS ?= $(HOME)/theos

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 34306jit

# FLAGS
$(TWEAK_NAME)_CCFLAGS = -std=c++17 -fno-rtti -DNDEBUG -Wall -Wno-unused-variable -Wno-unused-function -Wno-unused-value -fvisibility=hidden
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wall -Wno-unused-variable -Wno-unused-function -Wno-unused-value -fvisibility=hidden

# FRAMEWORKS
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController

# LIB
$(TWEAK_NAME)_LDFLAGS += Other/libdobby_fixed.a

# SAFE FILE LOAD (ไม่มีไฟล์ก็ไม่พัง)
ESP_MM := $(wildcard Esp/*.mm)
ESP_M  := $(wildcard Esp/*.m)
IMGUI_CPP := $(wildcard IMGUI/*.cpp)
IMGUI_MM  := $(wildcard IMGUI/*.mm)

# FILES
$(TWEAK_NAME)_FILES = ImGuiDrawView.mm oxorany/oxorany.cpp \
$(ESP_MM) \
$(ESP_M) \
$(IMGUI_CPP) \
$(IMGUI_MM)

include $(THEOS_MAKE_PATH)/tweak.mk
