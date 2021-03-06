LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

commands_recovery_local_path := $(LOCAL_PATH)
# LOCAL_CPP_EXTENSION := .c

LOCAL_SRC_FILES := \
    recovery.c \
    bootloader.c \
    install.c \
    roots.c \
    ui.c \
    mounts.c \
    extendedcommands.c \
    nandroid.c \
    ../../system/core/toolbox/reboot.c \
    firmware.c \
    edifyscripting.c \
    setprop.c \
    default_recovery_ui.c \
    adb_install.c \
    verifier.c

ADDITIONAL_RECOVERY_FILES := $(shell echo $$ADDITIONAL_RECOVERY_FILES)
LOCAL_SRC_FILES += $(ADDITIONAL_RECOVERY_FILES)

LOCAL_MODULE := recovery

LOCAL_FORCE_STATIC_EXECUTABLE := true

#PHILZ_TOUCH_RECOVERY := true
ifdef PHILZ_TOUCH_RECOVERY
RECOVERY_NAME := PhilZ Touch
LOCAL_CFLAGS += -DPHILZ_TOUCH_RECOVERY
endif

ifdef I_AM_KOUSH
RECOVERY_NAME := ClockworkMod Recovery
LOCAL_CFLAGS += -DI_AM_KOUSH
else
ifndef RECOVERY_NAME
RECOVERY_NAME := CWM-based Recovery
endif
endif

ifdef PHILZ_TOUCH_RECOVERY
RECOVERY_VERSION := $(RECOVERY_NAME) 4
PHILZ_BUILD := 4.87.2
CWM_BASE_VERSION := 6.0.2.8
LOCAL_CFLAGS += -DPHILZ_BUILD="$(PHILZ_BUILD)"
LOCAL_CFLAGS += -DCWM_BASE_VERSION="$(CWM_BASE_VERSION)"
#compile date:
#LOCAL_CFLAGS += -DBUILD_DATE="\"`date`\""
else
RECOVERY_VERSION := $(RECOVERY_NAME) v6.0.2.8
endif

LOCAL_CFLAGS += -DRECOVERY_VERSION="$(RECOVERY_VERSION)"
RECOVERY_API_VERSION := 2
LOCAL_CFLAGS += -DRECOVERY_API_VERSION=$(RECOVERY_API_VERSION)

##############################################################
#device specific config                                      #
#Copyright (C) 2011-2012 sakuramilk <c.sakuramilk@gmail.com> #
#adapted from kbc-developers                                 #
##############################################################
#Galaxy S3 International
ifeq ($(TARGET_PRODUCT), cm_i9300)
TARGET_DEVICE := i930x
#TARGET_RECOVERY_PIXEL_FORMAT := \"RGBX_8888\"
LOCAL_CFLAGS += -DTARGET_DEVICE_I9300
ifdef PHILZ_TOUCH_RECOVERY
BOARD_CUSTOM_RECOVERY_KEYMAPPING := ../../../../../PhilZ_Touch/touch_source/philz_keys_s2.c
endif

#Galaxy S2 International
else ifeq ($(TARGET_PRODUCT), cm_i9100)
TARGET_DEVICE := i9100
#TARGET_RECOVERY_PIXEL_FORMAT := \"BGRA_8888\"
LOCAL_CFLAGS += -DTARGET_DEVICE_I9100
ifdef PHILZ_TOUCH_RECOVERY
BOARD_CUSTOM_RECOVERY_KEYMAPPING := ../../../../../PhilZ_Touch/touch_source/philz_keys_s2.c
endif

#Galaxy Note
else ifeq ($(TARGET_PRODUCT), cm_n7000)
TARGET_DEVICE := n7000
#TARGET_RECOVERY_PIXEL_FORMAT := \"RGBX_8888\"
LOCAL_CFLAGS += -DTARGET_DEVICE_N7000
ifdef PHILZ_TOUCH_RECOVERY
BOARD_CUSTOM_RECOVERY_KEYMAPPING := ../../../../../PhilZ_Touch/touch_source/philz_keys_s2.c
endif

