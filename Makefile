NDK:=$(if $(ANDROID_NDK_HOME),$(ANDROID_NDK_HOME),$(ANDROID_NDK_ROOT))
API?=21
HOST:=$(notdir $(firstword $(wildcard $(NDK)/toolchains/llvm/prebuilt/*)))
TOOLCHAIN:=$(NDK)/toolchains/llvm/prebuilt/$(HOST)
SYSROOT:=$(TOOLCHAIN)/sysroot
SYSROOT_OPT:=$(if $(NDK),--sysroot=$(SYSROOT),)
PC_PKGS:=libnetfilter_queue libnfnetlink libmnl
PC_CFLAGS:=$(shell pkg-config --cflags $(PC_PKGS) 2>/dev/null)
PC_LIBS:=$(shell pkg-config --libs $(PC_PKGS) 2>/dev/null)
LIBNETLINK_SRC?=third_party/iproute2/lib/libnetlink.c
SRC:=src/nfqttl.c $(wildcard $(LIBNETLINK_SRC))
OUT_ARM64:=libs/arm64-v8a/nfqttl
OUT_ARMV7:=libs/armeabi-v7a/nfqttl
OUT_X86:=libs/x86/nfqttl
OUT_X86_64:=libs/x86_64/nfqttl
CLANG:=clang
CC_ARM64:=$(if $(NDK),$(TOOLCHAIN)/bin/aarch64-linux-android$(API)-clang,$(CLANG) --target=aarch64-linux-android$(API))
CC_ARMV7:=$(if $(NDK),$(TOOLCHAIN)/bin/armv7a-linux-androideabi$(API)-clang,$(CLANG) --target=armv7a-linux-androideabi$(API))
CC_X86:=$(if $(NDK),$(TOOLCHAIN)/bin/i686-linux-android$(API)-clang,$(CLANG) --target=i686-linux-android$(API))
CC_X86_64:=$(if $(NDK),$(TOOLCHAIN)/bin/x86_64-linux-android$(API)-clang,$(CLANG) --target=x86_64-linux-android$(API))
COMMON_CFLAGS:=-O2 -fPIE -D_GNU_SOURCE $(SYSROOT_OPT) $(PC_CFLAGS) $(EXTRA_CFLAGS)
COMMON_LDFLAGS:=-pie $(PC_LIBS) $(EXTRA_LDFLAGS)
.PHONY: all clean arm64 armeabi-v7a x86 x86_64
all: $(OUT_ARM64) $(OUT_ARMV7) $(OUT_X86) $(OUT_X86_64)
$(OUT_ARM64): $(SRC)
	mkdir -p $(dir $@)
	$(CC_ARM64) $(COMMON_CFLAGS) -o $@ $^ $(COMMON_LDFLAGS)
$(OUT_ARMV7): $(SRC)
	mkdir -p $(dir $@)
	$(CC_ARMV7) $(COMMON_CFLAGS) -o $@ $^ $(COMMON_LDFLAGS)
$(OUT_X86): $(SRC)
	mkdir -p $(dir $@)
	$(CC_X86) $(COMMON_CFLAGS) -o $@ $^ $(COMMON_LDFLAGS)
$(OUT_X86_64): $(SRC)
	mkdir -p $(dir $@)
	$(CC_X86_64) $(COMMON_CFLAGS) -o $@ $^ $(COMMON_LDFLAGS)
clean:
	rm -f $(OUT_ARM64) $(OUT_ARMV7) $(OUT_X86) $(OUT_X86_64)
