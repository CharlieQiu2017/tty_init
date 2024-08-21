CC = /opt/aarch64-none-elf/bin/aarch64-none-elf-gcc
AS = /opt/aarch64-none-elf/bin/aarch64-none-elf-as
LD = /opt/aarch64-none-elf/bin/aarch64-none-elf-ld
CFLAGS = -nostdinc -nostdlib -ffreestanding
CFLAGS += -fno-asynchronous-unwind-tables -fcf-protection=none -fno-stack-protector -fno-stack-clash-protection
CFLAGS += -ffunction-sections
LDFLAGS = -nostdlib -no-dynamic-linker --gc-sections --build-id=none

ifeq ($(optimize),1)
CFLAGS += -Os
else
CFLAGS += -O0
endif

ifeq ($(pic),1)
CFLAGS += -fPIC
LDFLAGS += -pie
endif

LIBC_DIR = /root/mini_libc

ifeq ($(pic),1)
LIBC = $(LIBC_DIR)/libc_pic.a
else
LIBC = $(LIBC_DIR)/libc.a
endif

LGCC = /opt/aarch64-none-elf/lib/gcc/aarch64-none-elf/13.3.1/libgcc.a
CFLAGS += -I $(LIBC_DIR)/include

OUTPUT = tty_init

all: $(OUTPUT)

$(OUTPUT) : main.o
	$(LD) $(LDFLAGS) -o $@ $(LIBC_DIR)/crt.o $^ $(LIBC) $(LGCC)

%.o : %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean :
	rm -rf *.o $(OUTPUT)

.PHONY : all clean