#Galaxy Note 2
else ifeq ($(TARGET_PRODUCT), cm_n7100)
TARGET_DEVICE := n710x-i317M-T889
#TARGET_RECOVERY_PIXEL_FORMAT := \"RGBX_8888\"
LOCAL_CFLAGS += -DTARGET_DEVICE_N7100
ifdef PHILZ_TOUCH_RECOVERY
BOARD_CUSTOM_RECOVERY_KEYMAPPING := ../../../../../PhilZ_Touch/touch_source/philz_keys_s2.c
endif

#Galaxy Tab 2 P5100
else ifeq ($(TARGET_PRODUCT), cm_p5100)
TARGET_DEVICE := p5100
#TARGET_RECOVERY_PIXEL_FORMAT := \"RGBX_8888\"
LOCAL_CFLAGS += -DTARGET_DEVICE_P5100
ifdef PHILZ_TOUCH_RECOVERY
BOARD_CUSTOM_RECOVERY_KEYMAPPING := ../../../../../PhilZ_Touch/touch_source/philz_keys_s2.c
endif

#Undefined Device
else
TARGET_DEVICE := $(TARGET_PRODUCT)
endif

LOCAL_CFLAGS += -DTARGET_DEVICE="$(TARGET_DEVICE)"

#############################
#end device specific config #
#############################

ifdef PHILZ_TOUCH_RECOVERY
BOARD_USE_CUSTOM_RECOVERY_FONT := \"roboto_15x24.h\"
endif

ifdef BOARD_TOUCH_RECOVERY
ifeq ($(BOARD_USE_CUSTOM_RECOVERY_FONT),)
  BOARD_USE_CUSTOM_RECOVERY_FONT := \"roboto_15x24.h\"
endif
endif

ifeq ($(BOARD_USE_CUSTOM_RECOVERY_FONT),)
  BOARD_USE_CUSTOM_RECOVERY_FONT := \"font_10x18.h\"
endif

BOARD_RECOVERY_CHAR_WIDTH := $(shell echo $(BOARD_USE_CUSTOM_RECOVERY_FONT) | cut -d _  -f 2 | cut -d . -f 1 | cut -d x -f 1)
BOARD_RECOVERY_CHAR_HEIGHT := $(shell echo $(BOARD_USE_CUSTOM_RECOVERY_FONT) | cut -d _  -f 2 | cut -d . -f 1 | cut -d x -f 2)

LOCAL_CFLAGS += -DBOARD_RECOVERY_CHAR_WIDTH=$(BOARD_RECOVERY_CHAR_WIDTH) -DBOARD_RECOVERY_CHAR_HEIGHT=$(BOARD_RECOVERY_CHAR_HEIGHT)

BOARD_RECOVERY_DEFINES := BOARD_HAS_NO_SELECT_BUTTON BOARD_UMS_LUNFILE BOARD_RECOVERY_ALWAYS_WIPES BOARD_RECOVERY_HANDLES_MOUNT BOARD_TOUCH_RECOVERY RECOVERY_EXTEND_NANDROID_MENU TARGET_USE_CUSTOM_LUN_FILE_PATH

