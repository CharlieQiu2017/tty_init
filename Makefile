CC = /opt/aarch64-none-elf/bin/aarch64-none-elf-gcc
AS = /opt/aarch64-none-elf/bin/aarch64-none-elf-as
LD = /opt/aarch64-none-elf/bin/aarch64-none-elf-ld
STRIP = /opt/aarch64-none-elf/bin/aarch64-none-elf-strip
FREEFLAGS = -nostdlib -ffreestanding
WARNFLAGS = -Wall -Wextra -pedantic -Werror -Wfatal-errors
ARCHFLAGS = -march=armv8-a+crc+crypto -mtune=cortex-a72.cortex-a53
PROTFLAGS = -fomit-frame-pointer -fno-asynchronous-unwind-tables -fcf-protection=none -fno-stack-protector -fno-stack-clash-protection -fno-ident
GCFLAGS = -ffunction-sections
LDFLAGS = -nostdlib -static --no-dynamic-linker -e _start --gc-sections --build-id=none
STRIPFLAGS = -s -R .dynamic -R .got -R .got.plt -R .dynsym -R .dynstr -R .hash -R .comment

ifeq ($(optimize),1)
OPTFLAGS = -Os -fweb
else
OPTFLAGS = -O0
endif

LIBC_DIR = /home/z/mini_libc

ifeq ($(pic),1)
PICFLAGS = -fPIC
LDFLAGS += -pie -T $(LIBC_DIR)/default_pic.lds
LIBC = $(LIBC_DIR)/libc_pic.a
else
PICFLAGS = 
LDFLAGS += -T $(LIBC_DIR)/default.lds
LIBC = $(LIBC_DIR)/libc.a
endif

LIBGCC = /opt/aarch64-none-elf/lib/gcc/aarch64-none-elf/14.2.0/libgcc.a

INCFLAGS = -I $(LIBC_DIR)/include
EXTFLAGS = 

CFLAGS = $(FREEFLAGS) $(WARNFLAGS) $(ARCHFLAGS) $(PROTFLAGS) $(GCFLAGS) $(OPTFLAGS) $(PICFLAGS) $(INCFLAGS) $(EXTFLAGS)

OUTPUT = tty_init

all: $(OUTPUT)

$(OUTPUT) : main.o
	$(LD) $(LDFLAGS) -o $@ $(LIBC_DIR)/crt.o $^ $(LIBC) $(LIBGCC)

strip : $(OUTPUT)
	$(STRIP) $(STRIPFLAGS) $(OUTPUT)

clean :
	rm -rf *.o $(OUTPUT)

.PHONY : all strip clean
