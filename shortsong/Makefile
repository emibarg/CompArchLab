ARMGNU ?= aarch64-unknown-linux-gnu

AOPS = --warn --fatal-warnings

asm : kernel8.img

all : asm

clean :
	rm -f *.o
	rm -f *.img
	rm -f *.hex
	rm -f *.elf
	rm -f *.list
	rm -f *.img
	rm -f memory_map.txt

main.o : main.s
	$(ARMGNU)-as $(AOPS) main.s -o main.o


kernel8.img : memmap main.o
	$(ARMGNU)-ld main.o -T memmap -o main.elf -M > memory_map.txt
	$(ARMGNU)-objdump -D main.elf > main.list
	$(ARMGNU)-objcopy main.elf -O ihex main.hex
	$(ARMGNU)-objcopy main.elf -O binary kernel8.img
