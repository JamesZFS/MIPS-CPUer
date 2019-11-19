ifndef CROSS_COMPILE
CROSS_COMPILE = mips-mti-elf-
endif
CC = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

OBJECTS = a.o

export	CROSS_COMPILE

# ********************
# Rules of Compilation
# ********************

all: a.data

%.o: %.s
	$(CC) -mips32 $< -o $@
a.om: $(OBJECTS)
	$(LD) -T ram.ld $(OBJECTS) -o $@
a.bin: a.om
	$(OBJCOPY) -j .text -O binary $<  $@
a.asm: a.om
	$(OBJDUMP) -D $< > $@
a.data: a.bin
	./Bin2Mem.exe -f $< -o $@
clean:
	rm -f *.o *.om *.bin *.data *.mif *.asm
