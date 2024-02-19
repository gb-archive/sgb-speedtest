#!/usr/bin/env -S make -f

RGBASM ?= rgbasm
RGBLINK ?= rgblink
RGBFIX ?= rgbfix
RGBGFX ?= rgbgfx

# rgbds defines
# flags
AS_FLAGS  = -h -Wall -p ${PAD_VAL} $(addprefix -I,${INC_PATHS}) $(addprefix -D,${DEFINES})
LD_FLAGS = -w -p ${PAD_VAL}
FIX_FLAGS  = -v -l 0x33 -j -s -t ${HDR_TITLE} -k ${HDR_LICENSEE} -m ${HDR_MBC} -r ${HDR_RAM} -n ${HDR_VER} -p ${PAD_VAL}
# include paths
INC_PATHS = src/inc/ src/res/ res/
# (string?) constants for rgbasm
DEFINES = ${CONFIG}
# pad value
PAD_VAL = 0xFF

# ROM defines
# filename for the binary
BIN_NAME = sgb-speedtest
# name for the header
HDR_TITLE = "SPEED TEST"
# new licensee code
HDR_LICENSEE = "--"
# mapper used
HDR_MBC = 0
# rgbfix will set ROM size for you
# RAM size
HDR_RAM = 0
# ROM version size
HDR_VER = 0

# dependencies
AS_DEPS = $(wildcard src/inc/*.inc) res/screen.2bpp res/font.2bpp
LD_DEPS = $(patsubst src/%.sm83,obj/%.o,$(wildcard src/*.sm83))

.PHONY: all clean

all: bin/${BIN_NAME}.gb

clean:
	${RM} -r bin/ obj/ res/

# assets
res/screen.2bpp: src/res/screen.png
	@mkdir -p ${@D}
	${RGBGFX} -v -d 2 -u --colors "#420, #fff, #000, #f00" -o $@ -t res/screen.tilemap $<

res/font.2bpp: src/res/font.png
	@mkdir -p ${@D}
	${RGBGFX} -v -d 2 --colors "#420, #fff, #000, #f00" -o $@ $<

# object files and binaries
obj/%.o: src/%.sm83 ${AS_DEPS}
	@mkdir -p ${@D}
	${RGBASM} ${ASM_FLAGS} -o $@ $<

bin/${BIN_NAME}.gb: ${LD_DEPS}
	@mkdir -p ${@D}
	${RGBLINK} ${LINK_FLAGS} -m bin/${BIN_NAME}.map -n bin/${BIN_NAME}.sym -o $@ $^
	${RGBFIX} ${FIX_FLAGS} $@
