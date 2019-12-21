include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = ClassDumpRuntime
ClassDumpRuntime_CFLAGS = -fobjc-arc
ClassDumpRuntime_FILES = $(wildcard ClassDump/Services/*.m) $(wildcard ClassDump/Models/*.m)

include $(THEOS_MAKE_PATH)/library.mk
