include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = ClassDumpRuntime
ClassDumpRuntime_CFLAGS = -fobjc-arc -I Sources/ClassDumpRuntime/include
ClassDumpRuntime_FILES = $(wildcard ClassDumpRuntime/*/*.m) $(wildcard ClassDumpRuntime/*/*/*.m)

include $(THEOS_MAKE_PATH)/library.mk
