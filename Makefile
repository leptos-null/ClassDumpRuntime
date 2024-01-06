include $(THEOS)/makefiles/common.mk

TOOL_NAME = classdumpctl

classdumpctl_FILES = $(wildcard classdumpctl_src/*.m) $(wildcard ClassDump/*/*.m) $(wildcard ClassDump/*/*/*.m)
classdumpctl_CFLAGS = -fobjc-arc -I.
classdumpctl_CODESIGN_FLAGS = -Sentitlements.plist
classdumpctl_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tool.mk
