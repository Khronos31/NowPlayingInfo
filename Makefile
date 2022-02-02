TARGET := iphone:clang:latest:7.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = SpringBoard
#FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NowPlayingInfo
$(TWEAK_NAME)_FILES = NowPlayingInfo.xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_LDFLAGS = -lrocketbootstrap
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MediaRemote

LIBRARY_NAME = libnowplaying
$(LIBRARY_NAME)_FILES = NPLibrary.mm
$(LIBRARY_NAME)_LDFLAGS = -lrocketbootstrap
$(LIBRARY_NAME)_PRIVATE_FRAMEWORKS = MediaRemote
$(LIBRARY_NAME)_INSTALL_PATH = /usr/local/lib

TOOL_NAME = nowplaying
$(TOOL_NAME)_FILES = main.mm
$(TOOL_NAME)_LDFLAGS = -lnowplaying
$(TOOL_NAME)_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tool.mk
