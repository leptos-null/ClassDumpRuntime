include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = ClassDumpRuntime
# not Swift related, but the requirements for a Swift package and theos build are similar
ClassDumpRuntime_CFLAGS = -fobjc-arc -DSWIFT_PACKAGE=1
ClassDumpRuntime_FILES = $(wildcard ClassDump/*/*.m) $(wildcard ClassDump/*/*/*.m)

include $(THEOS_MAKE_PATH)/library.mk
