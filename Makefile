CC = sdcc
OBJCOPY = sdobjcopy
PACKHEX = packihx
ISPFLASH = isp55e0

SRC_DIR = ./src
OBJ_DIR = ./build


TARGET = main


SRCS := $(wildcard $(SRC_DIR)/*.c)
OBJS := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.rel,$(SRCS))

XRAM_SIZE = 0x1800
XRAM_LOC  = 0x0000
CODE_SIZE = 0xF000

CFLAGS := -mmcs51 --model-large --stack-auto -I./inc \
          --xram-size $(XRAM_SIZE) --xram-loc $(XRAM_LOC) --code-size $(CODE_SIZE)


LFLAGS := $(CFLAGS)

.PHONY: all clean

all: $(OBJ_DIR)/$(TARGET).bin $(OBJ_DIR)/$(TARGET).hex size


$(OBJ_DIR)/%.rel : $(SRC_DIR)/%.c Makefile
	@-mkdir -p build
	$(CC) -c $(CFLAGS) -o $@ $<


$(OBJ_DIR)/$(TARGET).ihx: $(OBJS)
	$(CC) $(OBJS) $(LFLAGS) -o $(OBJ_DIR)/$(TARGET).ihx
		

$(OBJ_DIR)/$(TARGET).hex: $(OBJ_DIR)/$(TARGET).ihx
	$(PACKHEX) $(OBJ_DIR)/$(TARGET).ihx > $(OBJ_DIR)/$(TARGET).hex

$(OBJ_DIR)/$(TARGET).bin: $(OBJ_DIR)/$(TARGET).ihx
	$(OBJCOPY) -I ihex -O binary $(OBJ_DIR)/$(TARGET).ihx $(OBJ_DIR)/$(TARGET).bin


size: $(OBJ_DIR)/$(TARGET).ihx
	@echo '---------- Segments ----------'
	@egrep '(ABS,CON)|(REL,CON)' $(OBJ_DIR)/$(TARGET).map | gawk --non-decimal-data '{dec = sprintf("%d","0x" $$2); print dec " " $$0}' | /usr/bin/sort -n -k1 | cut -f2- -d' ' | uniq
	@echo '---------- Memory ----------'
	@egrep 'available|EXTERNAL|FLASH' $(OBJ_DIR)/$(TARGET).mem


flash: $(OBJ_DIR)/$(TARGET).bin
	$(ISPFLASH) -f $(OBJ_DIR)/$(TARGET).bin

clean:
	-rm -rf $(OBJ_DIR)
