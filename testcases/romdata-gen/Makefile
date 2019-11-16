ifndef CROSS_COMPILE
CROSS_COMPILE = mips-mti-elf-
endif
CC = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

OBJECTS = inst_rom.o

export	CROSS_COMPILE

# ********************
# Rules of Compilation
# ********************

all: inst_rom.data

%.o: %.s
	$(CC) -mips32 $< -o $@
inst_rom.om: $(OBJECTS)
	$(LD) $(OBJECTS) -o $@
inst_rom.bin: inst_rom.om
	$(OBJCOPY) -O binary $<  $@
inst_rom.asm: inst_rom.om
	$(OBJDUMP) -D $< > $@
inst_rom.data: inst_rom.bin
	./Bin2Mem.exe -f $< -o $@
clean:
	rm -f *.o *.om *.bin *.data *.mif *.asm
