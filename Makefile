include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = ClassDumpRuntime
ClassDumpRuntime_CFLAGS = -fobjc-arc
ClassDumpRuntime_FILES = $(wildcard ClassDump/*/*.m) $(wildcard ClassDump/*/*/*.m)

include $(THEOS_MAKE_PATH)/library.mk
