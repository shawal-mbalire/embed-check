CC = arm-none-eabi-gcc
CFLAGS = -mcpu=cortex-m4 -mthumb -O2 -g
LDFLAGS = -Ttm4c123g.ld -nostdlib

SRC = hello.c tm4c123g_startup_gcc.c
OUT = hello.elf

all: $(OUT)

$(OUT): $(SRC) tm4c123g.ld
	$(CC) $(CFLAGS) $(SRC) -o $@ $(LDFLAGS)

clean:
	rm -f $(OUT) *.o 