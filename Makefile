# Select the right toolchain, maybe
CXX     = avr-g++
CC      = avr-gcc
AR      = avr-ar
AS      = avr-as
LD      = avr-ld
MKDIR_P = mkdir -p

CFLAGS?=-std=c11 -Os -Wall -g -pedantic -MMD -mmcu=atmega2560
CXXFLAGS?=-std=c++14 -Os -Wall -g -pedantic -MMD -mmcu=atmega2560
HWDEFS?=-D__AVR_ATmega2560__ -DF_CPU=16000000
#LDFLAGS?=

# output crap here
OUT=build

INCS=$(addprefix -I./,TVout TVout/spec TVoutfonts)

TVOUT=TVout.cpp TVoutPrint.cpp video_gen.cpp
TVOUTFONTS=font4x6.cpp font6x8.cpp font8x8.cpp font8x8ext.cpp
PROJ=arduino-tvout

TVOUTSRC=$(addprefix TVout/,$(TVOUT))
TVOUTOBJ=$(addprefix $(OUT)/,$(TVOUT:.cpp=.o))
TVOUTDEP=$(addprefix $(OUT)/,$(TVOUT:.cpp=.d))
TVOUTFONTSSRC=$(addprefix TVoutfonts/,$(TVOUTFONTS))
TVOUTFONTSOBJ=$(addprefix $(OUT)/,$(TVOUTFONTS:.cpp=.o))
TVOUTFONTSDEP=$(addprefix $(OUT)/,$(TVOUTFONTS:.cpp=.d))
OBJS=$(TVOUTOBJ) $(TVOUTFONTSOBJ)
LIBTARGETS=libtvout.a libtvoutfonts.a
BLIBS=$(addprefix $(OUT)/,$(LIBTARGETS))

all: $(BLIBS)

$(OUT):
	$(MKDIR_P) $@

$(OUT)/libtvout.a: $(TVOUTOBJ)
	$(AR) rs $@ $^

$(OUT)/libtvoutfonts.a: $(TVOUTFONTSOBJ)
	$(AR) rs $@ $^

$(OUT)/%.o: TVout/%.cpp | $(OUT)
	$(CXX) -o $@ -c $< $(CXXFLAGS) $(INCS) $(HWDEFS)
$(OUT)/%.o: TVoutfonts/%.cpp | $(OUT)
	$(CXX) -o $@ -c $< $(CXXFLAGS) $(INCS) $(HWDEFS)

$(OUT)/*.d: Makefile | $(OUT)

$(PROJ)-%.tar.gz:
	git archive --format=tar.gz \
		--prefix=$(@:$(PROJ)-%.tar.gz=$(PROJ)-%/) \
		-o $@ $(@:$(PROJ)-%.tar.gz=%)

$(TVOUTDEP): Makefile $(TVOUTOBJ)
$(TVOUTFONTSDEP): Makefile $(TVOUTFONTSOBJ)

clean:
	$(RM) -r "$(OUT)"

ifneq ($(MAKECMDGOALS),clean)
-include $(TVOUTDEP)
-include $(TVOUTFONTSDEP)
endif
.PHONY: all clean
.DEFAULT: all
