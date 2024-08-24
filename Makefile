CC = /opt/aarch64-none-elf/bin/aarch64-none-elf-gcc
AS = /opt/aarch64-none-elf/bin/aarch64-none-elf-as
LD = /opt/aarch64-none-elf/bin/aarch64-none-elf-ld
STRIP = /opt/aarch64-none-elf/bin/aarch64-none-elf-strip -s -R .dynamic -R .got -R .got.plt -R .dynsym -R .dynstr -R .hash -R .comment tty_init
CFLAGS = -nostdinc -nostdlib -ffreestanding
CFLAGS += -Wall -Wextra -pedantic -Werror -Wfatal-errors
CFLAGS += -march=armv8-a+crc+crypto -mtune=cortex-a72.cortex-a53
CFLAGS += -fno-asynchronous-unwind-tables -fcf-protection=none -fno-stack-protector -fno-stack-clash-protection
CFLAGS += -ffunction-sections
LDFLAGS = -nostdlib -no-dynamic-linker -e _start --gc-sections --build-id=none
STRIPFLAGS = -s -R .dynamic -R .got -R .got.plt -R .dynsym -R .dynstr -R .hash -R .comment

ifeq ($(optimize),1)
CFLAGS += -Os
else
CFLAGS += -O0
endif

LIBC_DIR = /root/mini_libc

ifeq ($(pic),1)
CFLAGS += -fPIC
LDFLAGS += -pie -T $(LIBC_DIR)/default_pic.lds
else
LDFLAGS += -T $(LIBC_DIR)/default.lds
endif

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

strip : $(OUTPUT)
	$(STRIP) $(STRIPFLAGS) $(OUTPUT)

clean :
	rm -rf *.o $(OUTPUT)

.PHONY : all strip clean
