PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
TARGET := iphone:clang:latest:11.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = SpringBoard
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NowPlayingInfo
$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_LDFLAGS = -lrocketbootstrap
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MediaRemote AppSupport

LIBRARY_NAME = libnowplaying
$(LIBRARY_NAME)_FILES = Library.m
$(LIBRARY_NAME)_CFLAGS = -objc-arc
$(LIBRARY_NAME)_LDFLAGS = -lrocketbootstrap
$(LIBRARY_NAME)_PRIVATE_FRAMEWORKS = MediaRemote AppSupport
$(LIBRARY_NAME)_INSTALL_PATH = /usr/local/lib

TOOL_NAME = nowplaying
$(TOOL_NAME)_FILES = main.m
$(TOOL_NAME)_LDFLAGS = -lnowplaying
$(TOOL_NAME)_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tool.mk

before-package::
	@mkdir -p $(THEOS_STAGING_DIR)/usr/local/include
	@cp $(THEOS_BUILD_DIR)/NowPlayingInfo.h $(THEOS_STAGING_DIR)/usr/local/include
