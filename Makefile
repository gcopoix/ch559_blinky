# Project target
PROJECT = firmware

# Toolchain definitions (SDCC with CH55x flash tool)
CC = sdcc
OBJCOPY = sdobjcopy
PACKHEX = packihx
ISPFLASH = isp55e0

SRC_DIR = ./src
INC_DIR = ./inc
BUILD_DIR = ./build




SRCS := $(wildcard $(SRC_DIR)/*.c)
OBJS := $(patsubst %.c,$(BUILD_DIR)/%.rel,$(SRCS))

XRAM_SIZE = 0x1800
XRAM_LOC  = 0x0000
CODE_SIZE = 0xF000

CFLAGS := -mmcs51 --model-large --stack-auto -I$(INC_DIR) -I. \
          -Dbit=__bit -Dsbit=__sbit -Dsfr=__sfr -Dsfr16=__sfr16 -Dcode=__code -Ddata=__data -Didata=__idata -Dxdata=__xdata -Dpdata=__pdata -D_at_=__at -Dinterrupt=__interrupt -Dusing=__using \
          -DUINT8=uint8_t   -DPUINT8=uint8_t*   -D"UINT8X=uint8_t __xdata"   -D"UINT8C=const uint8_t __code"   -D"PUINT8C=const uint8_t __code*" \
          -DUINT16=uint16_t -DPUINT16=uint16_t* -D"UINT16X=uint16_t __xdata" -D"UINT16C=const uint16_t __code" -D"PUINT16C=const uint16_t __code*" \
          --xram-size $(XRAM_SIZE) --xram-loc $(XRAM_LOC) --code-size $(CODE_SIZE)


LFLAGS := $(CFLAGS)

.PHONY: all clean size

all: $(BUILD_DIR)/$(PROJECT).bin $(BUILD_DIR)/$(PROJECT).hex size


$(BUILD_DIR)/%.rel : %.c Makefile
	@mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) -o $@ $<


$(BUILD_DIR)/$(PROJECT).ihx: $(OBJS)
	$(CC) $(OBJS) $(LFLAGS) -o $@
		

%.hex: %.ihx
	$(PACKHEX) $< > $@

%.bin: %.ihx
	$(OBJCOPY) -I ihex -O binary $< $@


size: $(BUILD_DIR)/$(PROJECT).ihx
	@echo '---------- Segments ----------'
	@egrep '(ABS,CON)|(REL,CON)' $(basename $<).map | gawk --non-decimal-data '{dec = sprintf("%d","0x" $$2); print dec " " $$0}' | /usr/bin/sort -n -k1 | cut -f2- -d' ' | uniq
	@echo '---------- Memory ----------'
	@egrep 'available|EXTERNAL|FLASH' $(basename $<).mem


flash: $(BUILD_DIR)/$(PROJECT).bin
	$(ISPFLASH) -f $<

clean:
	@rm -rf $(BUILD_DIR)