$(foreach board_define,$(BOARD_RECOVERY_DEFINES), \
  $(if $($(board_define)), \
    $(eval LOCAL_CFLAGS += -D$(board_define)=\"$($(board_define))\") \
  ) \
  )

LOCAL_STATIC_LIBRARIES :=

LOCAL_CFLAGS += -DUSE_EXT4
LOCAL_C_INCLUDES += system/extras/ext4_utils
LOCAL_STATIC_LIBRARIES += libext4_utils libz

# This binary is in the recovery ramdisk, which is otherwise a copy of root.
# It gets copied there in config/Makefile.  LOCAL_MODULE_TAGS suppresses
# a (redundant) copy of the binary in /system/bin for user builds.
# TODO: Build the ramdisk image in a more principled way.

LOCAL_MODULE_TAGS := eng

ifeq ($(BOARD_CUSTOM_RECOVERY_KEYMAPPING),)
  LOCAL_SRC_FILES += default_recovery_keys.c
else
  LOCAL_SRC_FILES += $(BOARD_CUSTOM_RECOVERY_KEYMAPPING)
endif

LOCAL_STATIC_LIBRARIES += libext4_utils libz
LOCAL_STATIC_LIBRARIES += libminzip libunz libmincrypt

LOCAL_STATIC_LIBRARIES += libminizip libminadbd libedify libbusybox libmkyaffs2image libunyaffs liberase_image libdump_image libflash_image

LOCAL_STATIC_LIBRARIES += libdedupe libcrypto_static libcrecovery libflashutils libmtdutils libmmcutils libbmlutils

ifeq ($(BOARD_USES_BML_OVER_MTD),true)
LOCAL_STATIC_LIBRARIES += libbml_over_mtd
endif

LOCAL_STATIC_LIBRARIES += libminui libpixelflinger_static libpng libcutils
LOCAL_STATIC_LIBRARIES += libstdc++ libc

LOCAL_C_INCLUDES += system/extras/ext4_utils

include $(BUILD_EXECUTABLE)

RECOVERY_LINKS := edify busybox flash_image dump_image mkyaffs2image unyaffs erase_image nandroid reboot volume setprop dedupe minizip

# nc is provided by external/netcat
RECOVERY_SYMLINKS := $(addprefix $(TARGET_RECOVERY_ROOT_OUT)/sbin/,$(RECOVERY_LINKS))
$(RECOVERY_SYMLINKS): RECOVERY_BINARY := $(LOCAL_MODULE)
$(RECOVERY_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Symlink: $@ -> $(RECOVERY_BINARY)"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf $(RECOVERY_BINARY) $@

ALL_DEFAULT_INSTALLED_MODULES += $(RECOVERY_SYMLINKS)

# Now let's do recovery symlinks
BUSYBOX_LINKS := $(shell cat external/busybox/busybox-minimal.links)
exclude := tune2fs mke2fs
RECOVERY_BUSYBOX_SYMLINKS := $(addprefix $(TARGET_RECOVERY_ROOT_OUT)/sbin/,$(filter-out $(exclude),$(notdir $(BUSYBOX_LINKS))))
$(RECOVERY_BUSYBOX_SYMLINKS): BUSYBOX_BINARY := busybox
$(RECOVERY_BUSYBOX_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Symlink: $@ -> $(BUSYBOX_BINARY)"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf $(BUSYBOX_BINARY) $@

ALL_DEFAULT_INSTALLED_MODULES += $(RECOVERY_BUSYBOX_SYMLINKS) 

include $(CLEAR_VARS)
LOCAL_MODULE := nandroid-md5.sh
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := RECOVERY_EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/sbin
LOCAL_SRC_FILES := nandroid-md5.sh
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := killrecovery.sh
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := RECOVERY_EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/sbin
LOCAL_SRC_FILES := killrecovery.sh
include $(BUILD_PREBUILT)

#philz external scripts
include $(CLEAR_VARS)
LOCAL_MODULE := raw-backup.sh
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := RECOVERY_EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/sbin
LOCAL_SRC_FILES := raw-backup.sh
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := ors-mount.sh
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := RECOVERY_EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/sbin
LOCAL_SRC_FILES := ors-mount.sh
include $(BUILD_PREBUILT)
#end philz external scripts

include $(CLEAR_VARS)

LOCAL_SRC_FILES := verifier_test.c verifier.c

LOCAL_MODULE := verifier_test

LOCAL_FORCE_STATIC_EXECUTABLE := true

LOCAL_MODULE_TAGS := tests

LOCAL_STATIC_LIBRARIES := libmincrypt libcutils libstdc++ libc

include $(BUILD_EXECUTABLE)

include $(commands_recovery_local_path)/bmlutils/Android.mk
include $(commands_recovery_local_path)/dedupe/Android.mk
include $(commands_recovery_local_path)/flashutils/Android.mk
include $(commands_recovery_local_path)/libcrecovery/Android.mk
include $(commands_recovery_local_path)/minui/Android.mk
include $(commands_recovery_local_path)/minelf/Android.mk
include $(commands_recovery_local_path)/minzip/Android.mk
include $(commands_recovery_local_path)/minadbd/Android.mk
include $(commands_recovery_local_path)/mtdutils/Android.mk
include $(commands_recovery_local_path)/mmcutils/Android.mk
include $(commands_recovery_local_path)/tools/Android.mk
include $(commands_recovery_local_path)/edify/Android.mk
include $(commands_recovery_local_path)/updater/Android.mk
include $(commands_recovery_local_path)/applypatch/Android.mk
include $(commands_recovery_local_path)/utilities/Android.mk
include $(commands_recovery_local_path)/pigz/Android.mk
commands_recovery_local_path :=
